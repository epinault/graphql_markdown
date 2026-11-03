defmodule GraphqlMarkdown.Backlinks do
  @moduledoc """
  Reverse index of type references: for every named type, the operations
  that return it and the types and operations that use it in a field or an
  argument.

  Built once per render from a `GraphqlMarkdown.Schema` and looked up while
  rendering type entries, when the `:backlinks` option is set.
  """

  alias GraphqlMarkdown.Schema

  @typedoc "An operation (by section and name) or a type referencing the indexed type."
  @type ref :: {:operation, String.t(), String.t()} | {:type, map()}

  @type entry :: %{returned_by: [ref()], used_by: [ref()]}

  @type t :: %{String.t() => entry()}

  @operations ~w(queries mutations subscriptions)
  @type_sections ~w(objects inputs interfaces)

  @empty %{returned_by: [], used_by: []}

  @doc "Builds the index. Operations come in schema order, types in section order."
  @spec index(Schema.t()) :: t()
  def index(schema_details) do
    operations =
      for section <- @operations,
          root = Map.get(schema_details, String.to_existing_atom(section)),
          root != nil,
          field <- List.wrap(root["fields"]),
          do: {section, field}

    types =
      for section <- @type_sections,
          type <- List.wrap(Map.get(schema_details, String.to_existing_atom(section))),
          do: type

    returned_by =
      for {section, field} <- operations,
          do: {Schema.field_type(field["type"]), {:operation, section, field["name"]}}

    used_by_operations =
      for {section, field} <- operations,
          arg <- List.wrap(field["args"]),
          do: {Schema.field_type(arg["type"]), {:operation, section, field["name"]}}

    used_by_types =
      for type <- types,
          field <- List.wrap(type["fields"] || type["inputFields"]),
          ref <- [field["type"] | Enum.map(List.wrap(field["args"]), & &1["type"])],
          name = Schema.field_type(ref),
          name != type["name"],
          do: {name, {:type, type}}

    %{}
    |> add(:returned_by, returned_by)
    |> add(:used_by, used_by_operations ++ used_by_types)
    |> Map.new(fn {name, entry} ->
      {name,
       Map.new(entry, fn {key, refs} ->
         {key, refs |> Enum.reverse() |> Enum.uniq_by(&key_of/1)}
       end)}
    end)
  end

  @doc "The references to `name`, or empty lists when nothing refers to it."
  @spec lookup(t(), String.t()) :: entry()
  def lookup(index, name), do: Map.get(index, name, @empty)

  defp add(index, key, pairs) do
    Enum.reduce(pairs, index, fn {name, ref}, index ->
      Map.update(index, name, Map.put(@empty, key, [ref]), fn entry ->
        Map.update!(entry, key, &[ref | &1])
      end)
    end)
  end

  defp key_of({:type, type}), do: {:type, type["name"]}
  defp key_of(operation), do: operation
end
