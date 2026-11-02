# Queries

## version

Type: [String](scalars.html#string)

Current API version

```gql
query Version {
  version
}
```


## droids

Type: [Droid](objects.html#droid)

| field | description |
| ----- | ----------- |
| `first` ( [Int](scalars.html#int) ) | Page size. The default value is `20` |
| `offset` ( [Int](scalars.html#int) ) | The default value is `0` |
| `filter` ( [Int](scalars.html#int) ) | Free text. |

```gql
query Droids($first: Int, $offset: Int, $filter: Int) {
  droids(first: $first, offset: $offset, filter: $filter) {
    name
  }
}
```


