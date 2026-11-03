defmodule Mix.Tasks.GraphqlGenMarkdown do
  @shortdoc "Transform a GraphQL JSON schema to markdown"

  @moduledoc """
  A mix task to convert a GraphQL JSON schema to markdown

  usage
  -----

  mix graphql_gen_markdown [OPTIONS]

  valid override args:
    -f, --schema            Path to the introspection JSON file
    -s, --schema-module     Absinthe schema module to introspect in-process
                            (requires absinthe in your deps). Use one of -f or -s
    -o, --output-dir        Where to output the files. Default: [Current Directory]
    -m, --multi-page        Generate each type in a separate file. Default: [single page format]
    -t, --title             Specify the page title for the generated file (Applies to single file only)
    --no-toc                Do not generate the table of content (Applies to single file only)
    -d, --depth             How many nested levels the example operations select. Default: 2
    --check                 Do not write anything; fail when the files in the output
                            directory differ from what would be generated


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

  3. Introspect an Absinthe schema directly, without an intermediate JSON file

  ```elixir
  mix graphql_gen_markdown -s MyApp.Schema -o guides
  ```

  4. In CI, fail when the committed markdown is out of date

  ```elixir
  mix graphql_gen_markdown -s MyApp.Schema -o guides/graphql -m --check
  ```

  """
  use Mix.Task

  @args [
    schema: :string,
    schema_module: :string,
    output_dir: :string,
    multi_page: :boolean,
    title: :string,
    no_toc: :boolean,
    depth: :integer,
    check: :boolean
  ]

  @args_aliases [
    f: :schema,
    s: :schema_module,
    o: :output_dir,
    m: :multi_page,
    t: :title,
    d: :depth
  ]

  @usage "usage: mix graphql_gen_markdown (-f path/to/schema.json | -s MyApp.Schema) [-o DIR] [-m] [-t TITLE] [--no-toc] [-d DEPTH] [--check]"

  @doc false
  def run(args) do
    {parsed_args, _} = OptionParser.parse!(args, aliases: @args_aliases, strict: @args)
    options = schema_options(parsed_args)

    if options[:check], do: check(options), else: generate(options)
  end

  defp generate(options) do
    case GraphqlMarkdown.generate(options) do
      {:ok, files} ->
        Mix.shell().info("Generated:\n" <> Enum.map_join(files, "\n", &("  " <> &1)))
        {:ok, files}

      {:error, reason} ->
        Mix.raise(error_message(schema_source(options), reason))
    end
  end

  defp check(options) do
    case GraphqlMarkdown.check(options) do
      :ok ->
        Mix.shell().info("Generated markdown is up to date.")
        :ok

      {:error, {:outdated, changes}} ->
        Mix.raise(
          "Generated markdown is out of date:\n" <>
            Enum.map_join(changes, "\n", fn {path, status} -> "  #{path} (#{status})" end) <>
            "\n\nRun mix graphql_gen_markdown without --check to update it."
        )

      {:error, reason} ->
        Mix.raise(error_message(schema_source(options), reason))
    end
  end

  # Validates that exactly one schema source is given. A schema module lives
  # in the user's project, so the project is compiled and loaded first, the
  # same way mix absinthe.schema.json does it.
  defp schema_options(parsed_args) do
    case {parsed_args[:schema], parsed_args[:schema_module]} do
      {nil, nil} ->
        Mix.raise("One of --schema (-f) or --schema-module (-s) is required.\n\n" <> @usage)

      {_path, nil} ->
        parsed_args

      {nil, module_name} ->
        Mix.Task.run("loadpaths")
        Mix.Task.run("compile")
        Keyword.put(parsed_args, :schema_module, schema_module(module_name))

      {_path, _module} ->
        Mix.raise("Pass either --schema (-f) or --schema-module (-s), not both.\n\n" <> @usage)
    end
  end

  # safe_concat only resolves modules that already exist, so a typo or an
  # uncompiled module is caught here rather than creating a new atom.
  defp schema_module(module_name) do
    Module.safe_concat([module_name])
  rescue
    ArgumentError -> Mix.raise(error_message(module_name, {:not_a_schema, module_name}))
  end

  defp schema_source(options), do: options[:schema] || inspect(options[:schema_module])

  defp error_message(path, :enoent), do: "Could not read #{path}: no such file or directory"

  defp error_message(module, {:not_a_schema, _}),
    do: "#{module} is not an Absinthe schema module (or is not compiled)"

  defp error_message(_module, :absinthe_not_available),
    do: "--schema-module needs Absinthe. Add {:absinthe, \"~> 1.7\"} to your dependencies"

  defp error_message(module, {:introspection_failed, result}),
    do: "Introspecting #{module} failed: #{inspect(result)}"

  defp error_message(_path, {:invalid_depth, depth}),
    do: "--depth must be a positive integer, got #{inspect(depth)}"

  defp error_message(path, %Jason.DecodeError{} = error),
    do: "#{path} is not valid JSON: #{Exception.message(error)}"

  defp error_message(path, :invalid_schema),
    do:
      "#{path} is not a GraphQL introspection result (expected a top-level \"data\" -> \"__schema\" key)"

  defp error_message(path, reason),
    do: "Failed to generate markdown from #{path}: #{inspect(reason)}"
end
