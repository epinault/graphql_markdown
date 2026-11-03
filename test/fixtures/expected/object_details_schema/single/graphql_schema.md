# Graphql Schema

  * [Queries](#queries)
    * [hero](#hero)
    * [oldHero](#oldhero)
  * [Objects](#objects)
    * [Droid](#droid)
    * [Human](#human)
    * [Starship](#starship)
  * [Inputs](#inputs)
  * [Enums](#enums)
    * [Episode](#episode)
  * [Scalars](#scalars)
    * [Boolean](#boolean)
    * [ID](#id)
    * [Int](#int)
    * [String](#string)
  * [Interfaces](#interfaces)
    * [Character](#character)
  * [Unions](#unions)

## Queries

### hero

Type: [Character](#character)

The hero of an episode

| argument | type | description |
| -------- | ---- | ----------- |
| `episode` | [Episode](#episode) |  |

```gql
query Hero($episode: Episode) {
  hero(episode: $episode) {
    __typename
    id
    name
    ... on Human {
      homePlanet
    }
    ... on Droid {
      primaryFunction
      serialNumber
    }
  }
}
```


### oldHero

Type: [Character](#character)

**Deprecated:** Use `hero` instead

The hero of the first episode

```gql
query OldHero {
  oldHero {
    __typename
    id
    name
    ... on Human {
      homePlanet
    }
    ... on Droid {
      primaryFunction
      serialNumber
    }
  }
}
```



## Mutations

None

## Subscriptions

None

## Objects

### Droid

An autonomous mechanical character.

Implements: [Character](#character)

| field | type | description |
| ----- | ---- | ----------- |
| `id` | [ID!](#id) |  |
| `name` | [String](#string) | Full name |
| `friends(first: Int = 10, after: String)` | [\[Character\]](#character) | Friends of this character |
| ~~`primaryFunction`~~ | [String](#string) | What the droid was built for. **Deprecated:** Droids no longer have a single function |
| `serialNumber` | [String](#string) |  |


### Human

A person.

Implements: [Character](#character)

| field | type | description |
| ----- | ---- | ----------- |
| `id` | [ID!](#id) |  |
| `name` | [String](#string) | Full name |
| `friends(first: Int = 10, after: String)` | [\[Character\]](#character) | Friends of this character |
| `homePlanet` | [String](#string) | Where they were born |


### Starship

A vessel. Implements nothing.

| field | type | description |
| ----- | ---- | ----------- |
| `id` | [ID!](#id) |  |



## Inputs

None

## Enums

### Episode

One of the films.

| value | description |
| ----- | ----------- |
| NEWHOPE | Released in 1977 |
| EMPIRE |  |
| JEDI | Released in 1983 |
| ~~CLONE_WARS~~ | An animated film. **Deprecated:** Not part of the original trilogy |
| ~~HOLIDAY_SPECIAL~~ | **Deprecated** |



## Scalars

### Boolean


### ID

Unique identifier


### Int


### String



## Interfaces

### Character

A character in the saga.

| field | type | description |
| ----- | ---- | ----------- |
| `id` | [ID!](#id) |  |
| `name` | [String](#string) | Full name |
| `friends(first: Int = 10, after: String)` | [\[Character\]](#character) | Friends of this character |

Implemented by:

  * [Human](#human)
  * [Droid](#droid)



## Unions

None

