defmodule GraphqlMarkdown.CheckTest do
  @moduledoc """
  `check/1` compares freshly rendered markdown with the committed files
  without writing anything (issue #19).
  """
  use ExUnit.Case, async: true

  @moduletag :tmp_dir

  @schema "test/fixtures/schema.json"

  test "is :ok when every file on disk matches the rendered markdown", %{tmp_dir: dir} do
    {:ok, _} = GraphqlMarkdown.generate(schema: @schema, output_dir: dir, multi_page: true)

    assert GraphqlMarkdown.check(schema: @schema, output_dir: dir, multi_page: true) == :ok
  end

  test "reports a file whose content differs as changed", %{tmp_dir: dir} do
    {:ok, _} = GraphqlMarkdown.generate(schema: @schema, output_dir: dir, multi_page: true)
    File.write!(Path.join(dir, "queries.md"), "# Queries\n\nstale\n")

    assert GraphqlMarkdown.check(schema: @schema, output_dir: dir, multi_page: true) ==
             {:error, {:outdated, [{Path.join(dir, "queries.md"), :changed}]}}
  end

  test "reports a file that does not exist as missing, in filename order", %{tmp_dir: dir} do
    {:ok, _} = GraphqlMarkdown.generate(schema: @schema, output_dir: dir, multi_page: true)
    File.rm!(Path.join(dir, "unions.md"))
    File.rm!(Path.join(dir, "enums.md"))

    assert GraphqlMarkdown.check(schema: @schema, output_dir: dir, multi_page: true) ==
             {:error,
              {:outdated,
               [{Path.join(dir, "enums.md"), :missing}, {Path.join(dir, "unions.md"), :missing}]}}
  end

  test "never writes to the output directory", %{tmp_dir: dir} do
    assert {:error, {:outdated, [{_, :missing}]}} =
             GraphqlMarkdown.check(schema: @schema, output_dir: dir)

    assert File.ls!(dir) == []
  end

  test "takes the rendering options into account", %{tmp_dir: dir} do
    {:ok, _} = GraphqlMarkdown.generate(schema: @schema, output_dir: dir, title: "Mine")

    assert GraphqlMarkdown.check(schema: @schema, output_dir: dir, title: "Mine") == :ok
    assert {:error, {:outdated, _}} = GraphqlMarkdown.check(schema: @schema, output_dir: dir)
  end

  test "propagates load errors" do
    assert GraphqlMarkdown.check(schema: "missing.json") == {:error, :enoent}
  end
end
