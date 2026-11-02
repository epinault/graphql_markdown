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
