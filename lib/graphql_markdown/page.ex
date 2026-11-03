defmodule GraphqlMarkdown.Page do
  @moduledoc """
  Renders the sections of a schema (queries, mutations, objects, enums, ...)
  as nested lists of markdown lines.

  `GraphqlMarkdown.SinglePage` and `GraphqlMarkdown.MultiPage` produce the
  same sections and only differ in how they are laid out, which a
  `GraphqlMarkdown.Page.Layout` captures: the heading level of a section and
  the way a type reference becomes a link.
  """
  alias GraphqlMarkdown.MarkdownHelpers
  alias GraphqlMarkdown.OperationDetailsHelpers
  alias GraphqlMarkdown.Schema

  defmodule Layout do
    @moduledoc """
    What differs between page layouts.

    * `section_level` - heading level of a section title; entries use the
      next level down.
    * `link` - turns an introspection type reference into the URL a link to
      that type should point at.
    """
    @enforce_keys [:section_level, :link]
    defstruct [:section_level, :link]

    @type t :: %__MODULE__{
            section_level: pos_integer(),
            link: (map() -> String.t())
          }
  end

  @sections ~w(queries mutations subscriptions objects inputs enums scalars interfaces unions)
  @operations ~w(queries mutations subscriptions)

  @typedoc "A nested list of lines, consumed by `MarkdownHelpers.document/1`."
  @type lines :: [String.t() | lines()]

  @doc "Section names, in the order they are rendered."
  @spec sections() :: [String.t()]
  def sections, do: @sections

  @doc """
  Renders one section: its heading followed by one entry per operation or
  type, or `None` when the schema has nothing in that section.
  """
  @spec section(String.t(), Schema.t(), Layout.t()) :: lines()
  def section(name, schema_details, %Layout{} = layout) do
    items = Map.get(schema_details, String.to_existing_atom(name))

    [
      MarkdownHelpers.header(name, layout.section_level, true),
      "",
      entries(name, items, schema_details, layout)
    ]
  end

  defp entries(_name, empty, _schema_details, _layout) when empty in [[], nil], do: ["None"]

  defp entries(name, %{"fields" => fields}, schema_details, layout) when name in @operations do
    Enum.map(fields, fn field ->
      [
        entry_header(field["name"], layout),
        "",
        "Type: " <> type_link(field["type"], Schema.field_type(field["type"]), layout),
        "",
        deprecation(field),
        description(field["description"]),
        field["args"] |> field_rows(layout) |> table(field: {}, description: {}),
        name
        |> OperationDetailsHelpers.generate_operation_details(field, schema_details)
        |> MarkdownHelpers.graphql_operation_code_block(),
        ""
      ]
    end)
  end

  defp entries(_name, types, _schema_details, layout) do
    Enum.map(types, fn type ->
      [
        entry_header(type["name"], layout),
        "",
        description(type["description"]),
        type_body(type, layout),
        ""
      ]
    end)
  end

  defp type_body(%{"kind" => "INPUT_OBJECT"} = type, layout) do
    type["inputFields"] |> field_rows(layout) |> table(field: {}, description: {})
  end

  defp type_body(%{"kind" => "SCALAR"}, _layout), do: []

  defp type_body(%{"kind" => "ENUM"} = type, _layout) do
    type["enumValues"]
    |> Enum.map(fn value -> [strike(value["name"], value), description_cell(value)] end)
    |> table(value: {}, description: {})
  end

  defp type_body(%{"kind" => "UNION"} = type, layout) do
    ["Possible types:", "", possible_types(type["possibleTypes"], layout)]
  end

  defp type_body(type, layout) do
    type["fields"] |> field_rows(layout) |> table(field: {}, description: {})
  end

  defp possible_types(types, layout) do
    Enum.map(types, fn possible_type ->
      possible_type
      |> type_link(possible_type["name"], layout)
      |> MarkdownHelpers.list(1)
    end)
  end

  defp entry_header(name, layout), do: MarkdownHelpers.header(name, layout.section_level + 1)

  defp type_link(type, text, layout), do: MarkdownHelpers.link(text, layout.link.(type))

  # The description is its own paragraph. Nothing is emitted when the schema
  # has no description, so the following block directly follows the header.
  defp description(nil), do: []
  defp description(description), do: [description, ""]

  defp field_rows(fields, layout) do
    Enum.map(fields, fn field ->
      type_details = type_link(field["type"], Schema.full_field_type(field["type"]), layout)

      [
        strike(MarkdownHelpers.code(field["name"]), field) <> " ( " <> type_details <> " )",
        description_cell(field)
      ]
    end)
  end

  # The description column: description, default value and deprecation
  # notice, whichever are present.
  defp description_cell(field) do
    MarkdownHelpers.sentences([
      field["description"],
      MarkdownHelpers.default_value(field["defaultValue"]),
      MarkdownHelpers.deprecation(field)
    ])
  end

  defp strike(text, %{"isDeprecated" => true}), do: "~~" <> text <> "~~"
  defp strike(text, _field), do: text

  # A deprecated operation gets its notice as a paragraph of its own.
  defp deprecation(%{"isDeprecated" => true} = field),
    do: [MarkdownHelpers.deprecation(field), ""]

  defp deprecation(_field), do: []

  # A table with no rows is only a header, so it is skipped altogether.
  defp table([], _columns), do: []
  defp table(rows, columns), do: [MarkdownHelpers.table(columns, rows), ""]
end
