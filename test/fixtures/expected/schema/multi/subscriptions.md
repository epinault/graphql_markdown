# Subscriptions

## loginEvent

Type: [LoginResponse](objects.html#loginresponse)

Fires when a user logs in

```gql
subscription LoginEvent {
  loginEvent {
    idToken
    refreshToken
  }
}
```


