# Architecture

## Contract Design

MultiSigWallet.sol is a from-scratch implementation with no OpenZeppelin dependencies.

### Data Structures

- `address[] owners` — iterable list of all owners
- `mapping(address => bool) isOwner` — O(1) owner lookup
- `Transaction[] transactions` — all submitted transactions indexed by txId
- `mapping(uint => mapping(address => bool)) approved` — tracks which owner approved which tx

### Transaction Lifecycle

1. Owner calls `submitTransaction(to, value, data)` — stored on-chain, returns txId
2. Owners call `approveTransaction(txId)` — increments approvalCount
3. Any owner can `revokeApproval(txId)` — decrements approvalCount
4. Any owner can `cancelTransaction(txId)` — marks cancelled, blocks further action
5. Once approvalCount >= required, any owner calls `executeTransaction(txId)`

### Security Model

- Checks-Effects-Interactions: `executed = true` set before external call
- Custom ReentrancyGuard using `_status` flag
- Transaction expiry: 7 days from `createdAt` timestamp
- Duplicate owner prevention in constructor

## Frontend Architecture

- `useMultiSig.js` — single hook managing all contract state and interactions
- `constants/contract.js` — ABI and address, single source of truth
- Components are purely presentational — no contract logic
