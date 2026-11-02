# Graphql Schema

  * [Queries](#queries)
    * [invoice](#invoice)
  * [Objects](#objects)
    * [Invoice](#invoice)
  * [Inputs](#inputs)
  * [Enums](#enums)
    * [Status](#status)
  * [Scalars](#scalars)
    * [ID](#id)
    * [Int](#int)
  * [Interfaces](#interfaces)
  * [Unions](#unions)

## Queries

### invoice

Type: [Invoice](#invoice)

| field | description |
| ----- | ----------- |
| `uid` ( [ID!](#id) ) | Invoice UID<br>required when job_uid \| job_id are absent |

```gql
query Invoice($uid: ID!) {
  invoice(uid: $uid) {
    total
  }
}
```



## Mutations

None

## Subscriptions

None

## Objects

### Invoice

| field | description |
| ----- | ----------- |
| `total` ( [Int](#int) ) | Total in cents.<br><br>Always positive \| never zero |



## Inputs

None

## Enums

### Status

| value | description |
| ----- | ----------- |
| PAID | Paid<br>in full \| or partially |



## Scalars

### ID


### Int



## Interfaces

None

## Unions

None

