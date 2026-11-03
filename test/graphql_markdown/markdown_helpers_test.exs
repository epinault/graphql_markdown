defmodule GraphqlMarkdown.MarkdownHelpersTest do
  use ExUnit.Case, async: false
  alias GraphqlMarkdown.MarkdownHelpers
  doctest GraphqlMarkdown

  describe "#header" do
    test "it capitalizes only the first letter of the header" do
      assert MarkdownHelpers.header("some Header that NeEd capitalizing", 1, true) ==
               "# Some Header that NeEd capitalizing"
    end

    test "it leaves acronyms in a capitalized header untouched" do
      assert MarkdownHelpers.header("my API docs", 1, true) == "# My API docs"
    end

    test "it support different levels the header" do
      assert MarkdownHelpers.header("some Header that NeEd capitalizing", 3, false) ==
               "### some Header that NeEd capitalizing"
    end

    test "it default to not capitalizing a heading" do
      assert MarkdownHelpers.header("some Header that NeEd capitalizing", 1) ==
               "# some Header that NeEd capitalizing"
    end
  end

  describe "#list" do
    test "it capitalizes only the first letter of the list item" do
      assert MarkdownHelpers.list("some Header that NeEd capitalizing", 1, true) ==
               "  * Some Header that NeEd capitalizing"
    end

    test "it support different levels the list" do
      assert MarkdownHelpers.list("some Header that NeEd capitalizing", 2, false) ==
               "    * some Header that NeEd capitalizing"
    end

    test "it default to not capitalizing a list" do
      assert MarkdownHelpers.list("some Header that NeEd capitalizing", 1) ==
               "  * some Header that NeEd capitalizing"
    end
  end

  describe "#anchor" do
    test "it creates an anchor (link)" do
      assert MarkdownHelpers.anchor("Some Class") ==
               "[Some Class](#some class)"
    end

    test "it creates an anchor with different link than text" do
      assert MarkdownHelpers.anchor("Some Class", "Some Link") ==
               "[Some Class](#some link)"
    end
  end

  describe "#link" do
    test "it create a link for the text and url specified" do
      assert MarkdownHelpers.link("some text", "http://localhost") ==
               "[some text](http://localhost)"
    end

    test "it creates an anchor link if no url specified" do
      assert MarkdownHelpers.link("Some Class") ==
               "[Some Class](#some class)"
    end
  end

  describe "#table" do
    test "Generate a table with field and no data" do
      assert MarkdownHelpers.table([name: %{}, Description: %{}], []) ==
               "| name | Description |\n| ---- | ----------- |\n"
    end

    test "Generate a table with field and data" do
      assert MarkdownHelpers.table([name: %{}, Description: %{}], [
               ["toto", "some description"],
               ["titi", "another description"]
             ]) ==
               "| name | Description |\n| ---- | ----------- |\n| toto | some description |\n| titi | another description |"
    end

    test "escapes pipes inside cells so they do not add columns" do
      assert MarkdownHelpers.table([name: %{}, Description: %{}], [["a", "x | y"]]) ==
               "| name | Description |\n| ---- | ----------- |\n| a | x \\| y |"
    end

    test "replaces newlines inside cells with <br> so rows stay intact" do
      assert MarkdownHelpers.table([name: %{}, Description: %{}], [
               ["a", "Line one\nLine two\r\nLine three"]
             ]) ==
               "| name | Description |\n| ---- | ----------- |\n| a | Line one<br>Line two<br>Line three |"
    end

    test "renders nil cells as empty" do
      assert MarkdownHelpers.table([name: %{}, Description: %{}], [["a", nil]]) ==
               "| name | Description |\n| ---- | ----------- |\n| a |  |"
    end
  end

  describe "#graphql_operation_code_block" do
    test "creates a GQL text block for the operation" do
      operation_details = %{
        arguments: [%{name: "emailOrPhone", required: true, type: "String"}],
        operation_name: "generateLoginCode",
        operation_type: "mutation",
        return_type: %{
          kind: "OBJECT",
          name: "GenerateLoginCodeResponse",
          fields: [
            %{name: "processed", type: "SCALAR"}
          ]
        }
      }

      expected_text =
        """
        ```gql
        mutation GenerateLoginCode($emailOrPhone: String!) {
          generateLoginCode(emailOrPhone: $emailOrPhone) {
            processed
          }
        }
        ```
        """

      assert MarkdownHelpers.graphql_operation_code_block(operation_details) == expected_text
    end

    test "returns comma-separated arguments and types when there is more than one argument" do
      operation_details = %{
        arguments: [
          %{name: "username", required: true, type: "String"},
          %{name: "password", required: true, type: "String"}
        ],
        operation_name: "login",
        operation_type: "mutation",
        return_type: %{
          kind: "OBJECT",
          name: "LoginResponse",
          fields: [
            %{name: "idToken", type: "SCALAR"},
            %{name: "refreshToken", type: "SCALAR"}
          ]
        }
      }

      expected_text =
        """
        ```gql
        mutation Login($username: String!, $password: String!) {
          login(username: $username, password: $password) {
            idToken
            refreshToken
          }
        }
        ```
        """

      assert MarkdownHelpers.graphql_operation_code_block(operation_details) == expected_text
    end

    test "returns an empty object for an object return type" do
      operation_details = %{
        arguments: [
          %{name: "refreshToken", required: true, type: "String"}
        ],
        operation_name: "refreshIdToken",
        operation_type: "mutation",
        return_type: %{
          kind: "OBJECT",
          name: "RefreshIdTokenResponse",
          fields: [
            %{name: "idToken", type: "SCALAR"},
            %{name: "userSsoDetails", type: "OBJECT"}
          ]
        }
      }

      expected_text =
        """
        ```gql
        mutation RefreshIdToken($refreshToken: String!) {
          refreshIdToken(refreshToken: $refreshToken) {
            idToken
            userSsoDetails {
            }
          }
        }
        ```
        """

      assert MarkdownHelpers.graphql_operation_code_block(operation_details) == expected_text
    end

    test "does not include argument parentheses when there are no arguments" do
      operation_details = %{
        arguments: [],
        operation_name: "currentTime",
        operation_type: "query",
        return_type: %{
          kind: "SCALAR",
          name: "String"
        }
      }

      expected_text =
        """
        ```gql
        query CurrentTime {
          currentTime
        }
        ```
        """

      assert MarkdownHelpers.graphql_operation_code_block(operation_details) == expected_text
    end

    test "does not include return fields when the return type is scalar" do
      operation_details = %{
        arguments: [],
        operation_name: "currentTime",
        operation_type: "query",
        return_type: %{
          kind: "SCALAR",
          name: "String"
        }
      }

      expected_text =
        """
        ```gql
        query CurrentTime {
          currentTime
        }
        ```
        """

      assert MarkdownHelpers.graphql_operation_code_block(operation_details) == expected_text
    end

    test "does not include return fields when the return type is an enum" do
      operation_details = %{
        arguments: [%{name: "code", required: true, type: "String"}],
        operation_name: "authenticateWithCode",
        operation_type: "mutation",
        return_type: %{
          kind: "ENUM",
          name: "AuthenticationResult",
          fields: []
        }
      }

      expected_text =
        """
        ```gql
        mutation AuthenticateWithCode($code: String!) {
          authenticateWithCode(code: $code)
        }
        ```
        """

      assert MarkdownHelpers.graphql_operation_code_block(operation_details) == expected_text
    end

    test "handles NON_NULL return type by unwrapping to the inner type" do
      operation_details = %{
        arguments: [],
        operation_name: "requiredField",
        operation_type: "query",
        return_type: %{
          kind: "NON_NULL",
          name: nil,
          ofType: %{
            kind: "OBJECT",
            name: "RequiredResponse",
            fields: [
              %{name: "isRequired", type: "SCALAR"},
              %{name: "metadata", type: "SCALAR"}
            ]
          }
        }
      }

      expected_text =
        """
        ```gql
        query RequiredField {
          requiredField {
            isRequired
            metadata
          }
        }
        ```
        """

      assert MarkdownHelpers.graphql_operation_code_block(operation_details) == expected_text
    end

    test "handles NON_NULL return type without ofType field" do
      operation_details = %{
        arguments: [],
        operation_name: "emptyRequired",
        operation_type: "query",
        return_type: %{
          kind: "NON_NULL",
          name: "String"
        }
      }

      expected_text =
        """
        ```gql
        query EmptyRequired {
          emptyRequired
        }
        ```
        """

      assert MarkdownHelpers.graphql_operation_code_block(operation_details) == expected_text
    end
  end

  describe "#default_value" do
    test "return nothing when no default value is found as code" do
      assert MarkdownHelpers.default_value(nil) == ""
    end

    test "return the default value as code" do
      assert MarkdownHelpers.default_value("some text") == "The default value is `some text`"
    end
  end

  describe "#field_description" do
    test "returns an empty string when there is no description and no default" do
      assert MarkdownHelpers.field_description(nil, nil) == ""
    end

    test "returns only the description when there is no default" do
      assert MarkdownHelpers.field_description("Page size", nil) == "Page size"
    end

    test "returns only the default sentence when there is no description" do
      assert MarkdownHelpers.field_description(nil, "20") == "The default value is `20`"
    end

    test "separates description and default with a period and a space" do
      assert MarkdownHelpers.field_description("Page size", "20") ==
               "Page size. The default value is `20`"
    end

    test "does not double the period when the description already ends with one" do
      assert MarkdownHelpers.field_description("Page size.", "20") ==
               "Page size. The default value is `20`"
    end
  end

  describe "#sentences" do
    test "returns an empty string for no parts" do
      assert MarkdownHelpers.sentences([]) == ""
      assert MarkdownHelpers.sentences([nil, ""]) == ""
    end

    test "returns a single part untouched" do
      assert MarkdownHelpers.sentences([nil, "Page size.", ""]) == "Page size."
    end

    test "joins parts with a period and a space without doubling periods" do
      assert MarkdownHelpers.sentences(["Page size.", "Default is 20", "Deprecated"]) ==
               "Page size. Default is 20. Deprecated"
    end
  end

  describe "#deprecation" do
    test "is empty for a field that is not deprecated" do
      assert MarkdownHelpers.deprecation(%{"isDeprecated" => false, "deprecationReason" => nil}) ==
               ""

      assert MarkdownHelpers.deprecation(%{"name" => "arg"}) == ""
    end

    test "includes the reason when there is one" do
      assert MarkdownHelpers.deprecation(%{
               "isDeprecated" => true,
               "deprecationReason" => "Use x"
             }) ==
               "**Deprecated:** Use x"
    end

    test "is just Deprecated when the reason is missing or blank" do
      assert MarkdownHelpers.deprecation(%{"isDeprecated" => true, "deprecationReason" => nil}) ==
               "**Deprecated**"

      assert MarkdownHelpers.deprecation(%{"isDeprecated" => true, "deprecationReason" => ""}) ==
               "**Deprecated**"
    end
  end

  describe "#code" do
    test "display as code" do
      assert MarkdownHelpers.code("some text") == "`some text`"
    end
  end
end
