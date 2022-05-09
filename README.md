# Tezos Contract Starter Kit

## Pre-requisite

- ligo
- python3
- virtualenv
- pytezos

## Setup Environments

To set up the local environment, using the following command:

```
make env
```

For some tools that requires further dependencies, we list them below.

### Ligo

We use ligo docker image as the ligo CLI.

```
$ alias ligo="docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.40.0"
```

And test the ligo tool,

```
$ ligo version -version
```

### Pytezos

For different OS, there are some different requirements.

#### Mac

In mac, you need to install the following dependencies to ensure pytezos can well setup.

```
$ brew tap cuber/homebrew-libsecp256k1
$ brew install libsodium libsecp256k1 gmp pkg-config
```

### Compile

Use `make` to compile the contract code

### Deploy

Copy `env.json.sample` to `.env.jsom` and set up the variables properly.

Run

```
make deploy
```

### Test

Work in progress
