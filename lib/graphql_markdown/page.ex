defmodule GraphqlMarkdown.Page do
  @moduledoc """
  Renders the sections of a schema (queries, mutations, objects, enums, ...)
  as nested lists of markdown lines.

  `GraphqlMarkdown.SinglePage` and `GraphqlMarkdown.MultiPage` produce the
  same sections and only differ in how they are laid out, which a
  `GraphqlMarkdown.Page.Layout` captures: the heading level of a section and
  the way a type reference becomes a link.
  """
  alias GraphqlMarkdown.Backlinks
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
    * `page_link` - the URL of a section (given its name and `nil`) or of
      an entry in it (given the section and the entry's name).
    * `depth` - how many nested levels the example operations select.
    * `backlinks` - the `GraphqlMarkdown.Backlinks` index, or `nil` when
      backlinks are not rendered.
    """
    @enforce_keys [:section_level, :link, :page_link]
    defstruct [
      :section_level,
      :link,
      :page_link,
      depth: GraphqlMarkdown.OperationDetailsHelpers.default_depth(),
      backlinks: nil
    ]

    @type t :: %__MODULE__{
            section_level: pos_integer(),
            link: (map() -> String.t()),
            page_link: (String.t(), String.t() | nil -> String.t()),
            depth: pos_integer(),
            backlinks: GraphqlMarkdown.Backlinks.t() | nil
          }
  end

  @sections ~w(queries mutations subscriptions objects inputs enums scalars interfaces unions)
  @operations ~w(queries mutations subscriptions)
  @field_columns [field: {}, type: {}, description: {}]

  @typedoc "A nested list of lines, consumed by `MarkdownHelpers.document/1`."
  @type lines :: [String.t() | lines()]

  @doc "Section names, in the order they are rendered."
  @spec sections() :: [String.t()]
  def sections, do: @sections

  @doc """
  Builds a layout from the layout-specific `fields` and the rendering
  options (`:depth`, `:backlinks`).
  """
  @spec layout(Schema.t(), keyword(), keyword()) :: Layout.t()
  def layout(schema_details, options, fields) do
    backlinks = if options[:backlinks], do: Backlinks.index(schema_details)
    struct!(Layout, fields ++ Keyword.take(options, [:depth]) ++ [backlinks: backlinks])
  end

  @doc "The document title: the `:title` option or `\"Graphql Schema\"`."
  @spec title_text(keyword()) :: String.t()
  def title_text(options), do: Keyword.get(options, :title, "Graphql Schema")

  @doc "The document title as a level-one heading."
  @spec title(keyword()) :: String.t()
  def title(options), do: MarkdownHelpers.header(title_text(options), 1)

  @doc """
  The YAML front matter of a page with the given title, followed by a blank
  line, or nothing when the `:front_matter` option is not set.
  """
  @spec front_matter(String.t(), keyword()) :: lines()
  def front_matter(title, options) do
    if options[:front_matter], do: ["---", "title: " <> yaml_string(title), "---", ""], else: []
  end

  defp yaml_string(text) do
    escaped = text |> String.replace("\\", "\\\\") |> String.replace("\"", "\\\"")
    "\"" <> escaped <> "\""
  end

  @doc """
  The table of contents: one list item per section that exists in the
  schema, with a nested item per operation or type in it.

  Links come from the layout's `page_link`.
  """
  @spec toc(Schema.t(), Layout.t()) :: lines()
  def toc(schema_details, %Layout{page_link: link}) do
    Enum.map(@sections, fn section ->
      case Map.get(schema_details, String.to_existing_atom(section)) do
        nil -> []
        %{"fields" => fields} when section in @operations -> toc_entries(section, fields, link)
        types -> toc_entries(section, types, link)
      end
    end)
  end

  defp toc_entries(section, entries, link) do
    [
      section
      |> String.capitalize()
      |> MarkdownHelpers.link(link.(section, nil))
      |> MarkdownHelpers.list(1),
      Enum.map(entries, fn entry ->
        entry["name"]
        |> MarkdownHelpers.link(link.(section, entry["name"]))
        |> MarkdownHelpers.list(2)
      end)
    ]
  end

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
        field["args"] |> field_rows(layout) |> table(argument: {}, type: {}, description: {}),
        name
        |> OperationDetailsHelpers.generate_operation_details(field, schema_details,
          depth: layout.depth
        )
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
        backlinks(type, layout),
        ""
      ]
    end)
  end

  defp type_body(%{"kind" => "INPUT_OBJECT"} = type, layout) do
    type["inputFields"] |> field_rows(layout) |> table(@field_columns)
  end

  defp type_body(%{"kind" => "SCALAR"}, _layout), do: []

  defp type_body(%{"kind" => "ENUM"} = type, _layout) do
    type["enumValues"]
    |> Enum.map(fn value -> [strike(value["name"], value), description_cell(value)] end)
    |> table(value: {}, description: {})
  end

  defp type_body(%{"kind" => "UNION"} = type, layout) do
    ["Possible types:", "", possible_types(type["possibleTypes"], layout), ""]
  end

  defp type_body(%{"kind" => "INTERFACE"} = type, layout) do
    [
      type["fields"] |> field_rows(layout) |> table(@field_columns),
      implemented_by(type["possibleTypes"], layout)
    ]
  end

  defp type_body(type, layout) do
    [
      implements(type["interfaces"], layout),
      type["fields"] |> field_rows(layout) |> table(@field_columns)
    ]
  end

  defp implements(interfaces, _layout) when interfaces in [[], nil], do: []

  defp implements(interfaces, layout) do
    links = Enum.map_join(interfaces, ", ", &type_link(&1, &1["name"], layout))
    ["Implements: " <> links, ""]
  end

  defp implemented_by(types, _layout) when types in [[], nil], do: []

  defp implemented_by(types, layout) do
    ["Implemented by:", "", possible_types(types, layout), ""]
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
      [
        strike(MarkdownHelpers.code(signature(field)), field),
        type_link(field["type"], Schema.full_field_type(field["type"]), layout),
        description_cell(field)
      ]
    end)
  end

  # Scalars are referenced from almost everywhere, so they get no backlinks.
  defp backlinks(_type, %Layout{backlinks: nil}), do: []
  defp backlinks(%{"kind" => "SCALAR"}, _layout), do: []

  defp backlinks(type, layout) do
    %{returned_by: returned_by, used_by: used_by} =
      Backlinks.lookup(layout.backlinks, type["name"])

    [
      reference_list("Returned by:", returned_by, layout),
      reference_list("Used by:", used_by, layout)
    ]
  end

  defp reference_list(_title, [], _layout), do: []

  defp reference_list(title, references, layout) do
    [
      title,
      "",
      Enum.map(references, &(&1 |> reference_link(layout) |> MarkdownHelpers.list(1))),
      ""
    ]
  end

  defp reference_link({:operation, section, name}, layout),
    do: MarkdownHelpers.link(name, layout.page_link.(section, name))

  defp reference_link({:type, type}, layout), do: type_link(type, type["name"], layout)

  # Fields that take arguments show them inline, in SDL syntax:
  # `friends(first: Int = 10, after: String)`.
  defp signature(%{"args" => [_ | _] = args} = field) do
    field["name"] <> "(" <> Enum.map_join(args, ", ", &argument/1) <> ")"
  end

  defp signature(field), do: field["name"]

  defp argument(%{"defaultValue" => nil} = arg) do
    arg["name"] <> ": " <> Schema.full_field_type(arg["type"])
  end

  defp argument(arg), do: argument(%{arg | "defaultValue" => nil}) <> " = " <> arg["defaultValue"]

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
