defmodule Mix.Tasks.GraphqlGenMarkdownTest do
  use ExUnit.Case, async: false

  alias Mix.Tasks.GraphqlGenMarkdown

  @moduletag :tmp_dir

  setup do
    Mix.shell(Mix.Shell.Process)
    on_exit(fn -> Mix.shell(Mix.Shell.IO) end)
    :ok
  end

  test "prints the generated files on success", %{tmp_dir: dir} do
    GraphqlGenMarkdown.run(["-f", "test/fixtures/schema.json", "-o", dir])

    assert_received {:mix_shell, :info, [message]}
    assert message =~ Path.join(dir, "graphql_schema.md")
  end

  test "introspects an Absinthe schema module with --schema-module", %{tmp_dir: dir} do
    GraphqlGenMarkdown.run(["-s", "GraphqlMarkdown.TestSchema", "-o", dir])

    assert_received {:mix_shell, :info, ["Generated:" <> _ = message]}
    assert message =~ Path.join(dir, "graphql_schema.md")
    assert File.read!(Path.join(dir, "graphql_schema.md")) =~ "### Droid"
  end

  test "limits the example operations with --depth", %{tmp_dir: dir} do
    GraphqlGenMarkdown.run(["-f", "test/fixtures/return_types_schema.json", "-o", dir, "-d", "1"])

    content = File.read!(Path.join(dir, "graphql_schema.md"))
    assert content =~ "droids {\n    id\n    name\n  }"
    refute content =~ "owner {"
  end

  test "raises a readable error for a depth below 1" do
    assert_raise Mix.Error, ~r/--depth must be a positive integer/, fn ->
      GraphqlGenMarkdown.run(["-f", "test/fixtures/return_types_schema.json", "-d", "0"])
    end
  end

  test "--backlinks appends Returned by and Used by lists", %{tmp_dir: dir} do
    GraphqlGenMarkdown.run([
      "-f",
      "test/fixtures/nested_operations_schema.json",
      "-o",
      dir,
      "--backlinks"
    ])

    content = File.read!(Path.join(dir, "graphql_schema.md"))
    assert content =~ "Returned by:\n\n  * [starship](#starship)"
    assert content =~ "Used by:\n\n  * [Human](#human)"
  end

  describe "--link-ext and --front-matter" do
    test "--link-ext md rewrites multi-page links", %{tmp_dir: dir} do
      GraphqlGenMarkdown.run([
        "-f",
        "test/fixtures/return_types_schema.json",
        "-o",
        dir,
        "-m",
        "--link-ext",
        "md"
      ])

      assert File.read!(Path.join(dir, "queries.md")) =~ "[Droid](objects.md#droid)"
    end

    test "raises a readable error for an unknown --link-ext" do
      assert_raise Mix.Error, ~r/--link-ext must be one of html, md or none/, fn ->
        GraphqlGenMarkdown.run([
          "-f",
          "test/fixtures/return_types_schema.json",
          "--link-ext",
          "foo"
        ])
      end
    end

    test "--front-matter adds a YAML block", %{tmp_dir: dir} do
      GraphqlGenMarkdown.run([
        "-f",
        "test/fixtures/return_types_schema.json",
        "-o",
        dir,
        "--front-matter"
      ])

      assert File.read!(Path.join(dir, "graphql_schema.md")) =~
               ~r/\A---\ntitle: "Graphql Schema"\n---\n/
    end
  end

  describe "-o -" do
    import ExUnit.CaptureIO

    test "writes the single page to stdout and nothing to disk" do
      output =
        capture_io(fn ->
          assert :ok = GraphqlGenMarkdown.run(["-f", "test/fixtures/schema.json", "-o", "-"])
        end)

      assert String.starts_with?(output, "# Graphql Schema\n")
      assert output =~ "## Queries"
      refute_received {:mix_shell, :info, _}
      refute File.exists?("-")
    end

    test "cannot be combined with multi-page output" do
      assert_raise Mix.Error, ~r/-o - .*--multi-page/, fn ->
        GraphqlGenMarkdown.run(["-f", "test/fixtures/schema.json", "-o", "-", "-m"])
      end
    end

    test "cannot be combined with --check" do
      assert_raise Mix.Error, ~r/-o - .*--check/, fn ->
        GraphqlGenMarkdown.run(["-f", "test/fixtures/schema.json", "-o", "-", "--check"])
      end
    end
  end

  describe "--check" do
    test "reports up-to-date files and writes nothing", %{tmp_dir: dir} do
      GraphqlGenMarkdown.run(["-f", "test/fixtures/schema.json", "-o", dir, "-m"])
      before = Enum.sort(File.ls!(dir))

      assert :ok =
               GraphqlGenMarkdown.run([
                 "-f",
                 "test/fixtures/schema.json",
                 "-o",
                 dir,
                 "-m",
                 "--check"
               ])

      assert_received {:mix_shell, :info, ["Generated:" <> _]}
      assert_received {:mix_shell, :info, [message]}
      assert message =~ "up to date"
      assert Enum.sort(File.ls!(dir)) == before
    end

    test "raises listing the outdated files and leaves them untouched", %{tmp_dir: dir} do
      GraphqlGenMarkdown.run(["-f", "test/fixtures/schema.json", "-o", dir, "-m"])
      File.write!(Path.join(dir, "queries.md"), "stale")
      File.rm!(Path.join(dir, "unions.md"))

      error =
        assert_raise Mix.Error, fn ->
          GraphqlGenMarkdown.run(["-f", "test/fixtures/schema.json", "-o", dir, "-m", "--check"])
        end

      assert error.message =~ "out of date"
      assert error.message =~ "#{Path.join(dir, "queries.md")} (changed)"
      assert error.message =~ "#{Path.join(dir, "unions.md")} (missing)"
      assert File.read!(Path.join(dir, "queries.md")) == "stale"
      refute File.exists?(Path.join(dir, "unions.md"))
    end
  end

  test "raises when both --schema and --schema-module are given" do
    assert_raise Mix.Error, ~r/either --schema.*or --schema-module/i, fn ->
      GraphqlGenMarkdown.run(["-f", "schema.json", "-s", "GraphqlMarkdown.TestSchema"])
    end
  end

  test "raises a readable error when the module is not an Absinthe schema" do
    assert_raise Mix.Error, ~r/Not\.A\.Schema is not an Absinthe schema/, fn ->
      GraphqlGenMarkdown.run(["-s", "Not.A.Schema"])
    end
  end

  test "raises with usage when --schema is missing" do
    assert_raise Mix.Error, ~r/--schema.*is required/i, fn ->
      GraphqlGenMarkdown.run([])
    end
  end

  test "raises a readable error when the schema file does not exist" do
    assert_raise Mix.Error, ~r/does_not_exist\.json.*no such file/i, fn ->
      GraphqlGenMarkdown.run(["-f", "does_not_exist.json"])
    end
  end

  test "raises a readable error when the schema file is not valid JSON" do
    assert_raise Mix.Error, ~r/invalid_json_schema\.json.*not valid JSON/i, fn ->
      GraphqlGenMarkdown.run(["-f", "test/fixtures/invalid_json_schema.json"])
    end
  end

  test "raises a readable error when the JSON is not an introspection result" do
    assert_raise Mix.Error, ~r/invalid_schema\.json.*introspection/i, fn ->
      GraphqlGenMarkdown.run(["-f", "test/fixtures/invalid_schema.json"])
    end
  end
end
