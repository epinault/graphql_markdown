defmodule GraphqlMarkdown.ObjectDetailsTest do
  @moduledoc """
  Tests for the type details that used to be dropped from the markdown:
  deprecations, implemented interfaces, arguments on object fields and the
  implementers of an interface (issue #17).
  """
  use ExUnit.Case, async: true

  @fixture "test/fixtures/object_details_schema.json"

  setup do
    assert {:ok, %{"graphql_schema.md" => single}} = GraphqlMarkdown.render(schema: @fixture)
    assert {:ok, multi} = GraphqlMarkdown.render(schema: @fixture, multi_page: true)
    %{single: single, multi: multi}
  end

  describe "deprecations" do
    test "a deprecated object field is struck through with its reason in the description", %{
      single: single
    } do
      assert single =~
               "| ~~`primaryFunction`~~ ( [String](#string) ) | What the droid was built for. **Deprecated:** Droids no longer have a single function |"
    end

    test "a field that is not deprecated is rendered as before", %{single: single} do
      assert single =~ "| `homePlanet` ( [String](#string) ) | Where they were born |"
      refute single =~ "~~`homePlanet`~~"
    end

    test "a deprecated enum value is struck through with its reason", %{single: single} do
      assert single =~
               "| ~~CLONE_WARS~~ | An animated film. **Deprecated:** Not part of the original trilogy |"
    end

    test "a deprecated enum value without reason or description just says Deprecated", %{
      single: single
    } do
      assert single =~ "| ~~HOLIDAY_SPECIAL~~ | **Deprecated** |"
    end

    test "a deprecated operation gets a Deprecated paragraph under its type", %{single: single} do
      assert single =~
               "### oldHero\n\nType: [Character](#character)\n\n**Deprecated:** Use `hero` instead\n\nThe hero of the first episode\n"
    end

    test "multi page renders the same deprecation markers", %{multi: multi} do
      assert multi["objects.md"] =~ "| ~~`primaryFunction`~~ ( [String](scalars.html#string) ) |"
      assert multi["enums.md"] =~ "| ~~CLONE_WARS~~ |"
      assert multi["queries.md"] =~ "\n\n**Deprecated:** Use `hero` instead\n"
    end
  end

  describe "implemented interfaces" do
    test "an object lists the interfaces it implements under its description", %{single: single} do
      assert single =~
               "### Human\n\nA person.\n\nImplements: [Character](#character)\n\n| field |"
    end

    test "an object implementing nothing has no Implements line", %{single: single} do
      assert single =~ "### Starship\n\nA vessel. Implements nothing.\n\n| field |"
    end

    test "multi page links the interface to the interfaces page", %{multi: multi} do
      assert multi["objects.md"] =~
               "## Human\n\nA person.\n\nImplements: [Character](interfaces.html#character)\n"
    end
  end

  describe "arguments on object fields" do
    test "arguments are rendered inline with their type and default", %{single: single} do
      assert single =~
               "| `friends(first: Int = 10, after: String)` ( [\\[Character\\]](#character) ) | Friends of this character |"
    end

    test "a field without arguments keeps its bare name", %{single: single} do
      assert single =~ "| `homePlanet` ( [String](#string) ) |"
      refute single =~ "`homePlanet()`"
    end

    test "root operations still render their arguments as a table", %{single: single} do
      assert single =~ "### hero\n"
      assert single =~ "| `episode` ( [Episode](#episode) ) |"
      refute single =~ "### hero(episode"
    end

    test "multi page renders arguments the same way", %{multi: multi} do
      assert multi["objects.md"] =~
               "| `friends(first: Int = 10, after: String)` ( [\\[Character\\]](interfaces.html#character) ) |"
    end
  end
end
