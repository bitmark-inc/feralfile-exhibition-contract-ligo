.PHONY: api

default: clean compile compile-storage

ARCH=$(shell /usr/bin/uname -m)
PWD=$(shell pwd)
LIGO=docker run --rm -v ${PWD}:${PWD} -w ${PWD} ligolang/ligo:0.43.0

clean:
	rm -rf ./compilation
	mkdir ./compilation

compile-consts:
	${LIGO} compile constant cameligo "bytes_to_nat" --format json --init-file src/global_constants/bytes_to_nat.mligo > src/global_constants/bytes_to_nat.json
	jq -r '[.text_code]' src/global_constants/bytes_to_nat.json > src/global_constants/bytes_to_nat_array.json

compile:
	${LIGO} compile contract src/ff_fa2_asset.mligo -o compilation/contract.tz --file-constants src/global_constants/bytes_to_nat_array.json

compile-storage:
	${LIGO} compile storage src/ff_fa2_asset.mligo 'default_storage' -o compilation/storage.tz

deploy:
	./tools/with_venv.sh python ./tools/originate.py

tc-init:
	TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=yes tezos-client --endpoint $(shell jq -r .shell .env.json) config update
	TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=yes tezos-client import secret key default unencrypted:$(shell jq -r .key .env.json) --force

tc-dry-deploy: compile compile-storage
	TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=yes tezos-client originate contract FFExhibition transferring 0 from default \
	running ./compilation/contract.tz -D --verbose-signing --burn-cap 15 --init '$(shell cat ./compilation/storage.tz)'

tc-deploy: compile compile-storage
	TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=yes tezos-client originate contract FFExhibition transferring 0 from default \
	running ./compilation/contract.tz --burn-cap 15 --init '$(shell cat ./compilation/storage.tz)'
	TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=yes tezos-client forget all contracts --force

# This command failed if it has already registered
tc-deploy-consts: compile-consts
	TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=yes tezos-client register global constant '$(shell jq -r .text_code src/global_constants/bytes_to_nat.json)' from default

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

test-authorized-transfer:
	TEZOS_RPC_URL=$(shell jq -r .shell .env.json) \
	DEPLOYER_PRIVATE_KEY=$(shell jq -r .key .env.json) \
	NO_XTZ_ACCOUNT_PRIVATE_KEY=$(shell jq -r .noXTZAccKey .env.json) \
	CONTRACT_ADDRESS=$(shell jq -r .contract .env.json) \
	TEST_TOKEN_ID=$(shell jq -r .testTokenID .env.json) \
	npm run test-authorized-transfer

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

test-contract: test-register-artwork test-mint-editions test-authorized-transfer test-add-trustee test-remove-trustee

env:
	git submodule init
	git submodule update
	virtualenv .venv
ifeq (${ARCH}, arm64)
	CFLAGS="-I/opt/homebrew/Cellar/gmp/6.2.1_1/include/ -L/opt/homebrew/Cellar/gmp/6.2.1_1/lib/" \
	LIB_DIR="/opt/homebrew/Cellar/libsecp256k1/0.1/lib" \
	INCLUDE_DIR="/opt/homebrew/Cellar/libsecp256k1/0.1/include" \
	./tools/with_venv.sh pip install --no-cache-dir pytezos
else
	CFLAGS="-I/usr/local/Cellar/gmp/6.2.1_1/include/ -L/usr/local/Cellar/gmp/6.2.1_1/lib/" \
	LIB_DIR="/usr/local/Cellar/libsecp256k1/0.1/lib" \
	INCLUDE_DIR="/usr/local/Cellar/libsecp256k1/0.1/include" \
	./tools/with_venv.sh pip install --no-cache-dir pytezos
endif
test:
	${LIGO} run dry-run --entry-point main src/ff_fa2_asset.mligo 'Transfer ([])' 'default_storage'
