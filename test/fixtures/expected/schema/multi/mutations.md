# Mutations

## generateLoginCode

Type: [GenerateLoginCodeResponse](objects.html#generatelogincoderesponse)

| argument | type | description |
| -------- | ---- | ----------- |
| `emailOrPhone` | [String!](scalars.html#string) |  |

```gql
mutation GenerateLoginCode($emailOrPhone: String!) {
  generateLoginCode(emailOrPhone: $emailOrPhone) {
    processed
  }
}
```


## logout

Type: [String](scalars.html#string)

| argument | type | description |
| -------- | ---- | ----------- |
| `refreshToken` | [String!](scalars.html#string) |  |

```gql
mutation Logout($refreshToken: String!) {
  logout(refreshToken: $refreshToken)
}
```


## logoutAll

Type: [String](scalars.html#string)

| argument | type | description |
| -------- | ---- | ----------- |
| `userUid` | [String!](scalars.html#string) |  |

```gql
mutation LogoutAll($userUid: String!) {
  logoutAll(userUid: $userUid)
}
```


## passwordLogin

Type: [LoginResponse](objects.html#loginresponse)

| argument | type | description |
| -------- | ---- | ----------- |
| `input` | [PasswordLoginInput!](inputs.html#passwordlogininput) |  |

```gql
mutation PasswordLogin($input: PasswordLoginInput!) {
  passwordLogin(input: $input) {
    idToken
    refreshToken
  }
}
```


## passwordLoginV2

Type: [LoginResponseV2](unions.html#loginresponsev2)

Version 2 of password login

| argument | type | description |
| -------- | ---- | ----------- |
| `input` | [PasswordLoginInput!](inputs.html#passwordlogininput) |  |

```gql
mutation PasswordLoginV2($input: PasswordLoginInput!) {
  passwordLoginV2(input: $input) {
    __typename
    ... on LoginResponse {
      idToken
      refreshToken
    }
    ... on UnexpectedRequest {
      key
      message
    }
  }
}
```


## passwordlessLogin

Type: [LoginResponse](objects.html#loginresponse)

| argument | type | description |
| -------- | ---- | ----------- |
| `input` | [PasswordlessLoginInput!](inputs.html#passwordlesslogininput) |  |

```gql
mutation PasswordlessLogin($input: PasswordlessLoginInput!) {
  passwordlessLogin(input: $input) {
    idToken
    refreshToken
  }
}
```


## refreshIdToken

Type: [RefreshIdTokenResponse](objects.html#refreshidtokenresponse)

| argument | type | description |
| -------- | ---- | ----------- |
| `refreshToken` | [String!](scalars.html#string) |  |

```gql
mutation RefreshIdToken($refreshToken: String!) {
  refreshIdToken(refreshToken: $refreshToken) {
    idToken
    userSsoDetails {
      domain
      ssoEnabled
    }
  }
}
```


