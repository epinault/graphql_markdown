defmodule GraphqlMarkdown.SinglePage do
  @moduledoc """
  Single page generator from Graphql to Markdown.

  Every section is rendered into one document, preceded by a title and an
  optional table of contents. Links point at anchors inside the page.

  Rendering is pure: `render_schema/2` returns the page content and never
  touches the filesystem.
  """
  alias GraphqlMarkdown.MarkdownHelpers
  alias GraphqlMarkdown.Page
  alias GraphqlMarkdown.Page.Layout
  alias GraphqlMarkdown.Schema

  @filename "graphql_schema.md"

  @doc """
  Renders the whole schema into a single markdown page.

  Returns a one-element list of `{filename, content}`.
  """
  @spec render_schema(Schema.t(), keyword()) :: [{String.t(), String.t()}]
  def render_schema(schema_details, options) do
    layout =
      struct!(Layout, [section_level: 2, link: &anchor/1] ++ Keyword.take(options, [:depth]))

    lines = [
      Page.title(options),
      "",
      toc(schema_details, options),
      Enum.map(Page.sections(), &[Page.section(&1, schema_details, layout), ""])
    ]

    [{@filename, MarkdownHelpers.document(lines)}]
  end

  defp toc(schema_details, options) do
    if options[:no_toc], do: [], else: [Page.toc(schema_details, &toc_anchor/2), ""]
  end

  defp toc_anchor(section, nil), do: "#" <> section
  defp toc_anchor(_section, name), do: "#" <> String.downcase(name)

  # Everything lives in the same document, so a type is linked by its anchor.
  defp anchor(type), do: "#" <> String.downcase(Schema.field_type(type))
end
