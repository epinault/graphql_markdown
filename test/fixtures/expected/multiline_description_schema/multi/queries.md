# Queries

## invoice

Type: [Invoice](objects.html#invoice)

| argument | type | description |
| -------- | ---- | ----------- |
| `uid` | [ID!](scalars.html#id) | Invoice UID<br>required when job_uid \| job_id are absent |

```gql
query Invoice($uid: ID!) {
  invoice(uid: $uid) {
    total
  }
}
```


