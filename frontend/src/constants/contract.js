// Replace this after running: forge script script/Deploy.s.sol --rpc-url http://127.0.0.1:8545 --broadcast
export const CONTRACT_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

export const ABI = [
  //state-changing functions
  {
    type: "function",
    name: "submitTransaction",
    inputs: [
      { name: "_to",    type: "address" },
      { name: "_value", type: "uint256" },
      { name: "_data",  type: "bytes"   },
    ],
    outputs: [{ name: "txId", type: "uint256" }],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "approveTransaction",
    inputs: [{ name: "_txId", type: "uint256" }],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "revokeApproval",
    inputs: [{ name: "_txId", type: "uint256" }],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "cancelTransaction",
    inputs: [{ name: "_txId", type: "uint256" }],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "executeTransaction",
    inputs: [{ name: "_txId", type: "uint256" }],
    outputs: [],
    stateMutability: "nonpayable",
  },

  //view functions
  {
    type: "function",
    name: "getTransaction",
    inputs: [{ name: "_txId", type: "uint256" }],
    outputs: [
      { name: "to",            type: "address" },
      { name: "value",         type: "uint256" },
      { name: "data",          type: "bytes"   },
      { name: "executed",      type: "bool"    },
      { name: "cancelled",     type: "bool"    },
      { name: "approvalCount", type: "uint256" },
      { name: "createdAt",     type: "uint256" },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getApprovals",
    inputs: [{ name: "_txId", type: "uint256" }],
    outputs: [{ name: "", type: "address[]" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getOwnerCount",
    inputs: [],
    outputs: [{ name: "", type: "uint256" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "isOwner",
    inputs: [{ name: "", type: "address" }],
    outputs: [{ name: "", type: "bool" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "required",
    inputs: [],
    outputs: [{ name: "", type: "uint256" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "owners",
    inputs: [{ name: "", type: "uint256" }],
    outputs: [{ name: "", type: "address" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "TX_EXPIRY",
    inputs: [],
    outputs: [{ name: "", type: "uint256" }],
    stateMutability: "view",
  },

  //events
  {
    type: "event",
    name: "Submitted",
    inputs: [
      { name: "owner", type: "address", indexed: true  },
      { name: "txId",  type: "uint256", indexed: true  },
      { name: "to",    type: "address", indexed: true  },
      { name: "value", type: "uint256", indexed: false },
    ],
  },
  {
    type: "event",
    name: "Approved",
    inputs: [
      { name: "owner", type: "address", indexed: true },
      { name: "txId",  type: "uint256", indexed: true },
    ],
  },
  {
    type: "event",
    name: "Revoked",
    inputs: [
      { name: "owner", type: "address", indexed: true },
      { name: "txId",  type: "uint256", indexed: true },
    ],
  },
  {
    type: "event",
    name: "Executed",
    inputs: [
      { name: "txId", type: "uint256", indexed: true },
    ],
  },
  {
    type: "event",
    name: "Cancelled",
    inputs: [
      { name: "txId", type: "uint256", indexed: true },
    ],
  },
  {
    type: "event",
    name: "Deposited",
    inputs: [
      { name: "sender",  type: "address", indexed: true  },
      { name: "value",   type: "uint256", indexed: false },
      { name: "balance", type: "uint256", indexed: false },
    ],
  },
];