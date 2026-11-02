# Mutations

## generateLoginCode

Type: [GenerateLoginCodeResponse](objects.html#generatelogincoderesponse)

| field | description |
| ----- | ----------- |
| `emailOrPhone` ( [String!](scalars.html#string) ) |  |

```gql
mutation GenerateLoginCode($emailOrPhone: String!) {
  generateLoginCode(emailOrPhone: $emailOrPhone) {
    processed
  }
}
```


## logout

Type: [String](scalars.html#string)

| field | description |
| ----- | ----------- |
| `refreshToken` ( [String!](scalars.html#string) ) |  |

```gql
mutation Logout($refreshToken: String!) {
  logout(refreshToken: $refreshToken)
}
```


## logoutAll

Type: [String](scalars.html#string)

| field | description |
| ----- | ----------- |
| `userUid` ( [String!](scalars.html#string) ) |  |

```gql
mutation LogoutAll($userUid: String!) {
  logoutAll(userUid: $userUid)
}
```


## passwordLogin

Type: [LoginResponse](objects.html#loginresponse)

| field | description |
| ----- | ----------- |
| `input` ( [PasswordLoginInput!](inputs.html#passwordlogininput) ) |  |

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

| field | description |
| ----- | ----------- |
| `input` ( [PasswordLoginInput!](inputs.html#passwordlogininput) ) |  |

```gql
mutation PasswordLoginV2($input: PasswordLoginInput!) {
  passwordLoginV2(input: $input) {
    __typename
    ... on LoginResponse {
    }
    ... on UnexpectedRequest {
    }
  }
}
```


## passwordlessLogin

Type: [LoginResponse](objects.html#loginresponse)

| field | description |
| ----- | ----------- |
| `input` ( [PasswordlessLoginInput!](inputs.html#passwordlesslogininput) ) |  |

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

| field | description |
| ----- | ----------- |
| `refreshToken` ( [String!](scalars.html#string) ) |  |

```gql
mutation RefreshIdToken($refreshToken: String!) {
  refreshIdToken(refreshToken: $refreshToken) {
    idToken
    userSsoDetails {
    }
  }
}
```


