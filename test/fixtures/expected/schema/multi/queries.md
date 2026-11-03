# Queries

## userSsoDetails

Type: [UserSsoDetails](objects.html#userssodetails)

| argument | type | description |
| -------- | ---- | ----------- |
| `emailOrPhone` | [String!](scalars.html#string) |  |

```gql
query UserSsoDetails($emailOrPhone: String!) {
  userSsoDetails(emailOrPhone: $emailOrPhone) {
    domain
    ssoEnabled
  }
}
```


## heroForEpisode

Type: [Character](interfaces.html#character)

| argument | type | description |
| -------- | ---- | ----------- |
| `episode` | [String!](scalars.html#string) |  |

```gql
query HeroForEpisode($episode: String!) {
  heroForEpisode(episode: $episode) {
    __typename
    id
    name
    ... on Human {
      age
    }
    ... on Droid {
      primaryFunction
    }
  }
}
```


## droidsInEpisode

Type: [Droid](objects.html#droid)

Get droids for episode

| argument | type | description |
| -------- | ---- | ----------- |
| `episode` | [String!](scalars.html#string) |  |

```gql
query DroidsInEpisode($episode: String!) {
  droidsInEpisode(episode: $episode) {
    id
    name
    primaryFunction
  }
}
```


## humansInEpisode

Type: [Human](objects.html#human)

Get the humans in an episode

| argument | type | description |
| -------- | ---- | ----------- |
| `episode` | [String!](scalars.html#string) |  |

```gql
query HumansInEpisode($episode: String!) {
  humansInEpisode(episode: $episode) {
    id
    name
    age
  }
}
```


