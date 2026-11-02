# My API

## Queries

### version

Type: [String](#string)

Current API version

```gql
query Version {
  version
}
```


### droids

Type: [Droid](#droid)

| field | description |
| ----- | ----------- |
| `first` ( [Int](#int) ) | Page size. The default value is `20` |
| `offset` ( [Int](#int) ) | The default value is `0` |
| `filter` ( [Int](#int) ) | Free text. |

```gql
query Droids($first: Int, $offset: Int, $filter: Int) {
  droids(first: $first, offset: $offset, filter: $filter) {
    name
  }
}
```



## Mutations

None

## Subscriptions

None

## Objects

### Droid

| field | description |
| ----- | ----------- |
| `name` ( [String](#string) ) |  |


### Nothing

Empty marker object



## Inputs

None

## Enums

None

## Scalars

### Int


### String



## Interfaces

None

## Unions

None

