defmodule GraphqlMarkdown.NestedOperationsTest do
  @moduledoc """
  Example operations recurse into object, interface and union return types
  down to `:depth` levels, so that they are valid, copy-pasteable GraphQL
  (issue #16).
  """
  use ExUnit.Case, async: true

  @fixture "test/fixtures/nested_operations_schema.json"

  defp render(options \\ []) do
    assert {:ok, %{"graphql_schema.md" => content}} =
             GraphqlMarkdown.render([schema: @fixture, no_toc: true] ++ options)

    content
  end

  test "selects the leaves of nested objects down to the default depth of 2" do
    assert render() =~ """
           ```gql
           query Starship($id: ID!) {
             starship(id: $id) {
               id
               name
               pilot {
                 id
                 name
                 homePlanet
               }
             }
           }
           ```
           """
  end

  test "an interface selects __typename, its own fields and a fragment per implementer" do
    assert render() =~ """
           ```gql
           query Hero {
             hero {
               __typename
               id
               name
               ... on Human {
                 homePlanet
                 starship {
                   id
                   name
                 }
               }
               ... on Droid {
                 primaryFunction
               }
             }
           }
           ```
           """
  end

  test "a union selects __typename and the fields of every possible type" do
    assert render() =~ """
           ```gql
           query Search {
             search {
               __typename
               ... on Human {
                 id
                 name
                 friends {
                   __typename
                   id
                   name
                   ... on Droid {
                     primaryFunction
                   }
                 }
                 homePlanet
                 starship {
                   id
                   name
                 }
               }
               ... on Droid {
                 id
                 name
                 friends {
                   __typename
                   id
                   name
                   ... on Human {
                     homePlanet
                   }
                 }
                 primaryFunction
               }
             }
           }
           ```
           """
  end

  test "a field or fragment whose type is already on the path is skipped to break cycles" do
    content = render(depth: 4)

    # Character.friends is [Character], so hero never recurses into friends
    # and the block is the same as at depth 2.
    assert content =~ """
           query Hero {
             hero {
               __typename
               id
               name
               ... on Human {
                 homePlanet
                 starship {
                   id
                   name
                 }
               }
               ... on Droid {
                 primaryFunction
               }
             }
           }
           """

    # Starship.pilot is a Human whose starship is skipped (Starship is on the
    # path) and whose friends get no `... on Human` fragment (Human is too).
    assert content =~ """
           query Starship($id: ID!) {
             starship(id: $id) {
               id
               name
               pilot {
                 id
                 name
                 friends {
                   __typename
                   id
                   name
                   ... on Droid {
                     primaryFunction
                   }
                 }
                 homePlanet
               }
             }
           }
           """
  end

  test "depth 1 keeps only leaf fields and falls back to __typename when there are none" do
    content = render(depth: 1)

    assert content =~ """
           query Starship($id: ID!) {
             starship(id: $id) {
               id
               name
             }
           }
           """

    assert content =~ """
           query Wrapper {
             wrapper {
               __typename
             }
           }
           """
  end

  test "a deeper depth expands one more level of nested objects" do
    assert render(depth: 2) =~ """
           query Wrapper {
             wrapper {
               inner {
                 value
               }
             }
           }
           """

    assert render(depth: 3) =~ """
           query Wrapper {
             wrapper {
               inner {
                 value
                 deep {
                   value
                 }
               }
             }
           }
           """
  end

  test "rejects a depth that is not a positive integer" do
    assert GraphqlMarkdown.render(schema: @fixture, depth: 0) == {:error, {:invalid_depth, 0}}
    assert GraphqlMarkdown.render(schema: @fixture, depth: "2") == {:error, {:invalid_depth, "2"}}
  end
end
