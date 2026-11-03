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
    id
    name
    friends
    ... on Human {
    }
    ... on Droid {
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
    id
    name
    friends
    ... on Human {
    }
    ... on Droid {
    }
  }
}
```


