defmodule GraphqlMarkdown.EmptyTablesAndDefaultsTest do
  @moduledoc """
  Regression tests for header-only tables and the default-value sentence
  (issue #10).
  """
  use ExUnit.Case, async: true

  @fixture "test/fixtures/empty_args_schema.json"

  setup do
    assert {:ok, %{"graphql_schema.md" => content}} = GraphqlMarkdown.render(schema: @fixture)
    %{content: content}
  end

  test "an operation without arguments does not render a header-only table", %{content: content} do
    [version_section] = Regex.run(~r/### version\n.*?```gql/s, content)
    refute version_section =~ "| argument | type | description |"
  end

  test "an object without fields does not render a header-only table", %{content: content} do
    [nothing_section] = Regex.run(~r/### Nothing\n.*?## Inputs/s, content)
    assert nothing_section =~ "Empty marker object"
    refute nothing_section =~ "| field | type | description |"
  end

  test "description and default value are separated by a period and a space", %{
    content: content
  } do
    assert content =~ "| `first` | [Int](#int) | Page size. The default value is `20` |"
  end

  test "a default value without a description has no leading period", %{content: content} do
    assert content =~ "| `offset` | [Int](#int) | The default value is `0` |"
  end

  test "a description without a default value is rendered as-is", %{content: content} do
    assert content =~ "| `filter` | [Int](#int) | Free text. |"
  end
end
