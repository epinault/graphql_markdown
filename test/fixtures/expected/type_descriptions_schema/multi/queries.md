# Queries

## droid

Type: [Droid](objects.html#droid)

| argument | type | description |
| -------- | ---- | ----------- |
| `input` | [DroidFilter](inputs.html#droidfilter) |  |

```gql
query Droid($input: DroidFilter) {
  droid(input: $input) {
    name
  }
}
```


