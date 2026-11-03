defmodule GraphqlMarkdown.ReturnTypesTest do
  @moduledoc """
  Regression tests for the example operations generated for the different
  return-type shapes an introspection result can contain (issue #5).
  """
  use ExUnit.Case, async: true

  @fixture "test/fixtures/return_types_schema.json"

  setup do
    assert {:ok, %{"graphql_schema.md" => content}} =
             GraphqlMarkdown.render(schema: @fixture, no_toc: true)

    %{content: content}
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
                 name
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
                 name
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
                 id
                 name
                 owner {
                   name
                 }
               }
               ... on Human {
                 name
               }
             }
           }
           ```
           """
  end
end
