defmodule GraphqlMarkdown.MultiPage do
  @moduledoc """
  Multi page generator from Graphql to Markdown.

  Every section becomes its own page, so links point at the page holding the
  referenced type, with the `:link_ext` extension (ExDoc's `.html` by
  default). An `index.md` with the
  title and a table of contents linking to every page and entry comes first.

  Rendering is pure: `render_schema/2` returns the page contents and never
  touches the filesystem.
  """
  alias GraphqlMarkdown.MarkdownHelpers
  alias GraphqlMarkdown.Page
  alias GraphqlMarkdown.Schema

  @doc """
  Renders the schema into one markdown page per section.

  Returns an ordered list of `{filename, content}`, starting with `index.md`.
  """
  @spec render_schema(Schema.t(), keyword()) :: [{String.t(), String.t()}]
  def render_schema(schema_details, options) do
    ext = extension(Keyword.get(options, :link_ext, :html))

    layout =
      Page.layout(schema_details, options,
        section_level: 1,
        link: &page_reference(&1, ext),
        page_link: &page_link(&1, &2, ext)
      )

    pages =
      Enum.map(Page.sections(), fn section ->
        lines = [
          Page.front_matter(String.capitalize(section), options),
          Page.section(section, schema_details, layout)
        ]

        {"#{section}.md", MarkdownHelpers.document(lines)}
      end)

    [{"index.md", index(schema_details, options, layout)} | pages]
  end

  defp index(schema_details, options, layout) do
    MarkdownHelpers.document([
      Page.front_matter(Page.title_text(options), options),
      Page.title(options),
      "",
      Page.toc(schema_details, layout)
    ])
  end

  defp extension(:html), do: ".html"
  defp extension(:md), do: ".md"
  defp extension(:none), do: ""

  defp page_link(section, nil, ext), do: section <> ext
  defp page_link(section, name, ext), do: section <> ext <> "#" <> String.downcase(name)

  defp page_reference(type, ext) do
    page =
      case Schema.field_kind(type) do
        "OBJECT" -> "objects"
        "INPUT_OBJECT" -> "inputs"
        "ENUM" -> "enums"
        "UNION" -> "unions"
        "INTERFACE" -> "interfaces"
        _ -> "scalars"
      end

    String.downcase(page <> ext <> "#" <> Schema.field_type(type))
  end
end
