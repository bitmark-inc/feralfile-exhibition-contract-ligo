# Feral File Exhibition Contract Ligo

## Pre-requisite

- [ligo](https://ligolang.org/docs/intro/installation/)
- [tezos-client](https://wiki.tezos.com/build/clients/installation-and-setup)
- docker (for mac user)

### ligo on Mac

Since there is no native build of ligo on mac, we leverage docker image to run ligo. You can test the ligo environment by:

```sh
alias ligo="docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.43.0"
ligo version -version
```

## Setup Environment

To set up the local environment, we first copy `env.json.sample` to `.env.json` and set up the variables properly.
After that, run the following command:

```sh
make env
```

## Compile

Use `make` to compile the contract code

## Deploy

Run

```sh
make deploy
```

## Test

Work in progress
