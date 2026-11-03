# Changelog

## Unreleased

### Added

* `--schema-module` / `-s` on `mix graphql_gen_markdown`, and `schema_module:` on `GraphqlMarkdown.generate/1` and `render/1`, introspect an Absinthe schema in-process instead of requiring an introspection JSON file. Absinthe is an optional dependency ([#15](https://github.com/epinault/graphql_markdown/issues/15))

* Example operations recurse into object, interface and union return types and select their scalar and enum fields, so they are valid, copy-pasteable GraphQL. `--depth` / `-d` on the mix task and `depth:` on `generate/1` and `render/1` control how deep (default 2). Types already selected further up the path are skipped, which keeps recursive types such as `friends: [Character]` finite ([#16](https://github.com/epinault/graphql_markdown/issues/16))
* `--check` on `mix graphql_gen_markdown`, and `GraphqlMarkdown.check/1`, compare the rendered markdown with the files in the output directory without writing, and fail listing the changed or missing files. Use it in CI to keep committed docs in sync with the schema ([#19](https://github.com/epinault/graphql_markdown/issues/19))

* Multi-page output now includes an `index.md` with the title and a table of contents linking to every page and type, mirroring the single-page TOC. `-t` applies to it ([#20](https://github.com/epinault/graphql_markdown/issues/20))
* `mix graphql_gen_markdown -o -` writes the single page to stdout so it can be piped. It is rejected with `-m` and `--check` ([#20](https://github.com/epinault/graphql_markdown/issues/20))

* `--link-ext html|md|none` (`link_ext:` in the library) sets the extension of multi-page links, so the output works on GitHub, MkDocs, Docusaurus or Hugo and not only ExDoc. `html` stays the default ([#18](https://github.com/epinault/graphql_markdown/issues/18))
* `--front-matter` (`front_matter: true`) starts every page with a YAML block holding its `title` ([#18](https://github.com/epinault/graphql_markdown/issues/18))

* `--backlinks` (`backlinks: true`) ends every object, input, enum, interface and union with `Returned by` (operations whose return type is this type) and `Used by` (types and operations referencing it in a field or argument) lists ([#21](https://github.com/epinault/graphql_markdown/issues/21))

### Changed

* Field and argument tables have separate `field` (or `argument`), `type` and `description` columns instead of `` `name` ( [Type](#type) ) `` in one cell ([#21](https://github.com/epinault/graphql_markdown/issues/21))
* Union and interface entries end with a blank line like the other entries do
* `generate/1` and `render/1` return `{:error, :missing_schema}` instead of crashing when neither `:schema` nor `:schema_module` is given
* Example operations no longer contain empty selection sets (`owner {\n}` or `... on Human {\n}`), which were invalid GraphQL. A nested field with nothing selectable within the depth is left out, and an operation with nothing selectable asks for `__typename`. Interfaces now also select `__typename`, like unions already did
* `GraphqlMarkdown.OperationDetailsHelpers.generate_operation_details/4` returns the selection set as a tree under `selections`; `return_type` only holds the unwrapped `name` and `kind`
* Minimum Elixir version is now 1.16

## 1.1.0 - 2026-11-03

### Added

* `GraphqlMarkdown.render/1` renders the markdown in memory and returns it keyed by filename, without writing to disk
* Deprecated fields and enum values are struck through and their reason is appended to the description; a deprecated operation gets a `Deprecated` paragraph ([#17](https://github.com/epinault/graphql_markdown/issues/17))
* Objects list the interfaces they implement (`Implements: [Character](#character)`) and interfaces list their implementers under `Implemented by:` ([#17](https://github.com/epinault/graphql_markdown/issues/17))
* Arguments of object and interface fields are rendered inline in SDL syntax, for example `friends(first: Int = 10, after: String)` ([#17](https://github.com/epinault/graphql_markdown/issues/17))

### Changed

* Pages are rendered fully in memory and written once. `generate/1` can run concurrently in the same VM, and a failure no longer leaves a partially written file behind
* Minimum Elixir version is now 1.15 (it was declared as 1.14, which `mix.exs` already relied on being newer than). CI tests 1.17 to 1.20 ([#14](https://github.com/epinault/graphql_markdown/issues/14))
* Single-page and multi-page output share one renderer (`GraphqlMarkdown.Page`). Multi-page files are now returned in the same order as the single-page sections, with `subscriptions.md` after `mutations.md`

### Removed

* `GraphqlMarkdown.Renderer`. It was an internal GenServer used to stream lines to disk and was never part of the documented API

### Fixed

* Single-page generation crashed on schemas with a subscription root type ([#3](https://github.com/epinault/graphql_markdown/issues/3))
* Subscriptions were missing from single-page output and the subscription root type was listed under Objects ([#4](https://github.com/epinault/graphql_markdown/issues/4))
* Example operations were invalid GraphQL for scalar, enum, `Type!`, `[Type!]` and `[Type!]!` return types; scalars and enums no longer get an empty selection set ([#5](https://github.com/epinault/graphql_markdown/issues/5))
* `mix graphql_gen_markdown` exited 0 silently on a missing, invalid or non-introspection schema file, and crashed when `-f` was omitted. It now fails with a readable message and prints the generated files on success ([#6](https://github.com/epinault/graphql_markdown/issues/6))
* Titles and table-of-contents entries were lowercased after the first letter (`My API Docs` became `My api docs`, `userSsoDetails` became `Userssodetails`) ([#7](https://github.com/epinault/graphql_markdown/issues/7))
* Descriptions containing newlines or `|` broke markdown tables; cells are now escaped ([#8](https://github.com/epinault/graphql_markdown/issues/8))
* Object, interface and input descriptions were never rendered ([#9](https://github.com/epinault/graphql_markdown/issues/9))
* Operations and types without fields rendered a header-only table, and the default-value sentence was glued to the description without a space ([#10](https://github.com/epinault/graphql_markdown/issues/10))
* In single-page output the "Possible types" of a union linked to `objects.html#…`, which does not exist in a single page; they now link to the in-page anchor ([#32](https://github.com/epinault/graphql_markdown/issues/32))
* In multi-page output, links to interface-typed fields and return types pointed at `scalars.html` instead of `interfaces.html` ([#33](https://github.com/epinault/graphql_markdown/issues/33))

## 1.0.0 - 2026-10-29

### Changed

* First stable release. The mix task, generators and configuration are unchanged from 0.5.3
* Repository moved to https://github.com/epinault/graphql_markdown; package links updated
* CI now tests Elixir 1.17 - 1.20 on OTP 27 - 29; Elixir 1.15 - 1.16 and OTP 25 - 26 are no longer exercised in CI
* Add a `mix precommit` alias (format, unused-lock check, compile with warnings as errors, test with coverage, credo)

## 0.5.3 - 2026-04-15

### Fixed

* Fix crash when writing non-ASCII characters (e.g. em dash) to file on systems with non-UTF-8 locale

## 0.5.2 - 2025-12-30

### Fixed

* Add support for ENUM return types in GraphQL operations

## 0.5.1 - 2025-03-11

### Fixed

* Add support for NON_NULL GraphQL types

## 0.5.0 - 2024-10-01

### Changed

* Remove support for Elixir 1.13. Minimum is now 1.14

## 0.4.3 - 2024-09-27

### Fixed

* Fixes where NonNull and ListTypes were defaulting to scalar types for anchor links

## 0.4.2 - 2024-09-26

### Fixed

* Links to union return types handled correctly

## 0.4.1 - 2024-09-25

### Fixed

* Links to types from queries/mutations sets anchor properly

## 0.4.0 - 2024-08-26

### Added

* Added support for Subscriptions

## 0.3.1 - 2024-07-01

### Fixed

* Fix problems with generating example queries and mutations when the return types are unions, interfaces or lists: [#49](https://github.com/podium/graphql_markdown/pull/49)

## 0.3.0 - 2024-06-25 [RETIRED]

### Added

* Support generating example queries from the schema

## 0.2.1 - 2024-03-26

### Changed

* Improve documentation
* Fix generating multiple times

## 0.2.0 - 2024-01-12

### Changed

* Deps Update release

## 0.1.5 - 2023-08-16

### Changed

* Added more documentation
* Fix typespec

## 0.1.4 - 2022-09-27

### Changed

* Update dependencies
## 0.1.3 - 2021-09-23

### Fixed

* Add missing type and description for mutations and queries

## 0.1.2 - 2021-09-17

### Fixed

* Support for Unions properly
* Fix breakage when description is nil
## 0.1.1 - 2021-09-17

### Fixed

* Fix wrong link in multi page for scalar/objects
## 0.1 - 2021-09-17

_Initial release_
