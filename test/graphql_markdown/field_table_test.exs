defmodule GraphqlMarkdown.FieldTableTest do
  @moduledoc """
  Field and argument tables have separate `field`, `type` and `description`
  columns instead of packing name and type into one cell (issue #21).
  """
  use ExUnit.Case, async: true

  @fixture "test/fixtures/object_details_schema.json"

  setup do
    assert {:ok, %{"graphql_schema.md" => content}} =
             GraphqlMarkdown.render(schema: @fixture, no_toc: true)

    %{content: content}
  end

  test "object fields get a type column", %{content: content} do
    assert content =~ """
           | field | type | description |
           | ----- | ---- | ----------- |
           | `id` | [ID!](#id) |  |
           | `name` | [String](#string) | Full name |
           """
  end

  test "arguments and deprecation markers stay in the field column", %{content: content} do
    assert content =~
             "| `friends(first: Int = 10, after: String)` | [\\[Character\\]](#character) | Friends of this character |"

    assert content =~
             "| ~~`primaryFunction`~~ | [String](#string) | What the droid was built for. **Deprecated:** Droids no longer have a single function |"
  end

  test "operation arguments are labelled as such", %{content: content} do
    assert content =~ """
           | argument | type | description |
           | -------- | ---- | ----------- |
           | `episode` | [Episode](#episode) |  |
           """
  end

  test "enum tables keep their two columns", %{content: content} do
    assert content =~ "| value | description |\n| ----- | ----------- |\n"
    refute content =~ "( ["
  end

  test "input fields get the type column too" do
    assert {:ok, %{"inputs.md" => inputs}} =
             GraphqlMarkdown.render(schema: "test/fixtures/schema.json", multi_page: true)

    assert inputs =~ "| field | type | description |\n| ----- | ---- | ----------- |\n"
    assert inputs =~ ~r/\| `\w+` \| \[\w+!?\]\(scalars\.html#\w+\) \| /
  end
end
