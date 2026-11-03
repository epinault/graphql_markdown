defmodule GraphqlMarkdown.LinkExtTest do
  @moduledoc """
  Multi-page links can target ExDoc (`.html`), plain markdown viewers
  (`.md`) or clean URLs (no extension), and every page can start with YAML
  front matter (issue #18).
  """
  use ExUnit.Case, async: true

  @fixture "test/fixtures/return_types_schema.json"

  defp multi(options \\ []) do
    assert {:ok, pages} = GraphqlMarkdown.render([schema: @fixture, multi_page: true] ++ options)
    pages
  end

  describe "link_ext" do
    test "defaults to .html for ExDoc" do
      pages = multi()

      assert pages["queries.md"] =~ "Type: [Droid](objects.html#droid)"
      assert pages["index.md"] =~ "* [Queries](queries.html)\n    * [droids](queries.html#droids)"
    end

    test ":md links to the markdown files themselves" do
      pages = multi(link_ext: :md)

      assert pages["queries.md"] =~ "Type: [Droid](objects.md#droid)"
      assert pages["unions.md"] =~ "* [Droid](objects.md#droid)"
      assert pages["index.md"] =~ "* [Queries](queries.md)\n    * [droids](queries.md#droids)"
      refute pages["queries.md"] =~ ".html"
    end

    test ":none produces clean URLs" do
      pages = multi(link_ext: :none)

      assert pages["queries.md"] =~ "Type: [Droid](objects#droid)"
      assert pages["index.md"] =~ "* [Queries](queries)\n    * [droids](queries#droids)"
    end

    test "does not change single-page anchors" do
      assert {:ok, %{"graphql_schema.md" => content}} =
               GraphqlMarkdown.render(schema: @fixture, link_ext: :md)

      assert content =~ "Type: [Droid](#droid)"
    end

    test "rejects unknown extensions" do
      assert GraphqlMarkdown.render(schema: @fixture, link_ext: "foo") ==
               {:error, {:invalid_link_ext, "foo"}}
    end
  end

  describe "front_matter" do
    test "is absent by default" do
      refute String.starts_with?(multi()["queries.md"], "---")
    end

    test "prefixes every multi-page file with its title" do
      pages = multi(front_matter: true, title: "My API")

      assert String.starts_with?(
               pages["queries.md"],
               "---\ntitle: \"Queries\"\n---\n\n# Queries\n"
             )

      assert String.starts_with?(pages["index.md"], "---\ntitle: \"My API\"\n---\n\n# My API\n")
      assert Enum.all?(pages, fn {_, content} -> String.starts_with?(content, "---\ntitle: ") end)
    end

    test "prefixes the single page with the document title" do
      assert {:ok, %{"graphql_schema.md" => content}} =
               GraphqlMarkdown.render(schema: @fixture, front_matter: true)

      assert String.starts_with?(
               content,
               "---\ntitle: \"Graphql Schema\"\n---\n\n# Graphql Schema\n"
             )
    end

    test "escapes quotes and backslashes in the title" do
      assert {:ok, %{"graphql_schema.md" => content}} =
               GraphqlMarkdown.render(
                 schema: @fixture,
                 front_matter: true,
                 title: ~s(Say "hi" \\ bye)
               )

      assert String.starts_with?(content, ~s(---\ntitle: "Say \\"hi\\" \\\\ bye"\n---\n))
    end
  end
end
