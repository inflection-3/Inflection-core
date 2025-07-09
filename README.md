# MissionContract

A Solidity smart contract for managing missions and organizations built with [Foundry](https://book.getfoundry.sh/).

## Overview

MissionContract is a smart contract that allows:
- **Admin** to add organizations and manage missions
- **Organizations** to create missions for their cause
- **Users** to complete missions and get recorded on-chain
- **Transparent tracking** of all mission completions

## Features

- 🏢 **Organization Management**: Add and manage organizations
- 🎯 **Mission Creation**: Create missions for organizations
- ✅ **Mission Completion**: Track when users complete missions
- 🔐 **Access Control**: Admin and organization-level permissions
- 📊 **Transparent Tracking**: All actions recorded on-chain

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed
- [Git](https://git-scm.com/) for version control
- A wallet with some ETH for deployment (testnet or mainnet)

## Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd MissionContract
```

2. Install dependencies:
```bash
forge install
```

3. Build the project:
```bash
forge build
```

## Quick Start with Makefile

For convenience, you can use the included Makefile commands instead of typing the full forge commands:

### Set Private Key
```bash
export PRIVATE_KEY=<YOUR_PRIVATE_KEY>
```

### Available Make Commands
```bash
make build      # Compile contracts
make test       # Run tests
make deploy     # Deploy to Base Sepolia testnet
```

**Note**: The Makefile deploy command is configured for Base Sepolia testnet (https://84532.rpc.thirdweb.com). To use this, set the PRIVATE_KEY environment variable before running commands:

```bash
export PRIVATE_KEY=<YOUR_PRIVATE_KEY>
make deploy
```

### Makefile vs Forge Commands

| Makefile Command | Equivalent Forge Command |
|------------------|--------------------------|
| `make build`     | `forge build`            |
| `make test`      | `forge test`             |
| `make deploy`    | `forge create --rpc-url https://84532.rpc.thirdweb.com --private-key $PRIVATE_KEY src/MissionContract.sol:MissionContract` |

### Quick Makefile Workflow

```bash
# 1. Set your private key
export PRIVATE_KEY=your_private_key_here

# 2. Build the project
make build

# 3. Run tests
make test

# 4. Deploy to Base Sepolia
make deploy
```

## Testing

### Run All Tests
```bash
forge test
```

### Run Tests with Verbosity
```bash
forge test -v        # Show test names
forge test -vv       # Show test names and logs
forge test -vvv      # Show test names, logs, and traces
forge test -vvvv     # Show test names, logs, traces, and debug info
```

### Run Specific Test
```bash
forge test --match-test test_AddOrganization
```

### Run Tests for Specific Contract
```bash
forge test --match-contract MissionContractTest
```

### Generate Test Coverage Report
```bash
forge coverage
```

## Deployment

### Environment Setup

Create a `.env` file in the root directory:
```env
# Private key for deployment (without 0x prefix)
PRIVATE_KEY=your_private_key_here

# RPC URLs for different networks
MAINNET_RPC_URL=https://mainnet.infura.io/v3/your_infura_key
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/your_infura_key
POLYGON_RPC_URL=https://polygon-mainnet.infura.io/v3/your_infura_key
ARBITRUM_RPC_URL=https://arbitrum-mainnet.infura.io/v3/your_infura_key

# Etherscan API keys for verification
ETHERSCAN_API_KEY=your_etherscan_api_key
POLYGONSCAN_API_KEY=your_polygonscan_api_key
ARBISCAN_API_KEY=your_arbiscan_api_key
```

**⚠️ Important**: Never commit your `.env` file to version control. Add it to `.gitignore`.

### Load Environment Variables

**Option 1: Using .env file**
```bash
source .env
```

**Option 2: Export directly (recommended for Makefile)**
```bash
export PRIVATE_KEY=<YOUR_PRIVATE_KEY>
export SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/your_infura_key
# ... other variables as needed
```

**💡 Tip**: For Makefile usage, the export command is often more convenient as it sets variables for the current shell session.

### Local Development

Start a local Anvil node:
```bash
anvil
```

Deploy to local network:
```bash
forge script script/MissionContract.s.sol:MissionContractScript \
  --rpc-url http://localhost:8545 \
  --private-key $PRIVATE_KEY \
  --broadcast
```

### Testnet Deployment

#### Sepolia (Ethereum Testnet)
```bash
forge script script/MissionContract.s.sol:MissionContractScript \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

#### Polygon Mumbai (Polygon Testnet)
```bash
forge script script/MissionContract.s.sol:MissionContractScript \
  --rpc-url https://rpc-mumbai.maticvigil.com \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $POLYGONSCAN_API_KEY
```

### Mainnet Deployment

#### Ethereum Mainnet
```bash
forge script script/MissionContract.s.sol:MissionContractScript \
  --rpc-url $MAINNET_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

#### Polygon Mainnet
```bash
forge script script/MissionContract.s.sol:MissionContractScript \
  --rpc-url $POLYGON_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $POLYGONSCAN_API_KEY
```

### Deploy with Sample Data

To deploy with sample organizations and missions:
```bash
forge script script/MissionContract.s.sol:MissionContractScript \
  --sig "runWithSampleData()" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

## Alternative Private Key Methods

### 1. Using Keystore Files (Recommended for Production)
```bash
# Create a keystore file
cast wallet import deployer --interactive

# Deploy using keystore
forge script script/MissionContract.s.sol:MissionContractScript \
  --rpc-url $SEPOLIA_RPC_URL \
  --account deployer \
  --sender 0xYourWalletAddress \
  --broadcast
```

### 2. Using Ledger Hardware Wallet
```bash
forge script script/MissionContract.s.sol:MissionContractScript \
  --rpc-url $SEPOLIA_RPC_URL \
  --ledger \
  --sender 0xYourLedgerAddress \
  --broadcast
```

### 3. Using Interactive Mode
```bash
forge script script/MissionContract.s.sol:MissionContractScript \
  --rpc-url $SEPOLIA_RPC_URL \
  --interactive \
  --broadcast
```

## Contract Verification

### Verify on Etherscan
```bash
forge verify-contract \
  --chain-id 11155111 \
  --num-of-optimizations 200 \
  --watch \
  --constructor-args $(cast abi-encode "constructor()") \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --compiler-version v0.8.29+commit.e5e5eca2 \
  0xYourContractAddress \
  src/MissionContract.sol:MissionContract
```

## Useful Forge Commands

### Build and Compilation
```bash
forge build                    # Compile contracts
forge clean                    # Clean build artifacts
forge fmt                      # Format code
forge tree                     # Show dependency tree
```

### Testing
```bash
forge test                     # Run tests
forge test --gas-report        # Run tests with gas report
forge snapshot                 # Create gas snapshots
forge coverage                 # Generate coverage report
```

### Deployment and Interaction
```bash
forge create                   # Deploy a contract
forge script                   # Run deployment scripts
forge cast                     # Interact with contracts
```

### Debug and Analysis
```bash
forge debug                    # Debug transactions
forge inspect                  # Inspect contracts
forge flatten                  # Flatten source code
```

## Contract Interaction Examples

### Using Cast Commands

```bash
# Get contract admin
cast call 0xYourContractAddress "admin()" --rpc-url $SEPOLIA_RPC_URL

# Get organization count
cast call 0xYourContractAddress "getOrganizationCount()" --rpc-url $SEPOLIA_RPC_URL

# Get mission count
cast call 0xYourContractAddress "missionCount()" --rpc-url $SEPOLIA_RPC_URL

# Add organization (admin only)
cast send 0xYourContractAddress \
  "addOrganization(address,string,string)" \
  0xOrgWalletAddress \
  "Organization Name" \
  "Organization Description" \
  --private-key $PRIVATE_KEY \
  --rpc-url $SEPOLIA_RPC_URL

# Add mission
cast send 0xYourContractAddress \
  "addMission(string,address)" \
  "Mission Description" \
  0xOrgWalletAddress \
  --private-key $PRIVATE_KEY \
  --rpc-url $SEPOLIA_RPC_URL
```

## Security Best Practices

1. **Never commit private keys** to version control
2. **Use environment variables** for sensitive data
3. **Test thoroughly** before mainnet deployment
4. **Verify contracts** on block explorers
5. **Use hardware wallets** for production deployments
6. **Double-check addresses** before sending transactions
7. **Start with testnets** before mainnet

## Project Structure

```
MissionContract/
├── src/
│   └── MissionContract.sol     # Main contract
├── test/
│   └── MissionContract.t.sol   # Test suite
├── script/
│   └── MissionContract.s.sol   # Deployment scripts
├── lib/
│   └── forge-std/              # Foundry standard library
├── .env                        # Environment variables (create this)
├── .env.example               # Environment variables template
├── .gitignore                  # Git ignore file
├── foundry.toml               # Foundry configuration
├── makefile                   # Make commands for easy development
└── README.md                  # This file
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For questions or issues, please open an issue in the GitHub repository.
# mission-contract
