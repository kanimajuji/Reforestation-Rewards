# 🌳 Reforestation Rewards Contract

> A blockchain-based incentive system for environmental conservation through verified tree planting

## 🌟 Overview

The Reforestation Rewards smart contract creates a decentralized ecosystem where individuals can plant trees, verify plantings through community consensus, and earn STX rewards for their environmental contributions. This contract promotes global reforestation efforts while maintaining transparency and accountability through blockchain technology.

## ✨ Key Features

🌱 **Tree Planting Registry**: Register new tree plantings with species and location data  
🔍 **Community Verification**: Decentralized verification system requiring multiple confirmations  
💰 **Automatic Rewards**: Earn STX tokens for verified tree plantings  
📊 **User Statistics**: Track planting history, rewards, and reputation scores  
🎯 **Governance Controls**: Administrative functions for contract management  
🏆 **Reputation System**: Build credibility through verified environmental contributions  

## 🚀 Quick Start

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for testing
- Node.js for running tests

### Installation

```bash
git clone <your-repo>
cd Reforestation-Rewards
clarinet check
npm install
npm test
```

## 📖 Contract Functions

### 🌱 Core Functions

#### `plant-tree`
Register a new tree planting in the system.

```clarity
(plant-tree "Oak" "Central Park, NYC")
```

**Parameters:**
- `species`: Tree species name (max 50 characters)
- `location`: Planting location (max 100 characters)

**Returns:** Tree ID for tracking

#### `verify-tree`
Verify an existing tree planting (requires community consensus).

```clarity
(verify-tree u1 "Confirmed healthy sapling planted")
```

**Parameters:**
- `tree-id`: ID of the tree to verify
- `notes`: Verification notes (max 200 characters)

**Returns:** Boolean indicating if tree is now fully verified

#### `claim-reward`
Claim STX rewards for a verified tree planting.

```clarity
(claim-reward u1)
```

**Parameters:**
- `tree-id`: ID of verified tree

**Returns:** Amount of STX claimed

### 💰 Financial Functions

#### `fund-contract`
Add STX to the reward pool (anyone can contribute).

```clarity
(fund-contract u1000)
```

### 🔧 Admin Functions (Contract Owner Only)

#### `set-reward-amount`
Adjust the STX reward per verified tree.

```clarity
(set-reward-amount u150)
```

#### `set-verification-threshold`
Change how many verifications are needed for tree approval.

```clarity
(set-verification-threshold u5)
```

#### `deactivate-verifier`
Remove a verifier from the active pool.

```clarity
(deactivate-verifier 'ST1VERIFIER...)
```

## 📊 Read-Only Functions

### `get-tree`
Retrieve complete information about a specific tree.

### `get-user-stats`
Get user's planting statistics and rewards earned.

### `get-contract-stats`
View overall contract metrics including:
- Total trees planted
- Total rewards distributed
- Current contract balance
- Reward amount per tree
- Verification threshold

### `is-tree-verified`
Check if a specific tree has been verified.

## 🎮 Usage Examples

### Planting Your First Tree

1. **Plant a tree:**
```clarity
(contract-call? .reforestation-rewards plant-tree "Maple" "Brooklyn Bridge Park")
```

2. **Get community verification:**
Share your tree ID with the community for verification

3. **Claim your reward:**
Once verified by enough community members:
```clarity
(contract-call? .reforestation-rewards claim-reward u1)
```

### Becoming a Verifier

Help verify others' tree plantings to build reputation:

```clarity
(contract-call? .reforestation-rewards verify-tree u5 "Healthy oak sapling, properly planted with mulch")
```

## 🔒 Security Features

- **Self-verification prevention**: Users cannot verify their own trees
- **Double verification protection**: Prevents multiple verifications from same user
- **Fund safety**: Contract balance tracking prevents overpayment
- **Owner controls**: Administrative functions restricted to contract deployer

## 📈 Contract Economics

- **Default reward**: 100 μSTX per verified tree
- **Verification threshold**: 3 independent confirmations required
- **Reputation system**: Rewards both planters and verifiers
- **Community funding**: Anyone can contribute to the reward pool

## 🧪 Testing

Run the test suite:

```bash
npm test
```

Tests cover:
- Tree planting workflows
- Verification processes  
- Reward claiming
- Administrative functions
- Error conditions

## 🌍 Contributing

We welcome contributions to improve reforestation efforts!

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

## 📄 License

This project is open source and available under the MIT License.

## 🤝 Community

Join our mission to reforest the planet through blockchain technology!

---

**Made with 💚 for the planet** 🌍

# Reforestation Rewards

