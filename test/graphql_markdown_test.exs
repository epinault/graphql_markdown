defmodule GraphqlMarkdownTest do
  use ExUnit.Case, async: true
  doctest GraphqlMarkdown

  @moduletag :tmp_dir

  @schema "test/fixtures/schema.json"
  @multi_page_files ~w(queries mutations subscriptions objects inputs enums scalars interfaces unions)

  describe "#generate" do
    test "convert schema to markdown as single page", %{tmp_dir: dir} do
      expected = {:ok, [Path.join(dir, "graphql_schema.md")]}

      assert GraphqlMarkdown.generate(schema: @schema, output_dir: dir) == expected

      # assert that it can generate multiple times
      assert GraphqlMarkdown.generate(schema: @schema, output_dir: dir) == expected
    end

    test "convert schema to markdown as single page with no TOC", %{tmp_dir: dir} do
      assert {:ok, [path]} =
               GraphqlMarkdown.generate(schema: @schema, output_dir: dir, no_toc: true)

      refute File.read!(path) =~ "* [Queries](#queries) "
    end

    test "convert schema to markdown as single page with custom title", %{tmp_dir: dir} do
      assert {:ok, [path]} =
               GraphqlMarkdown.generate(schema: @schema, output_dir: dir, title: "Other Title")

      assert File.read!(path) =~ "# Other Title"
    end

    test "keeps the user-supplied title verbatim, including acronyms", %{tmp_dir: dir} do
      assert {:ok, [path]} =
               GraphqlMarkdown.generate(schema: @schema, output_dir: dir, title: "My API Docs")

      assert File.read!(path) =~ "# My API Docs\n"
    end

    test "table of contents keeps the original casing of field and type names", %{tmp_dir: dir} do
      assert {:ok, [path]} = GraphqlMarkdown.generate(schema: @schema, output_dir: dir)

      content = File.read!(path)
      assert content =~ "    * [userSsoDetails](#userssodetails)"
      assert content =~ "    * [LoginResponseV2](#loginresponsev2)"
      refute content =~ "Userssodetails"
    end

    test "convert schema to markdown as multipage", %{tmp_dir: dir} do
      expected = {:ok, Enum.map(@multi_page_files, &Path.join(dir, "#{&1}.md"))}

      assert GraphqlMarkdown.generate(schema: @schema, output_dir: dir, multi_page: true) ==
               expected

      # assert that it can generate multiple times
      assert GraphqlMarkdown.generate(schema: @schema, output_dir: dir, multi_page: true) ==
               expected

      # anchors need to be downcased to match other parts of the generated markdown
      assert File.read!(Path.join(dir, "queries.md")) =~ "Type: [Droid](objects.html#droid)"

      # union types need to be a valid type for links
      assert File.read!(Path.join(dir, "mutations.md")) =~
               "Type: [LoginResponseV2](unions.html#loginresponsev2)"
    end

    test "fails to load the file" do
      assert GraphqlMarkdown.generate(schema: "dontexistfile") == {:error, :enoent}
    end

    test "fails to find a schema" do
      assert GraphqlMarkdown.generate(schema: "test/fixtures/invalid_schema.json") ==
               {:error, :invalid_schema}
    end

    test "fails to decode the Json" do
      assert {
               :error,
               %Jason.DecodeError{}
             } = GraphqlMarkdown.generate(schema: "test/fixtures/invalid_json_schema.json")
    end

    test "writes non-ASCII characters (em dash) to file without crashing", %{tmp_dir: dir} do
      assert {:ok, _files} =
               GraphqlMarkdown.generate(
                 schema: "test/fixtures/unicode_schema.json",
                 output_dir: dir,
                 multi_page: true
               )

      assert File.read!(Path.join(dir, "inputs.md")) =~
               "Invoice UID — required when job_uid is absent"
    end
  end

  describe "subscriptions" do
    test "single page renders subscriptions and does not crash" do
      assert {:ok, %{"graphql_schema.md" => content}} = GraphqlMarkdown.render(schema: @schema)

      assert content =~ "## Subscriptions"
      assert content =~ "### loginEvent"
      assert content =~ "subscription LoginEvent {"
    end

    test "subscription root type is not listed as an object" do
      assert {:ok, %{"graphql_schema.md" => single}} = GraphqlMarkdown.render(schema: @schema)
      refute single =~ "### RootSubscriptionType"

      assert {:ok, pages} = GraphqlMarkdown.render(schema: @schema, multi_page: true)
      refute pages["objects.md"] =~ "## RootSubscriptionType"
      assert pages["subscriptions.md"] =~ "## loginEvent"
    end
  end
end
