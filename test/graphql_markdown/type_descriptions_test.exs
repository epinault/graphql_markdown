defmodule GraphqlMarkdown.TypeDescriptionsTest do
  @moduledoc """
  Regression tests for object, interface and input descriptions, which used
  to be dropped from the generated markdown (issue #9).
  """
  use ExUnit.Case, async: true

  @fixture "test/fixtures/type_descriptions_schema.json"

  test "single page renders the description under each type header" do
    assert {:ok, %{"graphql_schema.md" => content}} = GraphqlMarkdown.render(schema: @fixture)

    assert content =~ "### Droid\n\nAn autonomous mechanical character.\n"
    assert content =~ "### Character\n\nSomething with a name, human or not.\n"
    assert content =~ "### DroidFilter\n\nCriteria used to narrow down droids.\n"
  end

  test "multi page renders the description under each type header" do
    assert {:ok, pages} = GraphqlMarkdown.render(schema: @fixture, multi_page: true)

    assert pages["objects.md"] =~ "## Droid\n\nAn autonomous mechanical character.\n"
    assert pages["interfaces.md"] =~ "## Character\n\nSomething with a name, human or not.\n"
    assert pages["inputs.md"] =~ "## DroidFilter\n\nCriteria used to narrow down droids.\n"
  end
end
