# Feral File Exhibition Contract Ligo

## Pre-requisite

- [ligo](https://ligolang.org/docs/intro/installation/)
- [octez-client v15.0+](https://wiki.tezos.com/build/clients/installation-and-setup)  (former tezos-client)
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

First you need to setup the ff-deployer account. It can be either by local secret or a ledger. For the local setup, please ensure `.env.json` is well-configured with a `key`.

```sh
make init-local
```

or

```sh
make init-ledger
```

After the account is set up, run

```sh
make deploy
```

## Test

Work in progress
