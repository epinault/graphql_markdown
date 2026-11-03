# Interfaces

## Character

A character in the saga.

| field | description |
| ----- | ----------- |
| `id` ( [ID!](scalars.html#id) ) |  |
| `name` ( [String](scalars.html#string) ) | Full name |
| `friends(first: Int = 10, after: String)` ( [\[Character\]](interfaces.html#character) ) | Friends of this character |

Implemented by:

  * [Human](objects.html#human)
  * [Droid](objects.html#droid)

