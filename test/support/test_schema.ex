defmodule GraphqlMarkdown.TestSchema do
  @moduledoc false
  # A small Absinthe schema used to exercise `schema_module:` introspection.
  use Absinthe.Schema

  enum :episode do
    value(:newhope, description: "Released in 1977")
    value(:empire)
  end

  object :droid do
    description("An autonomous mechanical character.")
    field(:id, non_null(:id))
    field(:name, :string, description: "Full name")
    field(:appears_in, list_of(:episode))
  end

  query do
    field :droid, :droid do
      description("Look up a droid")
      arg(:id, non_null(:id))
      resolve(fn _, _ -> {:ok, nil} end)
    end
  end
end
