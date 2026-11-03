# Graphql Schema

  * [Queries](#queries)
    * [version](#version)
    * [droids](#droids)
  * [Objects](#objects)
    * [Droid](#droid)
    * [Nothing](#nothing)
  * [Inputs](#inputs)
  * [Enums](#enums)
  * [Scalars](#scalars)
    * [Int](#int)
    * [String](#string)
  * [Interfaces](#interfaces)
  * [Unions](#unions)

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

| argument | type | description |
| -------- | ---- | ----------- |
| `first` | [Int](#int) | Page size. The default value is `20` |
| `offset` | [Int](#int) | The default value is `0` |
| `filter` | [Int](#int) | Free text. |

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

| field | type | description |
| ----- | ---- | ----------- |
| `name` | [String](#string) |  |


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

