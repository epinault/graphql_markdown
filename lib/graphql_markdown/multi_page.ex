defmodule GraphqlMarkdown.MultiPage do
  @moduledoc """
  Multi page generator from Graphql to Markdown
  """
  alias GraphqlMarkdown.MarkdownHelpers
  alias GraphqlMarkdown.OperationDetailsHelpers
  alias GraphqlMarkdown.Renderer
  alias GraphqlMarkdown.Schema

  def render_schema(schema_details, options) do
    output_dir = Keyword.get(options, :output_dir, ".")

    Enum.map(
      [
        "queries",
        "mutations",
        "objects",
        "subscriptions",
        "inputs",
        "enums",
        "scalars",
        "interfaces",
        "unions"
      ],
      fn section ->
        filename = Path.join(output_dir, "#{section}.md")

        case Renderer.start_link(name: section, filename: filename) do
          {:ok, _pid} ->
            generate_title(section, options)

            generate_section(
              section,
              Map.get(schema_details, String.to_existing_atom(section)),
              schema_details
            )

            Renderer.save(String.to_existing_atom(section))
            filename

          _ ->
            {:error, :renderer_error}
        end
      end
    )
  end

  defp generate_title(type, _options) do
    render(type, MarkdownHelpers.header(type, 1, true))
    render_newline(type)
  end

  def generate_section(type, [], _schema_details) do
    render(type, "None")
  end

  def generate_section(type, nil, _schema_details) do
    render(type, "None")
  end

  def generate_section(type, %{"fields" => fields} = _details, schema_details)
      when type in ["queries", "mutations", "subscriptions"] do
    Enum.each(fields, fn field ->
      render(type, MarkdownHelpers.header(field["name"], 2))
      render_newline(type)

      type_details =
        field["type"]
        |> Schema.field_type()
        |> MarkdownHelpers.link(reference_for_kind(field))

      render(type, "Type: #{type_details}")
      render_newline(type)

      generate_description(type, field["description"])

      field["args"]
      |> generate_data()
      |> render_table(type, field: {}, description: {})

      gql_code_markdown =
        type
        |> OperationDetailsHelpers.generate_operation_details(field, schema_details)
        |> MarkdownHelpers.graphql_operation_code_block()

      render(type, gql_code_markdown)

      render_newline(type)
    end)
  end

  def generate_section(type, details, _schema_details) do
    input_kind = Schema.input_kind()
    scalar_kind = Schema.scalar_kind()
    enum_kind = Schema.enum_kind()
    union_kind = Schema.union_kind()

    Enum.each(details, fn detail ->
      render(type, MarkdownHelpers.header(detail["name"], 2))
      render_newline(type)
      generate_description(type, detail["description"])

      case detail["kind"] do
        ^input_kind ->
          detail["inputFields"]
          |> generate_data()
          |> render_table(type, field: {}, description: {})

        ^scalar_kind ->
          :ok

        ^enum_kind ->
          detail["enumValues"]
          |> Enum.map(fn enum -> [enum["name"], enum["description"]] end)
          |> render_table(type, value: {}, description: {})

        ^union_kind ->
          render(type, "Possible types:")
          render_newline(type)
          generate_unions_possible_types(type, detail["possibleTypes"])

        _ ->
          detail["fields"]
          |> generate_data()
          |> render_table(type, field: {}, description: {})
      end

      render_newline(type)
    end)
  end

  defp generate_unions_possible_types(section, types) do
    Enum.each(types, fn possible_type ->
      render(
        section,
        possible_type["name"]
        |> MarkdownHelpers.link("objects.html##{String.downcase(possible_type["name"])}")
        |> MarkdownHelpers.list(1)
      )
    end)
  end

  # Renders the description as its own paragraph. Nothing is emitted when the
  # schema has no description, so the following block directly follows the
  # header.
  defp generate_description(_section, nil), do: :ok

  defp generate_description(section, description) do
    render(section, description)
    render_newline(section)
  end

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
  defp render_table([], _section, _columns), do: :ok

  defp render_table(rows, section, columns) do
    render(section, MarkdownHelpers.table(columns, rows))
    render_newline(section)
  end

  defp reference_for_kind(field) do
    reference =
      case Schema.field_kind(field["type"]) do
        "OBJECT" ->
          "objects.html#" <> Schema.field_type(field["type"])

        "INPUT_OBJECT" ->
          "inputs.html#" <> Schema.field_type(field["type"])

        "ENUM" ->
          "enums.html#" <> Schema.field_type(field["type"])

        "UNION" ->
          "unions.html#" <> Schema.field_type(field["type"])

        _ ->
          "scalars.html#" <> Schema.field_type(field["type"])
      end

    String.downcase(reference)
  end

  defp render(type, text) do
    Renderer.render(text, String.to_existing_atom(type))
  end

  defp render_newline(type) do
    Renderer.render_newline(String.to_existing_atom(type))
  end
end
