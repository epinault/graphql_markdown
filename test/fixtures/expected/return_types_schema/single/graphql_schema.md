# Graphql Schema

  * [Queries](#queries)
    * [droids](#droids)
    * [droid](#droid)
    * [maybeDroids](#maybedroids)
    * [count](#count)
    * [requiredCount](#requiredcount)
    * [status](#status)
    * [searchResults](#searchresults)
  * [Objects](#objects)
    * [Droid](#droid)
    * [Human](#human)
  * [Inputs](#inputs)
  * [Enums](#enums)
    * [Status](#status)
  * [Scalars](#scalars)
    * [ID](#id)
    * [Int](#int)
    * [String](#string)
  * [Interfaces](#interfaces)
  * [Unions](#unions)
    * [SearchResult](#searchresult)

## Queries

### droids

Type: [Droid](#droid)

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


### droid

Type: [Droid](#droid)

One droid

| field | description |
| ----- | ----------- |
| `id` ( [ID!](#id) ) |  |

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


### maybeDroids

Type: [Droid](#droid)

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


### count

Type: [Int](#int)

```gql
query Count {
  count
}
```


### requiredCount

Type: [Int](#int)

```gql
query RequiredCount {
  requiredCount
}
```


### status

Type: [Status](#status)

```gql
query Status {
  status
}
```


### searchResults

Type: [SearchResult](#searchresult)

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



## Mutations

None

## Subscriptions

None

## Objects

### Droid

| field | description |
| ----- | ----------- |
| `id` ( [ID!](#id) ) |  |
| `name` ( [String](#string) ) |  |
| `owner` ( [Human](#human) ) |  |


### Human

| field | description |
| ----- | ----------- |
| `name` ( [String](#string) ) |  |



## Inputs

None

## Enums

### Status

| value | description |
| ----- | ----------- |
| ACTIVE |  |



## Scalars

### ID


### Int


### String



## Interfaces

None

## Unions

### SearchResult

Possible types:

  * [Droid](#droid)
  * [Human](#human)


