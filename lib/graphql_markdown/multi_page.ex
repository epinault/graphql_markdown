defmodule GraphqlMarkdown.MultiPage do
  @moduledoc """
  Multi page generator from Graphql to Markdown.

  Every section becomes its own page, so links point at the page holding the
  referenced type, with ExDoc's `.html` extension.

  Rendering is pure: `render_schema/2` returns the page contents and never
  touches the filesystem.
  """
  alias GraphqlMarkdown.MarkdownHelpers
  alias GraphqlMarkdown.Page
  alias GraphqlMarkdown.Page.Layout
  alias GraphqlMarkdown.Schema

  @doc """
  Renders the schema into one markdown page per section.

  Returns an ordered list of `{filename, content}`.
  """
  @spec render_schema(Schema.t(), keyword()) :: [{String.t(), String.t()}]
  def render_schema(schema_details, _options) do
    layout = %Layout{section_level: 1, link: &page_reference/1}

    Enum.map(Page.sections(), fn section ->
      {"#{section}.md", MarkdownHelpers.document(Page.section(section, schema_details, layout))}
    end)
  end

  defp page_reference(type) do
    page =
      case Schema.field_kind(type) do
        "OBJECT" -> "objects"
        "INPUT_OBJECT" -> "inputs"
        "ENUM" -> "enums"
        "UNION" -> "unions"
        "INTERFACE" -> "interfaces"
        _ -> "scalars"
      end

    String.downcase(page <> ".html#" <> Schema.field_type(type))
  end
end
