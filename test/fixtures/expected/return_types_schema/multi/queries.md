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
      name
    }
  }
}
```


## droid

Type: [Droid](objects.html#droid)

One droid

| argument | type | description |
| -------- | ---- | ----------- |
| `id` | [ID!](scalars.html#id) |  |

```gql
query Droid($id: ID!) {
  droid(id: $id) {
    id
    name
    owner {
      name
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
      name
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
      id
      name
      owner {
        name
      }
    }
    ... on Human {
      name
    }
  }
}
```


