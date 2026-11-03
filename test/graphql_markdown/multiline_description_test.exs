defmodule GraphqlMarkdown.MultilineDescriptionTest do
  @moduledoc """
  Regression tests for descriptions containing newlines or pipes, which
  used to break the generated markdown tables (issue #8).
  """
  use ExUnit.Case, async: true

  @fixture "test/fixtures/multiline_description_schema.json"

  test "argument, field and enum descriptions stay on one table row" do
    assert {:ok, %{"graphql_schema.md" => content}} = GraphqlMarkdown.render(schema: @fixture)

    assert content =~
             "| `uid` | [ID!](#id) | Invoice UID<br>required when job_uid \\| job_id are absent |"

    assert content =~
             "| `total` | [Int](#int) | Total in cents.<br><br>Always positive \\| never zero |"

    assert content =~ "| PAID | Paid<br>in full \\| or partially |"
  end

  test "multi-page output escapes the same way" do
    assert {:ok, pages} = GraphqlMarkdown.render(schema: @fixture, multi_page: true)

    assert pages["objects.md"] =~
             "| `total` | [Int](scalars.html#int) | Total in cents.<br><br>Always positive \\| never zero |"
  end
end
