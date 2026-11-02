defmodule GraphqlMarkdown.MultiPage do
  @moduledoc """
  Multi page generator from Graphql to Markdown.

  Rendering is pure: `render_schema/2` returns the page contents and never
  touches the filesystem.
  """
  alias GraphqlMarkdown.MarkdownHelpers
  alias GraphqlMarkdown.OperationDetailsHelpers
  alias GraphqlMarkdown.Schema

  @sections ~w(queries mutations objects subscriptions inputs enums scalars interfaces unions)

  @doc """
  Renders the schema into one markdown page per section.

  Returns an ordered list of `{filename, content}`.
  """
  @spec render_schema(Schema.t(), keyword()) :: [{String.t(), String.t()}]
  def render_schema(schema_details, _options) do
    Enum.map(@sections, fn section ->
      lines = [
        MarkdownHelpers.header(section, 1, true),
        "",
        generate_section(
          section,
          Map.get(schema_details, String.to_existing_atom(section)),
          schema_details
        )
      ]

      {"#{section}.md", MarkdownHelpers.document(lines)}
    end)
  end

  defp generate_section(_type, empty, _schema_details) when empty in [[], nil], do: ["None"]

  defp generate_section(type, %{"fields" => fields}, schema_details)
       when type in ["queries", "mutations", "subscriptions"] do
    Enum.map(fields, fn field ->
      type_details =
        field["type"]
        |> Schema.field_type()
        |> MarkdownHelpers.link(reference_for_kind(field))

      [
        MarkdownHelpers.header(field["name"], 2),
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
  end

  defp generate_section(_type, details, _schema_details) do
    Enum.map(details, fn detail ->
      [
        MarkdownHelpers.header(detail["name"], 2),
        "",
        generate_description(detail["description"]),
        generate_type_body(detail),
        ""
      ]
    end)
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
        |> MarkdownHelpers.link(reference_for_kind(field))

      [
        MarkdownHelpers.code(field["name"]) <> " ( " <> type_details <> " )",
        MarkdownHelpers.field_description(field["description"], field["defaultValue"])
      ]
    end)
  end

  # A table with no rows is only a header, so it is skipped altogether.
  defp table([], _columns), do: []
  defp table(rows, columns), do: [MarkdownHelpers.table(columns, rows), ""]

  defp reference_for_kind(field) do
    page =
      case Schema.field_kind(field["type"]) do
        "OBJECT" -> "objects"
        "INPUT_OBJECT" -> "inputs"
        "ENUM" -> "enums"
        "UNION" -> "unions"
        _ -> "scalars"
      end

    String.downcase(page <> ".html#" <> Schema.field_type(field["type"]))
  end
end
