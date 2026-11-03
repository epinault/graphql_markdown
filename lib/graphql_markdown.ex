defmodule GraphqlMarkdown do
  @moduledoc """
  Converts a GraphQL JSON schema to a markdown format
  """
  alias GraphqlMarkdown.MultiPage
  alias GraphqlMarkdown.Schema
  alias GraphqlMarkdown.SinglePage

  @typedoc "Rendered pages, keyed by filename (for example `\"graphql_schema.md\"`)."
  @type pages :: %{String.t() => String.t()}

  @type error ::
          :missing_schema
          | :invalid_schema
          | :absinthe_not_available
          | {:not_a_schema, module()}
          | {:introspection_failed, term()}
          | File.posix()
          | Jason.DecodeError.t()

  @doc """
  Renders the markdown in memory and returns it keyed by filename.

  Nothing is written to disk. Use this to embed the generator in your own
  pipeline or to inspect the output in tests.

  Accepts the same options as `generate/1` except `:output_dir`.

  ## Options

  The schema comes from exactly one of:

    * `:schema` - path to an introspection JSON file, as written by
      `mix absinthe.schema.json` or any GraphQL tooling
    * `:schema_module` - an Absinthe schema module, introspected in-process.
      Requires `absinthe` in your dependencies

  Rendering options:

    * `:multi_page` - one file per section instead of a single page
    * `:title` - title of the single page. Default: `"Graphql Schema"`
    * `:no_toc` - leave the table of contents out of the single page
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
    case {options[:schema], options[:schema_module]} do
      {nil, nil} -> {:error, :missing_schema}
      {path, nil} -> read_json(path)
      {_path, module} -> introspect(module)
    end
  end

  defp read_json(path) do
    with {:ok, body} <- File.read(path) do
      Jason.decode(body)
    end
  end

  # Absinthe is an optional dependency, so it is called through apply/3:
  # consumers without it compile without an undefined-function warning and
  # get a clear error instead of an UndefinedFunctionError.
  defp introspect(module) do
    cond do
      not absinthe_available?() ->
        {:error, :absinthe_not_available}

      not absinthe_schema?(module) ->
        {:error, {:not_a_schema, module}}

      true ->
        # credo:disable-for-next-line Credo.Check.Refactor.Apply
        case apply(Absinthe.Schema, :introspect, [module]) do
          {:ok, %{data: data}} -> {:ok, %{"data" => data}}
          other -> {:error, {:introspection_failed, other}}
        end
    end
  end

  defp absinthe_available? do
    Code.ensure_loaded?(Absinthe.Schema) and function_exported?(Absinthe.Schema, :introspect, 1)
  end

  defp absinthe_schema?(module) do
    Code.ensure_loaded?(module) and function_exported?(module, :__absinthe_types__, 0)
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
