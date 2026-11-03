defmodule GraphqlMarkdown.OperationDetailsHelpers do
  @moduledoc """
  Builds the details of an example operation (query, mutation or
  subscription): its name, arguments and the selection set to request.

  The selection set recurses into object, interface and union types down to
  a configurable depth, selecting scalar and enum leaves, so that the example
  is valid GraphQL. A field whose type is already selected further up the
  same path is skipped, which breaks cycles such as `friends: [Character]`.
  """

  alias GraphqlMarkdown.Schema

  @default_depth 2

  @type argument :: %{
          name: String.t(),
          type: String.t(),
          required: boolean()
        }

  @typedoc """
  One entry of a selection set: a field, or an inline fragment on a possible
  type of an interface or union. Leaves have an empty `selections` list.
  """
  @type selection ::
          %{name: String.t(), selections: [selection()]}
          | %{on: String.t(), selections: [selection()]}

  @type return_type :: %{name: String.t(), kind: String.t()}

  @type graphql_operation_details :: %{
          operation_type: String.t(),
          operation_name: String.t(),
          arguments: [argument()],
          return_type: return_type(),
          selections: [selection()]
        }

  @doc "The number of nested selection-set levels an example operation contains by default."
  @spec default_depth() :: pos_integer()
  def default_depth, do: @default_depth

  @doc """
  Creates a map with the details of an operation: the operation type and
  name, its arguments, its (unwrapped) return type and the selection set.

  Options:

    * `:depth` - how many nested selection-set levels to generate
      (default #{@default_depth}). `1` selects only the leaves of the return
      type.
  """
  @spec generate_operation_details(String.t(), map(), Schema.t(), keyword()) ::
          graphql_operation_details()
  def generate_operation_details(type, field, schema_details, options \\ []) do
    operation_type =
      case type do
        "queries" -> "query"
        "mutations" -> "mutation"
        "subscriptions" -> "subscription"
      end

    depth = Keyword.get(options, :depth, @default_depth)
    %{"name" => name, "kind" => kind} = return_type = unwrap_type(field["type"])

    %{
      operation_type: operation_type,
      operation_name: field["name"],
      arguments: operation_arguments(field["args"]),
      return_type: %{name: name, kind: kind},
      selections: root_selections(return_type, schema_details, depth)
    }
  end

  @spec operation_arguments([map()]) :: [argument()]
  defp operation_arguments(args) do
    Enum.map(args, fn arg ->
      arg_type = arg["type"]

      %{
        name: arg["name"],
        type: Schema.field_type(arg_type),
        required: arg_type["kind"] == "NON_NULL"
      }
    end)
  end

  # Strips NON_NULL and LIST wrappers so that `Droid`, `Droid!`, `[Droid]`,
  # `[Droid!]!` and deeper nestings all resolve to the named `Droid` type.
  @spec unwrap_type(map()) :: map()
  defp unwrap_type(%{"kind" => kind, "ofType" => inner})
       when kind in ["NON_NULL", "LIST"] and not is_nil(inner),
       do: unwrap_type(inner)

  defp unwrap_type(type), do: type

  # The operation itself must have a selection set when it returns a
  # composite type. When nothing can be selected within the depth, ask for
  # `__typename` so the example stays valid.
  defp root_selections(type, schema_details, depth) do
    case selections(type, schema_details, depth, []) do
      [] -> if leaf?(type), do: [], else: [typename()]
      selections -> selections
    end
  end

  # Returns the selection set for a composite type, or `[]` for a leaf, for a
  # type beyond the depth limit, or for a type on the current path.
  defp selections(%{"kind" => "OBJECT", "name" => name}, schema_details, depth, path) do
    schema_details
    |> fields_of(:objects, name)
    |> field_selections(schema_details, depth, [name | path])
  end

  defp selections(%{"kind" => "INTERFACE", "name" => name}, schema_details, depth, path) do
    path = [name | path]
    fields = fields_of(schema_details, :interfaces, name)
    shared = Enum.map(fields, & &1["name"])

    fragments =
      schema_details
      |> possible_types_of(:interfaces, name)
      |> Enum.flat_map(fn possible_type ->
        own_fields =
          Enum.reject(fields_of(schema_details, :objects, possible_type), &(&1["name"] in shared))

        fragment(possible_type, own_fields, schema_details, depth, path)
      end)

    [typename() | field_selections(fields, schema_details, depth, path)] ++
      fragments
  end

  defp selections(%{"kind" => "UNION", "name" => name}, schema_details, depth, path) do
    path = [name | path]

    fragments =
      schema_details
      |> possible_types_of(:unions, name)
      |> Enum.flat_map(fn possible_type ->
        fragment(
          possible_type,
          fields_of(schema_details, :objects, possible_type),
          schema_details,
          depth,
          path
        )
      end)

    [typename() | fragments]
  end

  defp selections(_leaf, _schema_details, _depth, _path), do: []

  # An inline fragment does not add a nesting level. It is left out when its
  # type is already on the path, or when it has nothing selectable, since
  # `... on Type {}` is invalid.
  defp fragment(type_name, fields, schema_details, depth, path) do
    if type_name in path do
      []
    else
      fields
      |> field_selections(schema_details, depth, [type_name | path])
      |> wrap(%{on: type_name})
    end
  end

  # Leaves are always selected. A composite field is selected with its own
  # selection set one level deeper, unless the depth is exhausted, its type
  # is already on the path, or nothing can be selected in it.
  defp field_selections(fields, schema_details, depth, path) do
    Enum.flat_map(fields, fn field ->
      type = unwrap_type(field["type"])

      cond do
        leaf?(type) ->
          [%{name: field["name"], selections: []}]

        depth <= 1 or type["name"] in path ->
          []

        true ->
          type |> selections(schema_details, depth - 1, path) |> wrap(%{name: field["name"]})
      end
    end)
  end

  defp wrap([], _selection), do: []
  defp wrap(selections, selection), do: [Map.put(selection, :selections, selections)]

  defp leaf?(%{"kind" => kind}), do: kind not in ["OBJECT", "INTERFACE", "UNION"]

  defp typename, do: %{name: "__typename", selections: []}

  defp find_type(schema_details, section, name) do
    schema_details
    |> Map.get(section, [])
    |> Enum.find(%{}, fn type -> type["name"] == name end)
  end

  defp fields_of(schema_details, section, name) do
    schema_details |> find_type(section, name) |> Map.get("fields") |> List.wrap()
  end

  defp possible_types_of(schema_details, section, name) do
    schema_details
    |> find_type(section, name)
    |> Map.get("possibleTypes")
    |> List.wrap()
    |> Enum.map(& &1["name"])
  end
end
