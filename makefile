# Makefile
.PHONY: build deploy test

# Load environment variables from .env file if it exists
ifneq (,$(wildcard .env))
    include .env
    export
endif

build:
	forge build

deploy-monad:
	@if [ -z "$(PRIVATE_KEY)" ]; then echo "Error: PRIVATE_KEY environment variable not set"; exit 1; fi
	forge create --rpc-url https://rpc.ankr.com/monad_testnet --private-key $(PRIVATE_KEY) --broadcast src/MissionContract.sol:MissionContract

deploy-base:
	@if [ -z "$(PRIVATE_KEY)" ]; then echo "Error: PRIVATE_KEY environment variable not set"; exit 1; fi
	forge create --rpc-url https://base-sepolia.drpc.org --private-key $(PRIVATE_KEY) --broadcast src/MissionContract.sol:MissionContract

deploy-linea:
	@if [ -z "$(PRIVATE_KEY)" ]; then echo "Error: PRIVATE_KEY environment variable not set"; exit 1; fi
	forge create --rpc-url https://rpc.sepolia.linea.build --private-key $(PRIVATE_KEY) --broadcast src/MissionContract.sol:MissionContract


test:
	forge test