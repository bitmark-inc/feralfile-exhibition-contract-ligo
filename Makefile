.PHONY: api

default: clean compile compile-storage

OS=$(shell /usr/bin/uname)
PWD=$(shell pwd)

# Set default ligo CLI to docker image command for macOS
ifeq (${OS}, Darwin)
LIGO=docker run --rm -v ${PWD}:${PWD} -w ${PWD} ligolang/ligo:0.43.0
else
LIGO=ligo
endif

clean:
	rm -rf ./compilation
	mkdir ./compilation

compile:
	${LIGO} compile contract src/ff_main.mligo -o compilation/contract.tz

compile-storage:
	${LIGO} compile storage src/ff_main.mligo 'default_storage' -o compilation/storage.tz

tc-init:
	TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=yes octez-client --endpoint $(shell jq -r .shell .env.json) config update
	TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=yes octez-client import secret key ff-deployer unencrypted:$(shell jq -r .key .env.json) --force

init-local: tc-init
init-ledger:
	octez-client --endpoint $(shell jq -r .shell .env.json) config update
	octez-client import secret key ff-deployer "ledger://quarrelsome-moose-concrete-neanderthal/ed25519/0h/0h" --force
deploy: tc-deploy

tc-dry-deploy: compile compile-storage
	TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=yes octez-client originate contract FFExhibition transferring 0 from ff-deployer \
	running ./compilation/contract.tz -D --verbose-signing --burn-cap 15 --init '$(shell cat ./compilation/storage.tz)'

tc-deploy: compile compile-storage
	TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=yes octez-client originate contract FFExhibition transferring 0 from ff-deployer \
	running ./compilation/contract.tz --burn-cap 15 --init '$(shell cat ./compilation/storage.tz)'
	TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=yes octez-client forget all contracts --force

test-register-artwork:
	TEZOS_RPC_URL=$(shell jq -r .shell .env.json) \
	DEPLOYER_PRIVATE_KEY=$(shell jq -r .key .env.json) \
	CONTRACT_ADDRESS=$(shell jq -r .contract .env.json) \
	npm run test-register-artwork

test-mint-editions:
	TEZOS_RPC_URL=$(shell jq -r .shell .env.json) \
	DEPLOYER_PRIVATE_KEY=$(shell jq -r .key .env.json) \
	CONTRACT_ADDRESS=$(shell jq -r .contract .env.json) \
	npm run test-mint-editions

test-update-edition-metadata:
	TEZOS_RPC_URL=$(shell jq -r .shell .env.json) \
	DEPLOYER_PRIVATE_KEY=$(shell jq -r .key .env.json) \
	CONTRACT_ADDRESS=$(shell jq -r .contract .env.json) \
	TEST_TOKEN_ID=$(shell jq -r .testTokenID .env.json) \
	npm run test-update-edition-metadata

test-authorized-transfer:
	TEZOS_RPC_URL=$(shell jq -r .shell .env.json) \
	DEPLOYER_PRIVATE_KEY=$(shell jq -r .key .env.json) \
	NO_XTZ_ACCOUNT_PRIVATE_KEY=$(shell jq -r .noXTZAccKey .env.json) \
	CONTRACT_ADDRESS=$(shell jq -r .contract .env.json) \
	TEST_TOKEN_ID=$(shell jq -r .testTokenID .env.json) \
	npm run test-authorized-transfer

test-burn-editions:
	TEZOS_RPC_URL=$(shell jq -r .shell .env.json) \
	DEPLOYER_PRIVATE_KEY=$(shell jq -r .key .env.json) \
	CONTRACT_ADDRESS=$(shell jq -r .contract .env.json) \
	TEST_TOKEN_ID=$(shell jq -r .testTokenID .env.json) \
	npm run test-burn-editions

test-add-trustee:
	TEZOS_RPC_URL=$(shell jq -r .shell .env.json) \
	DEPLOYER_PRIVATE_KEY=$(shell jq -r .key .env.json) \
	CONTRACT_ADDRESS=$(shell jq -r .contract .env.json) \
	npm run test-add-trustee

test-remove-trustee:
	TEZOS_RPC_URL=$(shell jq -r .shell .env.json) \
	DEPLOYER_PRIVATE_KEY=$(shell jq -r .key .env.json) \
	CONTRACT_ADDRESS=$(shell jq -r .contract .env.json) \
	npm run test-remove-trustee

test-action-with-xtz:
	TEZOS_RPC_URL=$(shell jq -r .shell .env.json) \
	DEPLOYER_PRIVATE_KEY=$(shell jq -r .key .env.json) \
	CONTRACT_ADDRESS=$(shell jq -r .contract .env.json) \
	npm run test-action-with-xtz

test-contract: test-register-artwork test-mint-editions test-update-edition-metadata test-authorized-transfer test-burn-editions test-add-trustee test-remove-trustee

git-init:
	git submodule init
	git submodule update

env: git-init tc-init

test:
	${LIGO} run dry-run --entry-point main src/ff_fa2_asset.mligo 'Transfer ([])' 'default_storage'
