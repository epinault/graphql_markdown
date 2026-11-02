defmodule GraphqlMarkdown.ReturnTypesTest do
  @moduledoc """
  Regression tests for the example operations generated for the different
  return-type shapes an introspection result can contain (issue #5).
  """
  use ExUnit.Case, async: false

  @fixture "test/fixtures/return_types_schema.json"

  setup do
    File.mkdir_p!("guides")

    assert {:ok, ["guides/graphql_schema.md"]} =
             GraphqlMarkdown.generate(schema: @fixture, output_dir: "guides", no_toc: true)

    %{content: File.read!("guides/graphql_schema.md")}
  end

  test "non-null list of non-null objects ([Droid!]!) selects the object's fields", %{
    content: content
  } do
    assert content =~ """
           ```gql
           query Droids {
             droids {
               id
               name
               owner {
               }
             }
           }
           ```
           """
  end

  test "non-null object (Droid!) selects the object's fields", %{content: content} do
    assert content =~ """
           ```gql
           query Droid($id: ID!) {
             droid(id: $id) {
               id
               name
               owner {
               }
             }
           }
           ```
           """
  end

  test "nullable list of non-null objects ([Droid!]) selects the object's fields", %{
    content: content
  } do
    assert content =~ """
           query MaybeDroids {
             maybeDroids {
               id
           """
  end

  test "scalar return type has no selection set", %{content: content} do
    assert content =~ """
           ```gql
           query Count {
             count
           }
           ```
           """
  end

  test "non-null scalar return type has no selection set", %{content: content} do
    assert content =~ """
           ```gql
           query RequiredCount {
             requiredCount
           }
           ```
           """
  end

  test "non-null enum return type has no selection set", %{content: content} do
    assert content =~ """
           ```gql
           query Status {
             status
           }
           ```
           """
  end

  test "non-null list of unions selects __typename and possible types", %{content: content} do
    assert content =~ """
           ```gql
           query SearchResults {
             searchResults {
               __typename
               ... on Droid {
               }
               ... on Human {
               }
             }
           }
           ```
           """
  end
end
