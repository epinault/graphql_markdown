defmodule GraphqlMarkdown.IndexPageTest do
  @moduledoc """
  Multi-page output comes with an `index.md` holding the title and a table
  of contents linking to every page and type, mirroring the single-page TOC
  (issue #20).
  """
  use ExUnit.Case, async: true

  @moduletag :tmp_dir

  @fixture "test/fixtures/return_types_schema.json"

  test "index.md links every section page and every entry in it" do
    assert {:ok, %{"index.md" => index}} =
             GraphqlMarkdown.render(schema: @fixture, multi_page: true)

    assert index == """
           # Graphql Schema

             * [Queries](queries.html)
               * [droids](queries.html#droids)
               * [droid](queries.html#droid)
               * [maybeDroids](queries.html#maybedroids)
               * [count](queries.html#count)
               * [requiredCount](queries.html#requiredcount)
               * [status](queries.html#status)
               * [searchResults](queries.html#searchresults)
             * [Objects](objects.html)
               * [Droid](objects.html#droid)
               * [Human](objects.html#human)
             * [Inputs](inputs.html)
             * [Enums](enums.html)
               * [Status](enums.html#status)
             * [Scalars](scalars.html)
               * [ID](scalars.html#id)
               * [Int](scalars.html#int)
               * [String](scalars.html#string)
             * [Interfaces](interfaces.html)
             * [Unions](unions.html)
               * [SearchResult](unions.html#searchresult)
           """
  end

  test "the index uses the configured title" do
    assert {:ok, %{"index.md" => index}} =
             GraphqlMarkdown.render(schema: @fixture, multi_page: true, title: "My API")

    assert String.starts_with?(index, "# My API\n")
  end

  test "the index mirrors the single-page table of contents" do
    assert {:ok, %{"graphql_schema.md" => single}} = GraphqlMarkdown.render(schema: @fixture)

    assert {:ok, %{"index.md" => index}} =
             GraphqlMarkdown.render(schema: @fixture, multi_page: true)

    [single_toc | _] = single |> String.split("\n\n## Queries") |> List.wrap()
    [index_toc | _] = index |> String.trim_trailing() |> List.wrap()

    rewritten =
      Regex.replace(~r/\]\((\w+)\.html(#[\w]+)?\)/, index_toc, fn _, section, anchor ->
        "](" <> if(anchor == "", do: "#" <> section, else: anchor) <> ")"
      end)

    assert rewritten == String.trim_trailing(single_toc)
  end

  test "generate/1 writes index.md first", %{tmp_dir: dir} do
    assert {:ok, [first | _] = paths} =
             GraphqlMarkdown.generate(schema: @fixture, output_dir: dir, multi_page: true)

    assert first == Path.join(dir, "index.md")
    assert length(paths) == 10
    assert File.read!(first) =~ "* [Queries](queries.html)"
  end

  test "single-page output has no index" do
    assert {:ok, pages} = GraphqlMarkdown.render(schema: @fixture)
    assert Map.keys(pages) == ["graphql_schema.md"]
  end
end
