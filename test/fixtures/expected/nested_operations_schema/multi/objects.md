# Objects

## Deep

| field | type | description |
| ----- | ---- | ----------- |
| `value` | [String](scalars.html#string) |  |


## Droid

Implements: [Character](interfaces.html#character)

| field | type | description |
| ----- | ---- | ----------- |
| `id` | [ID!](scalars.html#id) |  |
| `name` | [String](scalars.html#string) |  |
| `friends` | [\[Character\]](interfaces.html#character) |  |
| `primaryFunction` | [String](scalars.html#string) |  |


## Human

Implements: [Character](interfaces.html#character)

| field | type | description |
| ----- | ---- | ----------- |
| `id` | [ID!](scalars.html#id) |  |
| `name` | [String](scalars.html#string) |  |
| `friends` | [\[Character\]](interfaces.html#character) |  |
| `homePlanet` | [String](scalars.html#string) |  |
| `starship` | [Starship](objects.html#starship) |  |


## Inner

| field | type | description |
| ----- | ---- | ----------- |
| `value` | [String](scalars.html#string) |  |
| `deep` | [Deep](objects.html#deep) |  |


## Starship

| field | type | description |
| ----- | ---- | ----------- |
| `id` | [ID!](scalars.html#id) |  |
| `name` | [String](scalars.html#string) |  |
| `pilot` | [Human](objects.html#human) |  |


## Wrapper

| field | type | description |
| ----- | ---- | ----------- |
| `inner` | [Inner](objects.html#inner) |  |


