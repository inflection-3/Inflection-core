# Mission Contract System

A comprehensive smart contract system for managing missions, applications, interactions, and USDC rewards on Base blockchain.

## 🏗️ Architecture

- **MissionFactory**: Deploys individual mission contracts
- **Mission**: Individual mission contracts with applications, interactions, and rewards
- **MissionContract**: Central hub for managing missions and their lifecycle
- **Interfaces**: IUSDC and IMission for type safety

## 🚀 Quick Start

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Node.js](https://nodejs.org/) (for deployed contract testing)
- Base Sepolia or Base Mainnet RPC access

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   forge install
   ```

3. Copy environment variables:
   ```bash
   cp env.example .env
   ```

4. Fill in your `.env` file with:
   - `PRIVATE_KEY`: Your private key (without 0x prefix)
   - `USDC_ADDRESS`: USDC contract address for the network
   - `ETHERSCAN_API_KEY`: For contract verification

### USDC Addresses

- **Base Sepolia**: `0x036CbD53842c5426634e7929541eC2318f3dCF7e`
- **Base Mainnet**: `0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913`

## 🧪 Testing

### Local Testing

```bash
# Run all tests
make test

# Run tests with verbose output
make test-verbose

# Clean build artifacts
make clean
```

### Deployed Contract Testing

```bash
# Deploy and test on Base Sepolia
make deploy-and-test-sepolia

# Deploy and test on Base Mainnet
make deploy-and-test-mainnet
```

## 🚀 Deployment

### Base Sepolia (Testnet)

```bash
# Deploy to Base Sepolia
make deploy-sepolia

# Verify contracts
make verify-sepolia

# Test deployed contracts
make test-deployed-sepolia
```

### Base Mainnet

```bash
# Deploy to Base Mainnet
make deploy-mainnet

# Verify contracts
make verify-mainnet

# Test deployed contracts
make test-deployed-mainnet
```

## 📋 Available Commands

| Command | Description |
|---------|-------------|
| `make build` | Build contracts |
| `make test` | Run local tests |
| `make test-verbose` | Run tests with verbose output |
| `make clean` | Clean build artifacts |
| `make deploy-sepolia` | Deploy to Base Sepolia |
| `make deploy-mainnet` | Deploy to Base Mainnet |
| `make verify-sepolia` | Verify contracts on Base Sepolia |
| `make verify-mainnet` | Verify contracts on Base Mainnet |
| `make test-deployed-sepolia` | Test deployed contracts on Base Sepolia |
| `make test-deployed-mainnet` | Test deployed contracts on Base Mainnet |
| `make deploy-and-test-sepolia` | Full pipeline for Base Sepolia |
| `make deploy-and-test-mainnet` | Full pipeline for Base Mainnet |

## 🔧 Manual Script Usage

### Deployment Script

```bash
# Deploy to Base Sepolia
./scripts/deploy.sh sepolia

# Deploy to Base Mainnet
./scripts/deploy.sh mainnet
```

### Verification Script

```bash
# Verify on Base Sepolia
./scripts/verify.sh sepolia

# Verify on Base Mainnet
./scripts/verify.sh mainnet
```

### Testing Script

```bash
# Test deployed contracts on Base Sepolia
./scripts/test-deployed.sh sepolia

# Test deployed contracts on Base Mainnet
./scripts/test-deployed.sh mainnet
```

## 📊 Test Coverage

- **24/24 tests passing** ✅
- **MissionFactory Tests (9/9)**: Factory deployment, mission creation, ownership management
- **Mission Tests (12/12)**: Applications, interactions, participants, rewards, claiming
- **MissionContract Tests (3/3)**: Central hub functionality, mission management

## 🏗️ Contract Features

### MissionFactory
- Deploy individual mission contracts
- Track all deployed missions
- Transfer mission ownership
- Emergency USDC recovery

### Mission
- Add applications with metadata
- Create interactions with rewards
- Add participants who completed interactions
- Deposit USDC rewards
- Distribute rewards equally among participants
- Allow participants to claim rewards
- Deactivate applications and interactions

### MissionContract
- Central hub for mission management
- Create and register missions
- Add applications and interactions to missions
- Manage participants
- Deposit and distribute rewards
- Track mission statistics

## 🔒 Security Features

- **Ownable**: Only contract owners can perform administrative functions
- **ReentrancyGuard**: Prevents reentrancy attacks
- **Input Validation**: Comprehensive parameter validation
- **Access Control**: Role-based access control
- **Emergency Functions**: Recovery functions for stuck funds

## 📝 License

MIT License - see LICENSE file for details

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📞 Support

For questions or support, please open an issue on GitHub.