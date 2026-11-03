defmodule GraphqlMarkdown.SchemaModuleTest do
  @moduledoc """
  Tests for introspecting an Absinthe schema module in-process instead of
  reading an introspection JSON file (issue #15).
  """
  use ExUnit.Case, async: true

  alias GraphqlMarkdown.TestSchema

  @moduletag :tmp_dir

  test "render/1 introspects an Absinthe schema module" do
    assert {:ok, %{"graphql_schema.md" => content}} =
             GraphqlMarkdown.render(schema_module: TestSchema)

    assert content =~ "### droid\n\nType: [Droid](#droid)\n\nLook up a droid\n"
    assert content =~ "### Droid\n\nAn autonomous mechanical character.\n"
    assert content =~ "| NEWHOPE | Released in 1977 |"
  end

  test "renders exactly what the introspection JSON of the same schema renders", %{tmp_dir: dir} do
    {:ok, result} = Absinthe.Schema.introspect(TestSchema)
    path = Path.join(dir, "schema.json")
    File.write!(path, Jason.encode!(result))

    assert GraphqlMarkdown.render(schema_module: TestSchema, multi_page: true) ==
             GraphqlMarkdown.render(schema: path, multi_page: true)
  end

  test "generate/1 writes the files for a schema module", %{tmp_dir: dir} do
    assert {:ok, [path]} = GraphqlMarkdown.generate(schema_module: TestSchema, output_dir: dir)
    assert File.read!(path) =~ "# Graphql Schema"
  end

  test "returns an error for a module that is not an Absinthe schema" do
    assert GraphqlMarkdown.render(schema_module: GraphqlMarkdown.MarkdownHelpers) ==
             {:error, {:not_a_schema, GraphqlMarkdown.MarkdownHelpers}}

    assert GraphqlMarkdown.render(schema_module: Does.Not.Exist) ==
             {:error, {:not_a_schema, Does.Not.Exist}}
  end

  test "returns an error when neither a schema path nor a module is given" do
    assert GraphqlMarkdown.render([]) == {:error, :missing_schema}
    assert GraphqlMarkdown.generate(title: "Docs") == {:error, :missing_schema}
  end
end
