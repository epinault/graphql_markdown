defmodule GraphqlMarkdown.RenderTest do
  @moduledoc """
  Tests for the in-memory rendering API and for generation being free of
  global process state (issue #11).
  """
  use ExUnit.Case, async: true

  @moduletag :tmp_dir

  @schema "test/fixtures/schema.json"

  describe "render/1" do
    test "returns the single-page markdown keyed by filename without touching disk" do
      assert {:ok, %{"graphql_schema.md" => content}} = GraphqlMarkdown.render(schema: @schema)
      assert is_binary(content)
      assert content =~ "# Graphql Schema"
      assert content =~ "## Queries"
    end

    test "returns one entry per page in multi-page mode" do
      assert {:ok, pages} = GraphqlMarkdown.render(schema: @schema, multi_page: true)

      assert Enum.sort(Map.keys(pages)) ==
               ~w(enums.md index.md inputs.md interfaces.md mutations.md objects.md queries.md scalars.md subscriptions.md unions.md)

      assert pages["queries.md"] =~ "# Queries"
    end

    test "returns the same content that generate/1 writes to disk", %{tmp_dir: dir} do
      assert {:ok, %{"graphql_schema.md" => rendered}} =
               GraphqlMarkdown.render(schema: @schema, title: "Same")

      assert {:ok, [path]} =
               GraphqlMarkdown.generate(schema: @schema, output_dir: dir, title: "Same")

      assert File.read!(path) == rendered
    end

    test "propagates load errors" do
      assert GraphqlMarkdown.render(schema: "missing.json") == {:error, :enoent}

      assert GraphqlMarkdown.render(schema: "test/fixtures/invalid_schema.json") ==
               {:error, :invalid_schema}
    end
  end

  describe "generate/1" do
    test "can run concurrently in the same VM", %{tmp_dir: dir} do
      dirs = for i <- 1..4, do: Path.join(dir, "concurrent_#{i}")
      Enum.each(dirs, &File.mkdir_p!/1)

      results =
        dirs
        |> Task.async_stream(fn out ->
          GraphqlMarkdown.generate(schema: @schema, output_dir: out)
        end)
        |> Enum.map(fn {:ok, result} -> result end)

      assert results == Enum.map(dirs, &{:ok, [Path.join(&1, "graphql_schema.md")]})
    end

    test "does not leave a named renderer process behind", %{tmp_dir: dir} do
      assert {:ok, _} = GraphqlMarkdown.generate(schema: @schema, output_dir: dir)
      refute Process.whereis(:single)
    end
  end
end
