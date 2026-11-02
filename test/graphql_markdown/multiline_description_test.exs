defmodule GraphqlMarkdown.MultilineDescriptionTest do
  @moduledoc """
  Regression tests for descriptions containing newlines or pipes, which
  used to break the generated markdown tables (issue #8).
  """
  use ExUnit.Case, async: false

  @fixture "test/fixtures/multiline_description_schema.json"

  setup do
    File.mkdir_p!("guides")
    :ok
  end

  test "argument, field and enum descriptions stay on one table row" do
    assert {:ok, _} = GraphqlMarkdown.generate(schema: @fixture, output_dir: "guides")
    content = File.read!("guides/graphql_schema.md")

    assert content =~
             "| `uid` ( [ID!](#id) ) | Invoice UID<br>required when job_uid \\| job_id are absent |"

    assert content =~
             "| `total` ( [Int](#int) ) | Total in cents.<br><br>Always positive \\| never zero |"

    assert content =~ "| PAID | Paid<br>in full \\| or partially |"
  end

  test "multi-page output escapes the same way" do
    assert {:ok, _} =
             GraphqlMarkdown.generate(schema: @fixture, output_dir: "guides", multi_page: true)

    assert File.read!("guides/objects.md") =~
             "| `total` ( [Int](scalars.html#int) ) | Total in cents.<br><br>Always positive \\| never zero |"
  end
end
