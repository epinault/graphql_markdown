defmodule GraphqlMarkdown do
  @moduledoc """
  Converts a GraphQL JSON schema to a markdown format
  """
  alias GraphqlMarkdown.MultiPage
  alias GraphqlMarkdown.Schema
  alias GraphqlMarkdown.SinglePage

  @typedoc "Rendered pages, keyed by filename (for example `\"graphql_schema.md\"`)."
  @type pages :: %{String.t() => String.t()}

  @type error :: :invalid_schema | File.posix() | Jason.DecodeError.t()

  @doc """
  Renders the markdown in memory and returns it keyed by filename.

  Nothing is written to disk. Use this to embed the generator in your own
  pipeline or to inspect the output in tests.

  Accepts the same options as `generate/1` except `:output_dir`.
  """
  @spec render(keyword()) :: {:ok, pages()} | {:error, error()}
  def render(options) do
    with {:ok, json} <- load_json(options),
         {:ok, schema} <- Schema.schema_from_json(json) do
      {:ok, schema |> render_schema(options) |> Map.new()}
    end
  end

  @doc """
  Renders the markdown and writes it into `:output_dir` (default: the
  current directory). Returns the list of files written.

  Files are written only after every page has been rendered, so a failure
  never leaves a partially written file behind.
  """
  @spec generate(keyword()) :: {:ok, [Path.t()]} | {:error, error()}
  def generate(options) do
    with {:ok, json} <- load_json(options),
         {:ok, schema} <- Schema.schema_from_json(json) do
      output_dir = Keyword.get(options, :output_dir, ".")

      paths =
        schema
        |> render_schema(options)
        |> Enum.map(fn {filename, content} ->
          path = Path.join(output_dir, filename)
          File.write!(path, content)
          path
        end)

      {:ok, paths}
    end
  end

  defp load_json(options) do
    with {:ok, body} <- File.read(options[:schema]) do
      Jason.decode(body)
    end
  end

  defp render_schema(schema, options) do
    query_type_name = Schema.query_type(schema)
    mutation_type_name = Schema.mutation_type(schema)
    subscription_type_name = Schema.subscription_type(schema)
    types = Schema.types(schema)

    root_type_names = [query_type_name, mutation_type_name, subscription_type_name]

    filtered_types = Enum.reject(types, fn type -> type["name"] in root_type_names end)

    schema_details = %Schema{
      mutations: List.first(Schema.find_and_sort_type(types, "name", mutation_type_name)),
      queries: List.first(Schema.find_and_sort_type(types, "name", query_type_name)),
      subscriptions: List.first(Schema.find_and_sort_type(types, "name", subscription_type_name)),
      inputs: Schema.find_and_sort_type(filtered_types, "kind", Schema.input_kind()),
      objects: Schema.find_and_sort_type(filtered_types, "kind", Schema.object_kind()),
      scalars: Schema.find_and_sort_type(filtered_types, "kind", Schema.scalar_kind()),
      enums: Schema.find_and_sort_type(filtered_types, "kind", Schema.enum_kind()),
      interfaces: Schema.find_and_sort_type(filtered_types, "kind", Schema.interface_kind()),
      unions: Schema.find_and_sort_type(filtered_types, "kind", Schema.union_kind())
    }

    generate_strategy(options[:multi_page]).render_schema(schema_details, options)
  end

  defp generate_strategy(true), do: MultiPage
  defp generate_strategy(_), do: SinglePage
end
