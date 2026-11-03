# Objects

## Droid

An autonomous mechanical character.

Implements: [Character](interfaces.html#character)

| field | type | description |
| ----- | ---- | ----------- |
| `id` | [ID!](scalars.html#id) |  |
| `name` | [String](scalars.html#string) | Full name |
| `friends(first: Int = 10, after: String)` | [\[Character\]](interfaces.html#character) | Friends of this character |
| ~~`primaryFunction`~~ | [String](scalars.html#string) | What the droid was built for. **Deprecated:** Droids no longer have a single function |
| `serialNumber` | [String](scalars.html#string) |  |


## Human

A person.

Implements: [Character](interfaces.html#character)

| field | type | description |
| ----- | ---- | ----------- |
| `id` | [ID!](scalars.html#id) |  |
| `name` | [String](scalars.html#string) | Full name |
| `friends(first: Int = 10, after: String)` | [\[Character\]](interfaces.html#character) | Friends of this character |
| `homePlanet` | [String](scalars.html#string) | Where they were born |


## Starship

A vessel. Implements nothing.

| field | type | description |
| ----- | ---- | ----------- |
| `id` | [ID!](scalars.html#id) |  |


