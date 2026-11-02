# My API

## Queries

### userSsoDetails

Type: [UserSsoDetails](#userssodetails)

| field | description |
| ----- | ----------- |
| `emailOrPhone` ( [String!](#string) ) |  |

```gql
query UserSsoDetails($emailOrPhone: String!) {
  userSsoDetails(emailOrPhone: $emailOrPhone) {
    domain
    ssoEnabled
  }
}
```


### heroForEpisode

Type: [Character](#character)

| field | description |
| ----- | ----------- |
| `episode` ( [String!](#string) ) |  |

```gql
query HeroForEpisode($episode: String!) {
  heroForEpisode(episode: $episode) {
    id
    name
    ... on Human {
    }
    ... on Droid {
    }
  }
}
```


### droidsInEpisode

Type: [Droid](#droid)

Get droids for episode

| field | description |
| ----- | ----------- |
| `episode` ( [String!](#string) ) |  |

```gql
query DroidsInEpisode($episode: String!) {
  droidsInEpisode(episode: $episode) {
    id
    name
    primaryFunction
  }
}
```


### humansInEpisode

Type: [Human](#human)

Get the humans in an episode

| field | description |
| ----- | ----------- |
| `episode` ( [String!](#string) ) |  |

```gql
query HumansInEpisode($episode: String!) {
  humansInEpisode(episode: $episode) {
    id
    name
    age
  }
}
```



## Mutations

### generateLoginCode

Type: [GenerateLoginCodeResponse](#generatelogincoderesponse)

| field | description |
| ----- | ----------- |
| `emailOrPhone` ( [String!](#string) ) |  |

```gql
mutation GenerateLoginCode($emailOrPhone: String!) {
  generateLoginCode(emailOrPhone: $emailOrPhone) {
    processed
  }
}
```


### logout

Type: [String](#string)

| field | description |
| ----- | ----------- |
| `refreshToken` ( [String!](#string) ) |  |

```gql
mutation Logout($refreshToken: String!) {
  logout(refreshToken: $refreshToken)
}
```


### logoutAll

Type: [String](#string)

| field | description |
| ----- | ----------- |
| `userUid` ( [String!](#string) ) |  |

```gql
mutation LogoutAll($userUid: String!) {
  logoutAll(userUid: $userUid)
}
```


### passwordLogin

Type: [LoginResponse](#loginresponse)

| field | description |
| ----- | ----------- |
| `input` ( [PasswordLoginInput!](#passwordlogininput) ) |  |

```gql
mutation PasswordLogin($input: PasswordLoginInput!) {
  passwordLogin(input: $input) {
    idToken
    refreshToken
  }
}
```


### passwordLoginV2

Type: [LoginResponseV2](#loginresponsev2)

Version 2 of password login

| field | description |
| ----- | ----------- |
| `input` ( [PasswordLoginInput!](#passwordlogininput) ) |  |

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


### passwordlessLogin

Type: [LoginResponse](#loginresponse)

| field | description |
| ----- | ----------- |
| `input` ( [PasswordlessLoginInput!](#passwordlesslogininput) ) |  |

```gql
mutation PasswordlessLogin($input: PasswordlessLoginInput!) {
  passwordlessLogin(input: $input) {
    idToken
    refreshToken
  }
}
```


### refreshIdToken

Type: [RefreshIdTokenResponse](#refreshidtokenresponse)

| field | description |
| ----- | ----------- |
| `refreshToken` ( [String!](#string) ) |  |

```gql
mutation RefreshIdToken($refreshToken: String!) {
  refreshIdToken(refreshToken: $refreshToken) {
    idToken
    userSsoDetails {
    }
  }
}
```



## Subscriptions

### loginEvent

Type: [LoginResponse](#loginresponse)

Fires when a user logs in

```gql
subscription LoginEvent {
  loginEvent {
    idToken
    refreshToken
  }
}
```



## Objects

### Droid

| field | description |
| ----- | ----------- |
| `id` ( [ID](#id) ) |  |
| `name` ( [String](#string) ) |  |
| `primaryFunction` ( [String](#string) ) |  |


### GenerateLoginCodeResponse

| field | description |
| ----- | ----------- |
| `processed` ( [Boolean!](#boolean) ) |  |


### Human

| field | description |
| ----- | ----------- |
| `id` ( [ID](#id) ) |  |
| `name` ( [String](#string) ) |  |
| `age` ( [Int](#int) ) |  |


### LoginResponse

| field | description |
| ----- | ----------- |
| `idToken` ( [String!](#string) ) |  |
| `refreshToken` ( [String!](#string) ) |  |


### RefreshIdTokenResponse

| field | description |
| ----- | ----------- |
| `idToken` ( [String](#string) ) |  |
| `userSsoDetails` ( [UserSsoDetails](#userssodetails) ) |  |


### UnexpectedRequest

Unacceptable input from user

| field | description |
| ----- | ----------- |
| `key` ( [String!](#string) ) | The type of violation |
| `message` ( [String!](#string) ) | An explanation on how the user can proceed |


### UserSsoDetails

| field | description |
| ----- | ----------- |
| `domain` ( [String](#string) ) |  |
| `ssoEnabled` ( [Boolean!](#boolean) ) |  |



## Inputs

### PasswordLoginInput

| field | description |
| ----- | ----------- |
| `emailOrPhone` ( [String!](#string) ) |  |
| `password` ( [String!](#string) ) |  |


### PasswordlessLoginInput

| field | description |
| ----- | ----------- |
| `code` ( [String!](#string) ) |  |
| `emailOrPhone` ( [String!](#string) ) |  |



## Enums

None

## Scalars

### Boolean

The `Boolean` scalar type represents `true` or `false`.


### String

The `String` scalar type represents textual data, represented as UTF-8
character sequences. The String type is most often used by GraphQL to
represent free-form human-readable text.



## Interfaces

### Character

Information about a character

| field | description |
| ----- | ----------- |
| `id` ( [ID](#id) ) |  |
| `name` ( [String](#string) ) | The name |



## Unions

### LoginResponseV2

The response for password login

Possible types:

  * [LoginResponse](objects.html#loginresponse)
  * [UnexpectedRequest](objects.html#unexpectedrequest)

### OauthPreauthorizeResult

Possible types:

  * [OauthPreauthorizeData](objects.html#oauthpreauthorizedata)
  * [OauthRedirect](objects.html#oauthredirect)


