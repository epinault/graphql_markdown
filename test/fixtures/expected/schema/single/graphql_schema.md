# Graphql Schema

  * [Queries](#queries)
    * [userSsoDetails](#userssodetails)
    * [heroForEpisode](#heroforepisode)
    * [droidsInEpisode](#droidsinepisode)
    * [humansInEpisode](#humansinepisode)
  * [Mutations](#mutations)
    * [generateLoginCode](#generatelogincode)
    * [logout](#logout)
    * [logoutAll](#logoutall)
    * [passwordLogin](#passwordlogin)
    * [passwordLoginV2](#passwordloginv2)
    * [passwordlessLogin](#passwordlesslogin)
    * [refreshIdToken](#refreshidtoken)
  * [Subscriptions](#subscriptions)
    * [loginEvent](#loginevent)
  * [Objects](#objects)
    * [Droid](#droid)
    * [GenerateLoginCodeResponse](#generatelogincoderesponse)
    * [Human](#human)
    * [LoginResponse](#loginresponse)
    * [RefreshIdTokenResponse](#refreshidtokenresponse)
    * [UnexpectedRequest](#unexpectedrequest)
    * [UserSsoDetails](#userssodetails)
  * [Inputs](#inputs)
    * [PasswordLoginInput](#passwordlogininput)
    * [PasswordlessLoginInput](#passwordlesslogininput)
  * [Enums](#enums)
  * [Scalars](#scalars)
    * [Boolean](#boolean)
    * [String](#string)
  * [Interfaces](#interfaces)
    * [Character](#character)
  * [Unions](#unions)
    * [LoginResponseV2](#loginresponsev2)
    * [OauthPreauthorizeResult](#oauthpreauthorizeresult)

## Queries

### userSsoDetails

Type: [UserSsoDetails](#userssodetails)

| argument | type | description |
| -------- | ---- | ----------- |
| `emailOrPhone` | [String!](#string) |  |

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

| argument | type | description |
| -------- | ---- | ----------- |
| `episode` | [String!](#string) |  |

```gql
query HeroForEpisode($episode: String!) {
  heroForEpisode(episode: $episode) {
    __typename
    id
    name
    ... on Human {
      age
    }
    ... on Droid {
      primaryFunction
    }
  }
}
```


### droidsInEpisode

Type: [Droid](#droid)

Get droids for episode

| argument | type | description |
| -------- | ---- | ----------- |
| `episode` | [String!](#string) |  |

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

| argument | type | description |
| -------- | ---- | ----------- |
| `episode` | [String!](#string) |  |

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

| argument | type | description |
| -------- | ---- | ----------- |
| `emailOrPhone` | [String!](#string) |  |

```gql
mutation GenerateLoginCode($emailOrPhone: String!) {
  generateLoginCode(emailOrPhone: $emailOrPhone) {
    processed
  }
}
```


### logout

Type: [String](#string)

| argument | type | description |
| -------- | ---- | ----------- |
| `refreshToken` | [String!](#string) |  |

```gql
mutation Logout($refreshToken: String!) {
  logout(refreshToken: $refreshToken)
}
```


### logoutAll

Type: [String](#string)

| argument | type | description |
| -------- | ---- | ----------- |
| `userUid` | [String!](#string) |  |

```gql
mutation LogoutAll($userUid: String!) {
  logoutAll(userUid: $userUid)
}
```


### passwordLogin

Type: [LoginResponse](#loginresponse)

| argument | type | description |
| -------- | ---- | ----------- |
| `input` | [PasswordLoginInput!](#passwordlogininput) |  |

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

| argument | type | description |
| -------- | ---- | ----------- |
| `input` | [PasswordLoginInput!](#passwordlogininput) |  |

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


### passwordlessLogin

Type: [LoginResponse](#loginresponse)

| argument | type | description |
| -------- | ---- | ----------- |
| `input` | [PasswordlessLoginInput!](#passwordlesslogininput) |  |

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

| argument | type | description |
| -------- | ---- | ----------- |
| `refreshToken` | [String!](#string) |  |

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

Implements: [Character](#character)

| field | type | description |
| ----- | ---- | ----------- |
| `id` | [ID](#id) |  |
| `name` | [String](#string) |  |
| `primaryFunction` | [String](#string) |  |


### GenerateLoginCodeResponse

| field | type | description |
| ----- | ---- | ----------- |
| `processed` | [Boolean!](#boolean) |  |


### Human

Implements: [Character](#character)

| field | type | description |
| ----- | ---- | ----------- |
| `id` | [ID](#id) |  |
| `name` | [String](#string) |  |
| `age` | [Int](#int) |  |


### LoginResponse

| field | type | description |
| ----- | ---- | ----------- |
| `idToken` | [String!](#string) |  |
| `refreshToken` | [String!](#string) |  |


### RefreshIdTokenResponse

| field | type | description |
| ----- | ---- | ----------- |
| `idToken` | [String](#string) |  |
| `userSsoDetails` | [UserSsoDetails](#userssodetails) |  |


### UnexpectedRequest

Unacceptable input from user

| field | type | description |
| ----- | ---- | ----------- |
| `key` | [String!](#string) | The type of violation |
| `message` | [String!](#string) | An explanation on how the user can proceed |


### UserSsoDetails

| field | type | description |
| ----- | ---- | ----------- |
| `domain` | [String](#string) |  |
| `ssoEnabled` | [Boolean!](#boolean) |  |



## Inputs

### PasswordLoginInput

| field | type | description |
| ----- | ---- | ----------- |
| `emailOrPhone` | [String!](#string) |  |
| `password` | [String!](#string) |  |


### PasswordlessLoginInput

| field | type | description |
| ----- | ---- | ----------- |
| `code` | [String!](#string) |  |
| `emailOrPhone` | [String!](#string) |  |



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

| field | type | description |
| ----- | ---- | ----------- |
| `id` | [ID](#id) |  |
| `name` | [String](#string) | The name |

Implemented by:

  * [Human](#human)
  * [Droid](#droid)



## Unions

### LoginResponseV2

The response for password login

Possible types:

  * [LoginResponse](#loginresponse)
  * [UnexpectedRequest](#unexpectedrequest)


### OauthPreauthorizeResult

Possible types:

  * [OauthPreauthorizeData](#oauthpreauthorizedata)
  * [OauthRedirect](#oauthredirect)



