# Queries

## droids

Type: [Droid](objects.html#droid)

All droids

```gql
query Droids {
  droids {
    id
    name
    owner {
    }
  }
}
```


## droid

Type: [Droid](objects.html#droid)

One droid

| field | description |
| ----- | ----------- |
| `id` ( [ID!](scalars.html#id) ) |  |

```gql
query Droid($id: ID!) {
  droid(id: $id) {
    id
    name
    owner {
    }
  }
}
```


## maybeDroids

Type: [Droid](objects.html#droid)

```gql
query MaybeDroids {
  maybeDroids {
    id
    name
    owner {
    }
  }
}
```


## count

Type: [Int](scalars.html#int)

```gql
query Count {
  count
}
```


## requiredCount

Type: [Int](scalars.html#int)

```gql
query RequiredCount {
  requiredCount
}
```


## status

Type: [Status](enums.html#status)

```gql
query Status {
  status
}
```


## searchResults

Type: [SearchResult](unions.html#searchresult)

```gql
query SearchResults {
  searchResults {
    __typename
    ... on Droid {
    }
    ... on Human {
    }
  }
}
```


