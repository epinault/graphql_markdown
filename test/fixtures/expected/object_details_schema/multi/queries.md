# Queries

## hero

Type: [Character](interfaces.html#character)

The hero of an episode

| field | description |
| ----- | ----------- |
| `episode` ( [Episode](enums.html#episode) ) |  |

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


## oldHero

Type: [Character](interfaces.html#character)

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


