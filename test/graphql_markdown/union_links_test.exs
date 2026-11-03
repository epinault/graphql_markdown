defmodule GraphqlMarkdown.UnionLinksTest do
  @moduledoc """
  Regression tests for the links under a union's "Possible types" list,
  which always pointed at `objects.html` even in single-page output
  (issue #32).
  """
  use ExUnit.Case, async: true

  @schema "test/fixtures/schema.json"

  test "single page links possible types to in-page anchors" do
    assert {:ok, %{"graphql_schema.md" => content}} = GraphqlMarkdown.render(schema: @schema)

    assert content =~ "  * [LoginResponse](#loginresponse)\n"
    assert content =~ "  * [UnexpectedRequest](#unexpectedrequest)\n"
    refute content =~ "objects.html"
  end

  test "multi page links possible types to the objects page" do
    assert {:ok, pages} = GraphqlMarkdown.render(schema: @schema, multi_page: true)

    assert pages["unions.md"] =~ "  * [LoginResponse](objects.html#loginresponse)\n"
    assert pages["unions.md"] =~ "  * [UnexpectedRequest](objects.html#unexpectedrequest)\n"
  end
end
