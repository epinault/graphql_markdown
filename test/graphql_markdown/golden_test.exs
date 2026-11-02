defmodule GraphqlMarkdown.GoldenTest do
  @moduledoc """
  Golden-file tests: every fixture is rendered in every mode and compared
  byte-for-byte with the markdown checked in under `test/fixtures/expected`.

  When an output change is intentional, regenerate the expected files with

      UPDATE_GOLDEN=1 mix test test/graphql_markdown/golden_test.exs

  and review the diff before committing it.
  """
  use ExUnit.Case, async: true

  @expected_dir "test/fixtures/expected"

  @fixtures "test/fixtures/*.json"
            |> Path.wildcard()
            |> Enum.reject(&String.starts_with?(Path.basename(&1), "invalid"))

  @modes [
    single: [],
    single_no_toc: [no_toc: true, title: "My API"],
    multi: [multi_page: true]
  ]

  for fixture <- @fixtures, {mode, options} <- @modes do
    name = Path.basename(fixture, ".json")

    @tag fixture: fixture, options: options, expected: Path.join([@expected_dir, name, "#{mode}"])
    test "#{name} rendered as #{mode} matches the golden files", context do
      assert {:ok, pages} = GraphqlMarkdown.render([schema: context.fixture] ++ context.options)

      if System.get_env("UPDATE_GOLDEN"), do: write_golden(context.expected, pages)

      expected = read_golden(context.expected)

      assert Enum.sort(Map.keys(pages)) == Enum.sort(Map.keys(expected)),
             "the set of generated files changed; run UPDATE_GOLDEN=1 if intended"

      for {filename, content} <- pages do
        assert content == expected[filename],
               "#{Path.join(context.expected, filename)} differs from the rendered output; " <>
                 "run UPDATE_GOLDEN=1 if the change is intended"
      end
    end
  end

  defp read_golden(dir) do
    case File.ls(dir) do
      {:ok, files} ->
        Map.new(files, &{&1, File.read!(Path.join(dir, &1))})

      {:error, _} ->
        flunk("no golden files under #{dir}; run UPDATE_GOLDEN=1 mix test to create them")
    end
  end

  defp write_golden(dir, pages) do
    File.rm_rf!(dir)
    File.mkdir_p!(dir)
    Enum.each(pages, fn {filename, content} -> File.write!(Path.join(dir, filename), content) end)
  end
end
