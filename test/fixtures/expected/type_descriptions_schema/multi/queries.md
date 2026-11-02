# Queries

## droid

Type: [Droid](objects.html#droid)

| field | description |
| ----- | ----------- |
| `input` ( [DroidFilter](inputs.html#droidfilter) ) |  |

```gql
query Droid($input: DroidFilter) {
  droid(input: $input) {
    name
  }
}
```


