defmodule GraphqlMarkdown.InterfaceLinksTest do
  @moduledoc """
  Regression tests for links to interface-typed fields in multi-page output,
  which pointed at the scalars page instead of the interfaces page
  (issue #33).
  """
  use ExUnit.Case, async: true

  @schema "test/fixtures/schema.json"

  test "multi page links an interface return type to the interfaces page" do
    assert {:ok, pages} = GraphqlMarkdown.render(schema: @schema, multi_page: true)

    assert pages["queries.md"] =~ "Type: [Character](interfaces.html#character)\n"
    refute pages["queries.md"] =~ "scalars.html#character"
  end

  test "single page links an interface return type to its in-page anchor" do
    assert {:ok, %{"graphql_schema.md" => content}} = GraphqlMarkdown.render(schema: @schema)

    assert content =~ "Type: [Character](#character)\n"
  end
end
