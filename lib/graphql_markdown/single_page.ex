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
      title(options),
      "",
      toc(schema_details, options),
      Enum.map(Page.sections(), &[Page.section(&1, schema_details, layout), ""])
    ]

    [{@filename, MarkdownHelpers.document(lines)}]
  end

  defp title(options) do
    MarkdownHelpers.header(Keyword.get(options, :title, "Graphql Schema"), 1)
  end

  defp toc(schema_details, options) do
    if options[:no_toc] do
      []
    else
      [
        Enum.map(Page.sections(), fn section ->
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

  # Everything lives in the same document, so a type is linked by its anchor.
  defp anchor(type), do: "#" <> String.downcase(Schema.field_type(type))
end
