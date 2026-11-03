defmodule GraphqlMarkdown.MarkdownHelpers do
  @moduledoc """
  A set of helpers to generate proper markdown easily
  """
  alias GraphqlMarkdown.OperationDetailsHelpers

  @spec header(String.t(), non_neg_integer(), boolean()) :: String.t()
  def header(text, level, capitalize \\ false)

  def header(text, level, true) do
    header(capitalize_first(text), level, false)
  end

  def header(text, level, _capitalize) do
    "#{String.duplicate("#", level)} #{text}"
  end

  @spec list(String.t(), non_neg_integer(), boolean()) :: String.t()
  def list(text, level, capitalize \\ false)

  def list(text, level, true) do
    list(capitalize_first(text), level, false)
  end

  def list(text, level, _capitalize) do
    "#{String.duplicate(" ", level * 2)}* #{text}"
  end

  # Unlike String.capitalize/1 this leaves the rest of the string untouched,
  # so acronyms and camelCase names keep their casing.
  @spec capitalize_first(String.t()) :: String.t()
  def capitalize_first(""), do: ""

  def capitalize_first(text) do
    {first, rest} = String.split_at(text, 1)
    String.upcase(first) <> rest
  end

  @spec anchor(String.t(), String.t() | nil) :: String.t()
  def anchor(text, anchor_text \\ nil) do
    case anchor_text do
      nil ->
        link(text)

      _ ->
        link(text, "##{String.downcase(anchor_text)}")
    end
  end

  @spec link(String.t(), String.t() | nil) :: String.t()
  def link(text, url \\ nil) do
    case url do
      nil ->
        "[#{text}](##{String.downcase(text)})"

      _ ->
        "[#{text}](#{url})"
    end
  end

  @spec default_value(any()) :: String.t()
  def default_value(nil), do: ""

  def default_value(defaultValue) do
    "The default value is `#{defaultValue}`"
  end

  @doc """
  Builds the description cell for a field or argument, appending the default
  value sentence when there is one.
  """
  @spec field_description(String.t() | nil, any()) :: String.t()
  def field_description(description, default) do
    sentences([description, default_value(default)])
  end

  @doc """
  Joins sentence fragments with a period and a space. Empty and `nil`
  fragments are skipped, and a fragment that already ends with a period is
  not given a second one.
  """
  @spec sentences([String.t() | nil]) :: String.t()
  def sentences(parts) do
    case Enum.reject(parts, &(&1 in [nil, ""])) do
      [] ->
        ""

      parts ->
        {leading, [last]} = Enum.split(parts, -1)
        Enum.map_join(leading, "", &(String.trim_trailing(&1, ".") <> ". ")) <> last
    end
  end

  @doc """
  The deprecation notice for a field, argument or enum value, or an empty
  string when it is not deprecated.
  """
  @spec deprecation(map()) :: String.t()
  def deprecation(%{"isDeprecated" => true, "deprecationReason" => reason})
      when is_binary(reason) and reason != "" do
    "**Deprecated:** " <> reason
  end

  def deprecation(%{"isDeprecated" => true}), do: "**Deprecated**"
  def deprecation(_), do: ""

  @doc """
  Joins a (possibly nested) list of lines into a document.

  Every line is terminated by a newline; an empty string produces a blank
  line. Nested lists are flattened, so builders can return lists of lines
  freely, and `nil` entries are skipped.
  """
  @spec document([String.t() | nil | list()]) :: String.t()
  def document(lines) do
    lines
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.map_join(&(&1 <> new_line()))
  end

  @spec code(String.t()) :: String.t()
  def code(text), do: "`#{text}`"

  @spec new_line() :: String.t()
  def new_line do
    "\n"
  end

  @spec table(list(), list()) :: String.t()
  def table(fields, rows) do
    headers =
      Enum.join(
        [
          "| " <> Enum.map_join(fields, " | ", fn {name, _} -> name end) <> " |",
          "| " <>
            Enum.map_join(fields, " | ", fn {name, _} ->
              length =
                name
                |> Atom.to_string()
                |> String.length()

              String.duplicate("-", length)
            end) <> " |"
        ],
        new_line()
      )

    data =
      Enum.map_join(rows, new_line(), fn row ->
        "| " <> Enum.map_join(row, " | ", &escape_cell/1) <> " |"
      end)

    headers <> new_line() <> data
  end

  @doc """
  Makes a value safe to place inside a markdown table cell: pipes are
  escaped so they do not start a new column, and line breaks become `<br>`
  so the row is not split.
  """
  @spec escape_cell(String.t() | nil) :: String.t()
  def escape_cell(nil), do: ""

  def escape_cell(text) when is_binary(text) do
    text
    |> String.replace("|", "\\|")
    |> String.replace(~r/\r?\n/, "<br>")
  end

  def escape_cell(other), do: other |> to_string() |> escape_cell()

  @doc """
  Generates a code block for a GraphQL operation from the details built by
  `GraphqlMarkdown.OperationDetailsHelpers.generate_operation_details/4`.

  Example:
    ```gql
    mutation RefreshIdToken($refreshToken: String!) {
      refreshIdToken(refreshToken: $refreshToken) {
        idToken
        userSsoDetails {
          domain
          ssoEnabled
        }
      }
    }
    ```
  """
  @spec graphql_operation_code_block(OperationDetailsHelpers.graphql_operation_details()) ::
          String.t()
  def graphql_operation_code_block(operation_details) do
    %{
      operation_name: operation_name,
      operation_type: operation_type,
      arguments: args,
      selections: selections
    } =
      operation_details

    capitalized_operation_name = capitalize_operation_name(operation_name)

    arguments_types = argument_types_string(args)
    arguments = operation_arguments_string(args)

    """
    ```gql
    #{operation_type} #{capitalized_operation_name}#{arguments_types} {
      #{operation_name}#{arguments}#{selection_set(selections, 2)}
    }
    ```
    """
  end

  # Leaves have no selection set; a composite type gets its selections on
  # their own lines, indented two spaces deeper than the parent.
  @spec selection_set([OperationDetailsHelpers.selection()], non_neg_integer()) :: String.t()
  defp selection_set([], _indent), do: ""

  defp selection_set(selections, indent) do
    body = Enum.map_join(selections, "\n", &selection(&1, indent + 2))
    " {\n" <> body <> "\n" <> String.duplicate(" ", indent) <> "}"
  end

  defp selection(%{on: type_name, selections: selections}, indent) do
    String.duplicate(" ", indent) <> "... on " <> type_name <> selection_set(selections, indent)
  end

  defp selection(%{name: name, selections: selections}, indent) do
    String.duplicate(" ", indent) <> name <> selection_set(selections, indent)
  end

  @spec capitalize_operation_name(String.t()) :: String.t()
  defp capitalize_operation_name(operation_name) do
    <<first_grapheme::utf8, rest::binary>> = operation_name
    String.capitalize(<<first_grapheme::utf8>>) <> rest
  end

  @spec argument_types_string([OperationDetailsHelpers.argument()]) :: String.t()
  defp argument_types_string([]), do: ""

  defp argument_types_string(args) do
    arg_types =
      Enum.map_join(args, ", ", fn arg ->
        arg_type = arg.type
        arg_name = arg.name

        type_suffix =
          if arg.required, do: "!", else: ""

        "$#{arg_name}: #{arg_type}#{type_suffix}"
      end)

    "(#{arg_types})"
  end

  @spec operation_arguments_string([OperationDetailsHelpers.argument()]) :: String.t()
  defp operation_arguments_string([]), do: ""

  defp operation_arguments_string(args) do
    arguments_string =
      Enum.map_join(args, ", ", fn arg ->
        "#{arg.name}: $#{arg.name}"
      end)

    "(#{arguments_string})"
  end
end
