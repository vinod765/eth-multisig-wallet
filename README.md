# 🔐 Ethereum MultiSig Wallet

**multi-signature wallet** built from scratch in Solidity.

Requires M-of-N owner approvals before any transaction executes. Any owner can propose, each owner independently approves or revokes, and once the threshold is reached any owner can execute.

---

## ✨ Features

### Smart Contract
- Configurable M-of-N approval threshold
- Submit, approve, revoke, execute, and cancel transactions
- Transaction expiry — proposals expire after 7 days
- Reentrancy protection implemented from scratch (no OpenZeppelin)
- Checks-Effects-Interactions pattern enforced on execution
- Duplicate owner and zero address prevention in constructor
- On-chain transaction history with full event log

### Frontend
- MetaMask wallet connection
- Live wallet ETH balance display
- Submit new transactions with recipient, value, and calldata
- Approve, revoke, execute, and cancel with one click
- Transaction status badges — Pending, Ready, Executed, Cancelled
- Owner-aware UI — buttons shown based on connected account
- Real-time updates after every on-chain action

---

## 🏗 Tech Stack

| Layer | Technology |
|---|---|
| Smart Contract | Solidity ^0.8.20 |
| Development Framework | Foundry |
| Testing | Forge (41 tests) |
| Local Blockchain | Anvil |
| Frontend | React + Vite |
| Web3 Library | ethers.js v6 |
| Styling | Tailwind CSS |

---

## 📂 Project Structure
```
eth-multisig-wallet/
├── src/
│   └── MultiSigWallet.sol          # core contract
├── script/
│   ├── Deploy.s.sol                # deployment script
│   └── Interactions.s.sol
├── test/
│   ├── MultiSigWallet.t.sol        # 41 unit tests
│   └── helpers/
├── frontend/
│   └── src/
│       ├── components/
│       │   ├── ConnectWallet.jsx
│       │   ├── WalletInfo.jsx
│       │   ├── SubmitTransaction.jsx
│       │   ├── TransactionList.jsx
│       │   └── TransactionCard.jsx
│       ├── hooks/
│       │   └── useMultiSig.js      # all contract interaction logic
│       ├── constants/
│       │   └── contract.js         # ABI and contract address
│       └── App.jsx
├── docs/
│   └── architecture.md
├── foundry.toml
├── .env.example
├── .gitignore
└── README.md
```

---

## ⚙️ Prerequisites

- [Foundry](https://getfoundry.sh) — `curl -L https://foundry.paradigm.xyz | bash && foundryup`
- Node.js v18+
- MetaMask browser extension

---

## 🛠 Smart Contract Setup
```bash
# install dependencies
forge install

# compile
forge build

# run all 41 tests
forge test -vvv
```

---

## 🚀 Local Development

### 1. Start local blockchain
```bash
anvil
```

### 2. Set up environment
```bash
cp .env.example .env
```

Fill in `.env`:
```bash
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
OWNER1=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
OWNER2=0x70997970C51812dc3A010C7d01b50e0d17dc79C8
OWNER3=0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC
```

These are Anvil's default test accounts — safe for local use only.

### 3. Deploy contract
```bash
forge script script/Deploy.s.sol --rpc-url http://127.0.0.1:8545 --broadcast
```

Copy the deployed address and update `frontend/src/constants/contract.js`.

### 4. Fund the wallet
```bash
cast send CONTRACT_ADDRESS \
  --value 2ether \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --rpc-url http://127.0.0.1:8545
```

### 5. Run the frontend
```bash
cd frontend
npm install
npm run dev
```

Open `http://localhost:5173` and connect MetaMask to Anvil Local (Chain ID: 31337).

---

## 🔄 Transaction Lifecycle
```
Owner submits transaction
        ↓
Owners independently approve
        ↓
Threshold reached (M of N)
        ↓
Any owner executes → ETH/calldata sent
```

Owners can also:
- **Revoke** their approval before execution
- **Cancel** a transaction before it reaches threshold
- Transactions **expire** after 7 days automatically

---

## 🧪 Testing

41 tests covering every path:
```bash
forge test -vvv
```

| Category | Tests |
|---|---|
| Constructor validation | 7 |
| Submit transaction | 3 |
| Approve transaction | 6 |
| Revoke approval | 4 |
| Execute transaction | 6 |
| ETH receipt | 3 |
| Cancel transaction | 8 |
| Expiry | 3 |
| View functions | 1 |

---

## 🔒 Security

| Mechanism | Implementation |
|---|---|
| Reentrancy guard | Custom `_status` flag, no OpenZeppelin |
| CEI pattern | `executed = true` before external call |
| Duplicate owner check | Constructor loop with `isOwner` mapping |
| Zero address check | Constructor validation |
| Approval tracking | `mapping(txId => mapping(address => bool))` |
| Transaction expiry | `block.timestamp` check against `createdAt + 7 days` |

---

## 📌 Future Improvements

- Owner management — add/remove owners after deployment
- ERC20 token support
- Event-based indexing with subgraph
- Transaction batching
- Testnet deployment and Etherscan verification
- UI improvements inspired by Gnosis Safe

---

## 📜 License

MIT

---