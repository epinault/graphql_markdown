defmodule GraphqlMarkdown.TypeDescriptionsTest do
  @moduledoc """
  Regression tests for object, interface and input descriptions, which used
  to be dropped from the generated markdown (issue #9).
  """
  use ExUnit.Case, async: false

  @fixture "test/fixtures/type_descriptions_schema.json"

  setup do
    File.mkdir_p!("guides")
    :ok
  end

  test "single page renders the description under each type header" do
    assert {:ok, _} = GraphqlMarkdown.generate(schema: @fixture, output_dir: "guides")
    content = File.read!("guides/graphql_schema.md")

    assert content =~ "### Droid\n\nAn autonomous mechanical character.\n"
    assert content =~ "### Character\n\nSomething with a name, human or not.\n"
    assert content =~ "### DroidFilter\n\nCriteria used to narrow down droids.\n"
  end

  test "multi page renders the description under each type header" do
    assert {:ok, _} =
             GraphqlMarkdown.generate(schema: @fixture, output_dir: "guides", multi_page: true)

    assert File.read!("guides/objects.md") =~ "## Droid\n\nAn autonomous mechanical character.\n"

    assert File.read!("guides/interfaces.md") =~
             "## Character\n\nSomething with a name, human or not.\n"

    assert File.read!("guides/inputs.md") =~
             "## DroidFilter\n\nCriteria used to narrow down droids.\n"
  end
end
