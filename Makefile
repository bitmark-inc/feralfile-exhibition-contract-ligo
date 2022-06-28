.PHONY: api

default: clean compile-consts compile compile-storage

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

compile-consts:
	${LIGO} compile constant cameligo "bytes_to_nat" --format json --init-file src/global_constants/bytes_to_nat.mligo > src/global_constants/bytes_to_nat.json
	jq -r '[.text_code]' src/global_constants/bytes_to_nat.json > src/global_constants/bytes_to_nat_array.json

compile:
	${LIGO} compile contract src/ff_fa2_asset.mligo -o compilation/contract.tz --file-constants src/global_constants/bytes_to_nat_array.json

compile-storage:
	${LIGO} compile storage src/ff_fa2_asset.mligo 'default_storage' -o compilation/storage.tz --file-constants src/global_constants/bytes_to_nat_array.json

tc-init:
	TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=yes tezos-client --endpoint $(shell jq -r .shell .env.json) config update
	TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=yes tezos-client import secret key ff-deployer unencrypted:$(shell jq -r .key .env.json) --force

deploy: tc-deploy

tc-dry-deploy: compile compile-storage
	TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=yes tezos-client originate contract FFExhibition transferring 0 from ff-deployer \
	running ./compilation/contract.tz -D --verbose-signing --burn-cap 15 --init '$(shell cat ./compilation/storage.tz)'

tc-deploy: compile compile-storage
	TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=yes tezos-client originate contract FFExhibition transferring 0 from ff-deployer \
	running ./compilation/contract.tz --burn-cap 15 --init '$(shell cat ./compilation/storage.tz)'
	TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=yes tezos-client forget all contracts --force

# NOTE: This command can only run one time for each network
# since each global constant can only register once in a specific network
tc-deploy-consts: compile-consts
	TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=yes tezos-client register global constant '$(shell jq -r .text_code src/global_constants/bytes_to_nat.json)' from ff-deployer --burn-cap 2

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

test-contract: test-register-artwork test-mint-editions test-update-edition-metadata test-authorized-transfer test-burn-editions test-add-trustee test-remove-trustee

git-init:
	git submodule init
	git submodule update

env: git-init tc-init

test:
	${LIGO} run dry-run --entry-point main src/ff_fa2_asset.mligo 'Transfer ([])' 'default_storage'
