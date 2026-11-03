# Objects

## Droid

Implements: [Character](interfaces.html#character)

| field | description |
| ----- | ----------- |
| `id` ( [ID](scalars.html#id) ) |  |
| `name` ( [String](scalars.html#string) ) |  |
| `primaryFunction` ( [String](scalars.html#string) ) |  |


## GenerateLoginCodeResponse

| field | description |
| ----- | ----------- |
| `processed` ( [Boolean!](scalars.html#boolean) ) |  |


## Human

Implements: [Character](interfaces.html#character)

| field | description |
| ----- | ----------- |
| `id` ( [ID](scalars.html#id) ) |  |
| `name` ( [String](scalars.html#string) ) |  |
| `age` ( [Int](scalars.html#int) ) |  |


## LoginResponse

| field | description |
| ----- | ----------- |
| `idToken` ( [String!](scalars.html#string) ) |  |
| `refreshToken` ( [String!](scalars.html#string) ) |  |


## RefreshIdTokenResponse

| field | description |
| ----- | ----------- |
| `idToken` ( [String](scalars.html#string) ) |  |
| `userSsoDetails` ( [UserSsoDetails](objects.html#userssodetails) ) |  |


## UnexpectedRequest

Unacceptable input from user

| field | description |
| ----- | ----------- |
| `key` ( [String!](scalars.html#string) ) | The type of violation |
| `message` ( [String!](scalars.html#string) ) | An explanation on how the user can proceed |


## UserSsoDetails

| field | description |
| ----- | ----------- |
| `domain` ( [String](scalars.html#string) ) |  |
| `ssoEnabled` ( [Boolean!](scalars.html#boolean) ) |  |


