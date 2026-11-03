# Graphql Schema

  * [Queries](#queries)
    * [hero](#hero)
    * [starship](#starship)
    * [wrapper](#wrapper)
    * [search](#search)
  * [Objects](#objects)
    * [Deep](#deep)
    * [Droid](#droid)
    * [Human](#human)
    * [Inner](#inner)
    * [Starship](#starship)
    * [Wrapper](#wrapper)
  * [Inputs](#inputs)
  * [Enums](#enums)
  * [Scalars](#scalars)
    * [ID](#id)
    * [String](#string)
  * [Interfaces](#interfaces)
    * [Character](#character)
  * [Unions](#unions)
    * [SearchResult](#searchresult)

## Queries

### hero

Type: [Character](#character)

The hero of the saga

```gql
query Hero {
  hero {
    __typename
    id
    name
    ... on Human {
      homePlanet
      starship {
        id
        name
      }
    }
    ... on Droid {
      primaryFunction
    }
  }
}
```


### starship

Type: [Starship](#starship)

| field | description |
| ----- | ----------- |
| `id` ( [ID!](#id) ) |  |

```gql
query Starship($id: ID!) {
  starship(id: $id) {
    id
    name
    pilot {
      id
      name
      homePlanet
    }
  }
}
```


### wrapper

Type: [Wrapper](#wrapper)

```gql
query Wrapper {
  wrapper {
    inner {
      value
    }
  }
}
```


### search

Type: [SearchResult](#searchresult)

```gql
query Search {
  search {
    __typename
    ... on Human {
      id
      name
      friends {
        __typename
        id
        name
        ... on Droid {
          primaryFunction
        }
      }
      homePlanet
      starship {
        id
        name
      }
    }
    ... on Droid {
      id
      name
      friends {
        __typename
        id
        name
        ... on Human {
          homePlanet
        }
      }
      primaryFunction
    }
  }
}
```



## Mutations

None

## Subscriptions

None

## Objects

### Deep

| field | description |
| ----- | ----------- |
| `value` ( [String](#string) ) |  |


### Droid

Implements: [Character](#character)

| field | description |
| ----- | ----------- |
| `id` ( [ID!](#id) ) |  |
| `name` ( [String](#string) ) |  |
| `friends` ( [\[Character\]](#character) ) |  |
| `primaryFunction` ( [String](#string) ) |  |


### Human

Implements: [Character](#character)

| field | description |
| ----- | ----------- |
| `id` ( [ID!](#id) ) |  |
| `name` ( [String](#string) ) |  |
| `friends` ( [\[Character\]](#character) ) |  |
| `homePlanet` ( [String](#string) ) |  |
| `starship` ( [Starship](#starship) ) |  |


### Inner

| field | description |
| ----- | ----------- |
| `value` ( [String](#string) ) |  |
| `deep` ( [Deep](#deep) ) |  |


### Starship

| field | description |
| ----- | ----------- |
| `id` ( [ID!](#id) ) |  |
| `name` ( [String](#string) ) |  |
| `pilot` ( [Human](#human) ) |  |


### Wrapper

| field | description |
| ----- | ----------- |
| `inner` ( [Inner](#inner) ) |  |



## Inputs

None

## Enums

None

## Scalars

### ID


### String



## Interfaces

### Character

| field | description |
| ----- | ----------- |
| `id` ( [ID!](#id) ) |  |
| `name` ( [String](#string) ) |  |
| `friends` ( [\[Character\]](#character) ) |  |

Implemented by:

  * [Human](#human)
  * [Droid](#droid)


## Unions

### SearchResult

Possible types:

  * [Human](#human)
  * [Droid](#droid)


