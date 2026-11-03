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
end
