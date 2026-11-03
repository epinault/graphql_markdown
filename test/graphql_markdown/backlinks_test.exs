defmodule GraphqlMarkdown.BacklinksTest do
  @moduledoc """
  With `backlinks: true` every object, input, enum, interface and union
  entry ends with the operations that return it and the types and
  operations that use it in a field or argument (issue #21).
  """
  use ExUnit.Case, async: true

  @nested "test/fixtures/nested_operations_schema.json"

  defp single(fixture, options \\ []) do
    assert {:ok, %{"graphql_schema.md" => content}} =
             GraphqlMarkdown.render([schema: fixture, no_toc: true, backlinks: true] ++ options)

    content
  end

  test "nothing is added without the option" do
    assert {:ok, %{"graphql_schema.md" => content}} = GraphqlMarkdown.render(schema: @nested)

    refute content =~ "Returned by:"
    refute content =~ "Used by:"
  end

  test "an object lists the operations returning it and the types using it" do
    assert single(@nested) =~ """
           ### Starship

           | field | type | description |
           | ----- | ---- | ----------- |
           | `id` | [ID!](#id) |  |
           | `name` | [String](#string) |  |
           | `pilot` | [Human](#human) |  |

           Returned by:

             * [starship](#starship)

           Used by:

             * [Human](#human)


           """
  end

  test "a block is left out when it would be empty" do
    content = single(@nested)

    assert content =~
             "### Deep\n\n| field | type | description |\n| ----- | ---- | ----------- |\n| `value` | [String](#string) |  |\n\nUsed by:\n\n  * [Inner](#inner)\n\n\n"

    refute content =~
             "### Deep\n\n| field | type | description |\n| ----- | ---- | ----------- |\n| `value` | [String](#string) |  |\n\nReturned by:"
  end

  test "an interface is used by its implementers but not by itself" do
    assert single(@nested) =~ """
           Implemented by:

             * [Human](#human)
             * [Droid](#droid)

           Returned by:

             * [hero](#hero)

           Used by:

             * [Droid](#droid)
             * [Human](#human)


           """
  end

  test "a union lists the operations returning it" do
    assert single(@nested) =~ """
           Possible types:

             * [Human](#human)
             * [Droid](#droid)

           Returned by:

             * [search](#search)


           """
  end

  test "an enum used as an operation argument is used by that operation" do
    content = single("test/fixtures/object_details_schema.json")

    assert content =~
             "| ~~HOLIDAY_SPECIAL~~ | **Deprecated** |\n\nUsed by:\n\n  * [hero](#hero)\n"
  end

  test "an input lists the mutations taking it, and operations come before types" do
    content = single("test/fixtures/schema.json")

    assert content =~
             "### PasswordLoginInput\n\n" <>
               table_lines() <>
               "Used by:\n\n  * [passwordLogin](#passwordlogin)\n  * [passwordLoginV2](#passwordloginv2)\n"

    assert content =~
             "Returned by:\n\n  * [passwordLogin](#passwordlogin)\n  * [passwordlessLogin](#passwordlesslogin)\n  * [loginEvent](#loginevent)\n"

    assert content =~
             "Returned by:\n\n  * [userSsoDetails](#userssodetails)\n\nUsed by:\n\n  * [RefreshIdTokenResponse](#refreshidtokenresponse)\n"
  end

  defp table_lines do
    "| field | type | description |\n| ----- | ---- | ----------- |\n| `emailOrPhone` | [String!](#string) |  |\n| `password` | [String!](#string) |  |\n\n"
  end

  test "multi-page links follow the page layout and link extension" do
    assert {:ok, pages} =
             GraphqlMarkdown.render(
               schema: @nested,
               multi_page: true,
               backlinks: true,
               link_ext: :md
             )

    assert pages["objects.md"] =~
             "Returned by:\n\n  * [starship](queries.md#starship)\n\nUsed by:\n\n  * [Human](objects.md#human)\n"
  end

  test "scalars get no backlinks" do
    content = single(@nested)

    refute content =~ "### String\n\nUsed by:"
    assert content =~ "### String\n\n\n"
  end
end
