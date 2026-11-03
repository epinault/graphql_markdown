# GraphqlMarkdown

Converts a JSON Graphql Schema to Markdown

## Installation

Add `graphql_markdown` to your list of dependencies in `mix.exs`. It requires
Elixir 1.16 or later:

```elixir
def deps do
  [
    {:graphql_markdown, "~> 1.1"}
  ]
end
```

And run:

```shell
mix deps.get
```

Generate a single file called `graphql_schema.md` in the current dir:

```shell
mix graphql_gen_markdown -f ./schema.json
```

The full documentation is on [HexDocs](https://hexdocs.pm/graphql_markdown).

## Quick Start

You can generate either single page with all the types or a multipage that will then generate separately Mutations, Queries, Enums etc, each in a different file.

### Single page

When you run the following

```shell
mix graphql_gen_markdown -f ./schema.json
```
it will generate the following file in your current folder:

./graphql_schema.md

You can change the default title for the single page with `-t` option.

### Example operations

Every query, mutation and subscription comes with an example operation that
selects the scalar and enum fields of its return type, recursing into nested
objects, interfaces and unions two levels deep. Use `-d` to change the depth:

```shell
mix graphql_gen_markdown -f ./schema.json -d 3
```

A field whose type is already selected further up the same path is skipped,
so recursive types such as `friends: [Character]` do not blow up the example.

### Multi pages

When you run the following

```shell
mix graphql_gen_markdown -f ./schema.json -m
```

it will generate the following files in your current folder:

  ./index.md
  ./queries.md
  ./mutations.md
  ./subscriptions.md
  ./objects.md
  ./inputs.md
  ./enums.md
  ./scalars.md
  ./interfaces.md
  ./unions.md

`index.md` holds the title and a table of contents linking to every page and
type, so ExDoc users can list it as the first extra.

### Writing to stdout

Pass `-o -` to print the single page instead of writing a file, for example to
copy it or to pipe it into another tool:

```shell
mix graphql_gen_markdown -f ./schema.json -o - | pbcopy
```

## Integrate with ExDoc and Absinthe

You can easily automate the process with ExDoc by adding the following to your `mix.exs` file:

```elixir
defmodule Azeroth.MixProject do
  use Mix.Project

  # this is needed because the file are generated but if you run mix docs, Mix will check the existence of files first. so have to work around that
  @graphql_files [
    "guides/graphql/index.md",
    "guides/graphql/enums.md",
    "guides/graphql/inputs.md",
    "guides/graphql/interfaces.md",
    "guides/graphql/mutations.md",
    "guides/graphql/objects.md",
    "guides/graphql/queries.md",
    "guides/graphql/scalars.md",
    "guides/graphql/unions.md",
    "guides/graphql/subscriptions.md"
  ]
  ...

  defp aliases do
  [
    docs: [
      "graphql_gen_markdown -s YourApp.GraphQL.Schema -o guides/graphql -m",
      "docs"
    ],...
  ]
```

If you would rather keep an introspection JSON file around, generate it first
and point the task at it instead:

```elixir
    docs: [
      "absinthe.schema.json",
      "graphql_gen_markdown -f schema.json -o guides/graphql -m",
      "docs"
    ],
```

Make sure the absinthe schema is specified or generated with that name. Or add to your config.exs:

```elixir
config :absinthe, schema: YourApp.GraphQL.Schema
```

## Using it with Absinthe

If your schema is an Absinthe module you can skip the intermediate JSON file
and introspect it in-process:

```shell
mix graphql_gen_markdown -s MyApp.Schema -o guides
```

or, from code, `GraphqlMarkdown.generate(schema_module: MyApp.Schema, output_dir: "guides")`.
Absinthe is an optional dependency of this package, so it only works when
`absinthe` is already in your `mix.exs`.

## Checking committed docs in CI

If you commit the generated markdown, add a step that fails when it no longer
matches the schema. `--check` renders in memory, compares with the files in
the output directory and exits non-zero on any difference, without writing:

```shell
mix graphql_gen_markdown -s YourApp.GraphQL.Schema -o guides/graphql -m --check
```

## Using it as a library

`GraphqlMarkdown.generate/1` takes the same options as the mix task and writes the files:

```elixir
{:ok, files} = GraphqlMarkdown.generate(schema: "schema.json", output_dir: "guides", multi_page: true)
```

`GraphqlMarkdown.render/1` returns the markdown in memory instead, keyed by filename:

```elixir
{:ok, %{"graphql_schema.md" => markdown}} = GraphqlMarkdown.render(schema: "schema.json")
```

`GraphqlMarkdown.check/1` compares the rendered markdown with the files on disk
and reports the ones that are out of date:

```elixir
:ok = GraphqlMarkdown.check(schema: "schema.json", output_dir: "guides")
{:error, {:outdated, [{"guides/graphql_schema.md", :changed}]}} = GraphqlMarkdown.check(...)
```

## Documentation

Documentation is [available on Hexdocs](https://hexdocs.pm/graphql_markdown/)

## Contributing

1. [Fork it!](https://github.com/epinault/graphql_markdown/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Author

Emmanuel Pinault (@epinault)

## License

GraphqlMarkdown is released under the MIT License. See the [LICENSE.md](LICENSE.md) file for further details.
