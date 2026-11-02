defmodule GraphqlMarkdown.SinglePage do
  @moduledoc """
  Single page generator from Graphql to Markdown.

  Rendering is pure: `render_schema/2` returns the page content and never
  touches the filesystem.
  """
  alias GraphqlMarkdown.MarkdownHelpers
  alias GraphqlMarkdown.OperationDetailsHelpers
  alias GraphqlMarkdown.Schema

  @filename "graphql_schema.md"

  @sections ~w(queries mutations subscriptions objects inputs enums scalars interfaces unions)

  @doc """
  Renders the whole schema into a single markdown page.

  Returns a one-element list of `{filename, content}`.
  """
  @spec render_schema(Schema.t(), keyword()) :: [{String.t(), String.t()}]
  def render_schema(schema_details, options) do
    lines = [
      generate_title(options),
      "",
      generate_toc(schema_details, options),
      generate_sections(schema_details)
    ]

    [{@filename, MarkdownHelpers.document(lines)}]
  end

  defp generate_title(options) do
    title = Keyword.get(options, :title, "Graphql Schema")
    MarkdownHelpers.header(title, 1)
  end

  defp generate_toc(schema_details, options) do
    if options[:no_toc] do
      []
    else
      [
        Enum.map(@sections, fn section ->
          toc_entries(section, Map.get(schema_details, String.to_existing_atom(section)))
        end),
        ""
      ]
    end
  end

  defp toc_entries(_, nil), do: []

  defp toc_entries(type_label, %{"fields" => fields})
       when type_label in ["queries", "mutations", "subscriptions"] do
    toc_entries(type_label, fields)
  end

  defp toc_entries(type_label, types) do
    [
      type_label
      |> String.capitalize()
      |> MarkdownHelpers.anchor()
      |> MarkdownHelpers.list(1),
      Enum.map(types, fn type ->
        type["name"]
        |> MarkdownHelpers.anchor()
        |> MarkdownHelpers.list(2)
      end)
    ]
  end

  defp generate_sections(schema_details) do
    Enum.map(@sections, fn section_name ->
      [
        generate_section(
          section_name,
          Map.get(schema_details, String.to_existing_atom(section_name)),
          schema_details
        ),
        ""
      ]
    end)
  end

  defp generate_section(type, empty, _schema_details) when empty in [[], nil] do
    [MarkdownHelpers.header(type, 2, true), "", "None"]
  end

  # Handles Mutations and Queries and Subscriptions
  defp generate_section(type, %{"fields" => fields}, schema_details)
       when type in ["queries", "mutations", "subscriptions"] do
    [
      MarkdownHelpers.header(type, 2, true),
      "",
      Enum.map(fields, fn field ->
        type_details =
          field["type"]
          |> Schema.field_type()
          |> MarkdownHelpers.anchor()

        [
          MarkdownHelpers.header(field["name"], 3),
          "",
          "Type: #{type_details}",
          "",
          generate_description(field["description"]),
          field["args"] |> generate_data() |> table(field: {}, description: {}),
          type
          |> OperationDetailsHelpers.generate_operation_details(field, schema_details)
          |> MarkdownHelpers.graphql_operation_code_block(),
          ""
        ]
      end)
    ]
  end

  defp generate_section(type, details, _schema_details) do
    [
      MarkdownHelpers.header(type, 2, true),
      "",
      Enum.map(details, fn detail ->
        [
          MarkdownHelpers.header(detail["name"], 3),
          "",
          generate_description(detail["description"]),
          generate_type_body(detail),
          ""
        ]
      end)
    ]
  end

  defp generate_type_body(%{"kind" => "INPUT_OBJECT"} = detail) do
    detail["inputFields"] |> generate_data() |> table(field: {}, description: {})
  end

  defp generate_type_body(%{"kind" => "SCALAR"}), do: []

  defp generate_type_body(%{"kind" => "ENUM"} = detail) do
    detail["enumValues"]
    |> Enum.map(fn enum -> [enum["name"], enum["description"]] end)
    |> table(value: {}, description: {})
  end

  defp generate_type_body(%{"kind" => "UNION"} = detail) do
    ["Possible types:", "", generate_unions_possible_types(detail["possibleTypes"])]
  end

  defp generate_type_body(detail) do
    detail["fields"] |> generate_data() |> table(field: {}, description: {})
  end

  defp generate_unions_possible_types(types) do
    Enum.map(types, fn possible_type ->
      possible_type["name"]
      |> MarkdownHelpers.link("objects.html##{String.downcase(possible_type["name"])}")
      |> MarkdownHelpers.list(1)
    end)
  end

  # The description is its own paragraph. Nothing is emitted when the schema
  # has no description, so the following block directly follows the header.
  defp generate_description(nil), do: []
  defp generate_description(description), do: [description, ""]

  defp generate_data(fields) do
    Enum.map(fields, fn field ->
      type_details =
        field["type"]
        |> Schema.full_field_type()
        |> MarkdownHelpers.anchor(Schema.field_type(field["type"]))

      [
        MarkdownHelpers.code(field["name"]) <> " ( " <> type_details <> " )",
        MarkdownHelpers.field_description(field["description"], field["defaultValue"])
      ]
    end)
  end

  # A table with no rows is only a header, so it is skipped altogether.
  defp table([], _columns), do: []
  defp table(rows, columns), do: [MarkdownHelpers.table(columns, rows), ""]
end
