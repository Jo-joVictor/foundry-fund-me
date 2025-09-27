# FundMe Smart Contract

A decentralized crowdfunding smart contract built with Solidity and Foundry that accepts ETH donations with USD-based minimum requirements using Chainlink price feeds.

## Features

- **USD-based funding**: Minimum $50 funding requirement enforced through Chainlink price feeds
- **Real-time price conversion**: ETH to USD conversion using Chainlink oracles
- **Owner-controlled withdrawals**: Only contract owner can withdraw collected funds
- **Gas optimization**: Two withdrawal methods (standard and gas-optimized)
- **Multi-network support**: Deployable on Ethereum mainnet, Sepolia, Goerli, and local networks
- **Comprehensive testing**: Unit, integration, and deployment tests included

## Quick Start

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

### Installation

```bash
git clone <your-repo-url>
cd foundry-fundme
make install
```

### Environment Setup

Create a `.env` file:
```bash
SEPOLIA_RPC_URL=your_sepolia_rpc_url
PRIVATE_KEY=your_private_key
ETHERSCAN_API_KEY=your_etherscan_api_key
```

## Usage

### Deploy

```bash
# Deploy to local anvil
make deploy

# Deploy to Sepolia testnet
make deploy ARGS="--network sepolia"
```

### Fund the Contract

```bash
# Using Forge scripts
make fund ARGS="--network sepolia"

# Using Cast directly
make cast-fund
```

### Withdraw Funds (Owner Only)

```bash
# Using Forge scripts
make withdraw ARGS="--network sepolia"

# Using Cast directly  
make cast-withdraw
```

### Check Contract Status

```bash
# Check contract balance
make cast-balance

# Check owner address
make cast-owner

# Check current ETH price
make cast-price

# Check number of funders
make cast-funders
```

## Contract Architecture

### Core Contracts

- **FundMe.sol**: Main crowdfunding contract
- **PriceConverter.sol**: Library for ETH/USD price conversions using Chainlink

### Deployment Scripts

- **DeployFundMe.s.sol**: Main deployment script
- **HelperConfig.s.sol**: Network configuration management
- **Interactions.s.sol**: Contract interaction scripts

### Key Functions

- `fund()`: Accept ETH donations (minimum $50 USD equivalent)
- `withdraw()`: Withdraw all funds (owner only)
- `cheaperWithdraw()`: Gas-optimized withdrawal (owner only)
- `getConversionRate(uint256)`: Convert ETH amount to USD
- `getCurrentPrice()`: Get current ETH price in USD

## Testing

Run the complete test suite:

```bash
# Run all tests
make test

# Run tests with verbose output
forge test -vvv

# Run specific test files
forge test --match-path test/unit/FundMeTest.t.sol
forge test --match-path test/integration/InteractionsTest.t.sol
```

### Test Coverage

- **Unit Tests**: Core contract functionality
- **Integration Tests**: End-to-end interaction testing
- **Deployment Tests**: Deployment script verification
- **Mock Tests**: Local testing with price feed mocks

## Network Configuration

The contract supports multiple networks through HelperConfig:

- **Ethereum Mainnet**: Uses live Chainlink ETH/USD feed
- **Sepolia Testnet**: Uses Sepolia Chainlink ETH/USD feed
- **Goerli Testnet**: Uses Goerli Chainlink ETH/USD feed
- **Local Anvil**: Deploys mock price feeds for testing

## Security Features

- **Access Control**: Withdrawal restricted to contract owner
- **Input Validation**: Minimum funding amount enforced
- **Price Feed Integration**: Real-time price data prevents stale price exploits
- **Custom Errors**: Gas-efficient error handling
- **Reentrancy Protection**: Safe external calls pattern

## Gas Optimization

- Custom errors instead of require strings
- Efficient storage patterns with mappings
- Gas-optimized withdrawal function available
- Immutable variables where applicable

## Deployed Contracts

### Sepolia Testnet
- **FundMe Contract**: `0x383F4CFca357e2F9E1C9BaF69f0eaF24a1b8CA22`
- **Verified on Etherscan**: [View Contract](https://sepolia.etherscan.io/address/0x383f4cfca357e2f9e1c9baf69f0eaf24a1b8ca22)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Resources

- [Foundry Documentation](https://book.getfoundry.sh/)
- [Chainlink Price Feeds](https://docs.chain.link/data-feeds/price-feeds)
- [Solidity Documentation](https://docs.soliditylang.org/)
