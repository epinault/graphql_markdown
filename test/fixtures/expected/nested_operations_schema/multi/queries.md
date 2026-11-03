# Queries

## hero

Type: [Character](interfaces.html#character)

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


## starship

Type: [Starship](objects.html#starship)

| field | description |
| ----- | ----------- |
| `id` ( [ID!](scalars.html#id) ) |  |

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


## wrapper

Type: [Wrapper](objects.html#wrapper)

```gql
query Wrapper {
  wrapper {
    inner {
      value
    }
  }
}
```


## search

Type: [SearchResult](unions.html#searchresult)

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


