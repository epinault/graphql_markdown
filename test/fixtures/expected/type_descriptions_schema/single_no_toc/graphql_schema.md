# My API

## Queries

### droid

Type: [Droid](#droid)

| field | description |
| ----- | ----------- |
| `input` ( [DroidFilter](#droidfilter) ) |  |

```gql
query Droid($input: DroidFilter) {
  droid(input: $input) {
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

An autonomous mechanical character.

Implements: [Character](#character)

| field | description |
| ----- | ----------- |
| `name` ( [String](#string) ) |  |



## Inputs

### DroidFilter

Criteria used to narrow down droids.

| field | description |
| ----- | ----------- |
| `name` ( [String](#string) ) | Exact name match |



## Enums

None

## Scalars

### String



## Interfaces

### Character

Something with a name, human or not.

| field | description |
| ----- | ----------- |
| `name` ( [String](#string) ) |  |

Implemented by:

  * [Droid](#droid)


## Unions

None

