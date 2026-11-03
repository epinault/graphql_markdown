defmodule Mix.Tasks.GraphqlGenMarkdown do
  @shortdoc "Transform a GraphQL JSON schema to markdown"

  @moduledoc """
  A mix task to convert a GraphQL JSON schema to markdown

  usage
  -----

  mix graphql_gen_markdown [OPTIONS]

  valid override args:
    -f, --schema            Path to the schema file
    -o, --output-dir        Where to output the files. Default: [Current Directory]
    -m, --multi-page        Generate each type in a separate file. Default: [single page format]
    -t, --title             Specify the page title for the generated file (Applies to single file only)
    --no-toc                Do not generate the table of content (Applies to single file only)


  Examples
  --------

  1. Convert the GraphQL JSON schema to a single markdown file

  ```elixir
  mix graphql_gen_markdown -f myschema.json
  ```

  2. Convert the GraphQL JSON schema to a multiple markdown file

  ```elixir
  mix graphql_gen_markdown -f myschema.json -m
  ```

  """
  use Mix.Task

  @args [
    schema: :string,
    output_dir: :string,
    multi_page: :boolean,
    title: :string,
    no_toc: :boolean
  ]

  @args_aliases [
    f: :schema,
    o: :output_dir,
    m: :multi_page,
    t: :title
  ]

  @doc false
  def run(args) do
    {parsed_args, _} = OptionParser.parse!(args, aliases: @args_aliases, strict: @args)

    unless parsed_args[:schema] do
      Mix.raise("""
      --schema (-f) is required.

      usage: mix graphql_gen_markdown -f path/to/schema.json [-o DIR] [-m] [-t TITLE] [--no-toc]
      """)
    end

    case GraphqlMarkdown.generate(parsed_args) do
      {:ok, files} ->
        Mix.shell().info("Generated:\n" <> Enum.map_join(files, "\n", &("  " <> &1)))
        {:ok, files}

      {:error, reason} ->
        Mix.raise(error_message(parsed_args[:schema], reason))
    end
  end

  defp error_message(path, :enoent), do: "Could not read #{path}: no such file or directory"

  defp error_message(path, %Jason.DecodeError{} = error),
    do: "#{path} is not valid JSON: #{Exception.message(error)}"

  defp error_message(path, :invalid_schema),
    do:
      "#{path} is not a GraphQL introspection result (expected a top-level \"data\" -> \"__schema\" key)"

  defp error_message(path, reason),
    do: "Failed to generate markdown from #{path}: #{inspect(reason)}"
end
