defmodule GraphqlMarkdown.OperationDetailsHelpers do
  @moduledoc """
  A set of helpers to generate query and mutation details.
  """

  alias GraphqlMarkdown.Schema

  @type argument :: %{
          name: String.t(),
          type: String.t(),
          required: boolean()
        }

  @type field :: %{
          name: String.t(),
          type: String.t()
        }

  @type return_type :: %{
          name: String.t(),
          kind: String.t(),
          fields: [field()],
          possible_types: [field()]
        }

  @type graphql_operation_details :: %{
          operation_type: String.t(),
          operation_name: String.t(),
          arguments: [argument()],
          return_type: return_type()
        }

  @doc """
  Creates a map with the details of a query or mutation. The details created include
  the operation type, operation name, arguments, and return type.
  """
  @spec generate_operation_details(String.t(), map(), GraphqlMarkdown.Schema.t()) ::
          graphql_operation_details()
  def generate_operation_details(type, field, schema_details) do
    operation_type =
      case type do
        "queries" -> "query"
        "mutations" -> "mutation"
        "subscriptions" -> "subscription"
      end

    arguments = operation_arguments(field["args"])

    operation_details = %{
      operation_type: operation_type,
      operation_name: field["name"],
      arguments: arguments,
      return_type: return_fields(field["type"], schema_details)
    }

    operation_details
  end

  @spec operation_arguments([map()]) :: [argument()]
  defp operation_arguments(args) do
    Enum.map(args, fn arg ->
      arg_type = arg["type"]
      type = Schema.field_type(arg_type)
      required = arg_type["kind"] == "NON_NULL"

      %{
        name: arg["name"],
        type: type,
        required: required
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

  @spec return_fields(map(), GraphqlMarkdown.Schema.t()) :: return_type()
  defp return_fields(type, schema_details) do
    %{"name" => name, "kind" => kind} = unwrap_type(type)

    case kind do
      "OBJECT" ->
        %{name: name, kind: kind, fields: fields_of(schema_details, :objects, name)}

      "UNION" ->
        %{
          name: name,
          kind: kind,
          possible_types: possible_types_of(schema_details, :unions, name)
        }

      "INTERFACE" ->
        %{
          name: name,
          kind: kind,
          fields: fields_of(schema_details, :interfaces, name),
          possible_types: possible_types_of(schema_details, :interfaces, name)
        }

      _ ->
        %{name: name, kind: kind, fields: []}
    end
  end

  defp find_type(schema_details, section, name) do
    schema_details
    |> Map.get(section, [])
    |> Enum.find(%{}, fn type -> type["name"] == name end)
  end

  defp fields_of(schema_details, section, name) do
    schema_details
    |> find_type(section, name)
    |> Map.get("fields", [])
    |> Enum.map(fn field -> %{name: field["name"], type: return_field_type(field)} end)
  end

  defp possible_types_of(schema_details, section, name) do
    schema_details
    |> find_type(section, name)
    |> Map.get("possibleTypes", [])
    |> Enum.map(fn type -> %{name: type["name"], type: "OBJECT"} end)
  end

  @spec return_field_type(map()) :: String.t()
  defp return_field_type(%{"type" => %{"kind" => "NON_NULL"}} = field) do
    get_in(field, ["type", "ofType", "kind"])
  end

  defp return_field_type(field) do
    get_in(field, ["type", "kind"])
  end
end
