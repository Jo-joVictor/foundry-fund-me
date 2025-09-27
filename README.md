# 🏫 School DAO

A decentralized autonomous organization (DAO) for educational institutions, enabling democratic governance, transparent fee payments, and token-based incentives for staff members.

## 📋 Overview

School DAO is a comprehensive blockchain solution that modernizes school governance through:
- **Democratic Voting**: Staff members vote on proposals using governance tokens
- **Transparent Fee Payments**: Students pay school fees directly on-chain
- **Staff Incentives**: Token airdrops for educational staff members
- **Decentralized Decision Making**: Community-driven school policy changes

## 🚀 Features

### 🗳️ Governance System
- Proposal creation for school policy changes
- Token-weighted voting mechanism
- Timelock controller for secure execution
- Quorum requirements for proposal validation

### 💰 Fee Payment System
- On-chain school fee payments
- Transparent transaction records
- Configurable fee structures
- Automatic refund handling

### 🎁 Staff Airdrop
- Merkle tree-based token distribution
- Cryptographic proof verification
- One-time claim mechanism
- Staff member eligibility checking

### 🌐 Frontend Interface
- MetaMask wallet integration
- Responsive web design
- Real-time balance updates
- Intuitive governance dashboard

## 🛠️ Technology Stack

### Smart Contracts
- **Solidity ^0.8.20**
- **OpenZeppelin Contracts** (Governor, ERC20Votes, TimelockController)
- **Merkle Proof** for airdrop verification

### Frontend
- **React** with modern hooks
- **Tailwind CSS** for styling
- **Lucide React** icons
- **Native Web3** integration

### Blockchain
- **Ethereum Sepolia Testnet**
- **MetaMask** wallet support

## 📦 Contract Architecture

```
├── SchoolGovernor.sol      # Main governance contract
├── VotingToken.sol         # ERC20 voting token (SVT)
├── SchoolConfig.sol        # Fee management & configuration
├── Timelock.sol           # Execution delay controller
└── Airdrop.sol            # Staff token distribution
```

## 🔧 Installation & Setup

### Prerequisites
- Node.js 16+ and npm
- MetaMask browser extension
- Sepolia ETH for transactions

### Frontend Setup
1. Clone the repository:
```bash
git clone https://github.com/yourusername/school-dao.git
cd school-dao
```

2. Install dependencies:
```bash
npm install
```

3. Update contract addresses in the frontend:
```javascript
const CONTRACT_ADDRESSES = {
  governance: "0x...",      // Your deployed governance contract
  schoolConfig: "0x...",    // Your deployed school config contract  
  votingToken: "0x...",     // Your deployed voting token contract
  airdrop: "0x..."          // Your deployed airdrop contract
};
```

4. Start the development server:
```bash
npm start
```

## 🎯 Usage Guide

### For Staff Members (Governance Participants)
1. **Connect Wallet**: Use MetaMask to connect to the application
2. **Delegate Voting Power**: Self-delegate to activate your voting power
3. **Create Proposals**: Submit proposals for school policy changes
4. **Vote on Proposals**: Cast votes (For/Against/Abstain) on active proposals
5. **Claim Airdrop**: Claim your allocated governance tokens

### For Students (Fee Payers)
1. **Connect Wallet**: Connect your MetaMask wallet
2. **View Current Fee**: Check the current school fee amount
3. **Pay Fees**: Submit fee payment directly on-chain
4. **Transaction Confirmation**: Receive blockchain confirmation

### For Administrators
1. **Monitor Proposals**: Track all governance proposals and votes
2. **Execute Proposals**: Execute successful proposals after timelock
3. **Update Configuration**: Modify school settings through governance

## 🏛️ Governance Process

1. **Proposal Creation**: Staff members create proposals for school changes
2. **Voting Period**: 1-week voting window for all participants
3. **Quorum Check**: Minimum 3 votes required for proposal validity
4. **Timelock Queue**: Successful proposals enter timelock period
5. **Execution**: Approved proposals automatically execute

## 🎁 Airdrop Mechanism

The staff airdrop uses a Merkle tree for efficient and secure token distribution:

- **Eligibility**: Pre-approved staff member addresses
- **Amount**: 1000 SVT tokens per eligible staff member
- **Proof**: Cryptographic merkle proofs for verification
- **Security**: Signature-based claim validation

## 🔐 Security Features

- **Multi-signature** governance execution
- **Timelock delays** for critical changes
- **Merkle proof** verification for airdrops
- **Reentrancy protection** on all contracts
- **Access control** for administrative functions

## 📊 Contract Addresses (Sepolia)

Update these with your deployed contract addresses:

```
Governance Contract: 0x...
School Config: 0x...
Voting Token (SVT): 0x...
Airdrop Contract: 0x...
Timelock Controller: 0x...
```

## 🧪 Testing

The contracts have been tested and deployed on Sepolia testnet. Key test scenarios include:

- ✅ Proposal creation and voting
- ✅ Fee payment functionality  
- ✅ Airdrop claiming mechanism
- ✅ Governance execution via timelock
- ✅ Token delegation and voting power

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- **Frontend Demo**: [Live Demo](https://your-school-dao.vercel.app)
- **Sepolia Testnet**: [Etherscan](https://sepolia.etherscan.io)
- **Documentation**: [Governance Docs](./docs/governance.md)

## ⚠️ Disclaimer

This is experimental software. Use at your own risk. Not audited for mainnet deployment.

## 📞 Support

For questions and support:
- Open an issue on GitHub
- Join our [Discord community](https://discord.gg/your-invite)
- Email: support@schooldao.org

---

**Built with ❤️ for educational institutions embracing decentralized governance**