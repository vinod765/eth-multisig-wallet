import { useState, useCallback } from "react";
import { ethers } from "ethers";
import { CONTRACT_ADDRESS, ABI } from "../constants/contract";

export function useMultiSig() {
  const [provider, setProvider]       = useState(null);
  const [signer, setSigner]           = useState(null);
  const [contract, setContract]       = useState(null);
  const [account, setAccount]         = useState(null);
  const [isOwner, setIsOwner]         = useState(false);
  const [required, setRequired]       = useState(0);
  const [ownerCount, setOwnerCount]   = useState(0);
  const [transactions, setTransactions] = useState([]);
  const [loading, setLoading]         = useState(false);
  const [error, setError]             = useState(null);

  //connect wallet
  const connectWallet = useCallback(async () => {
    try {
      setError(null);
      setLoading(true);

      // check MetaMask exists
      if (!window.ethereum) {
        throw new Error("MetaMask not found. Please install it.");
      }

      // ask user to connect
      await window.ethereum.request({ method: "eth_requestAccounts" });

      // create provider — reads from the network
      const _provider = new ethers.BrowserProvider(window.ethereum);

      // create signer — represents the connected wallet
      const _signer = await _provider.getSigner();

      // get the connected address
      const _account = await _signer.getAddress();

      // create contract instance — needs address, ABI, and signer
      const _contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, _signer);

      // read contract state
      const _isOwner    = await _contract.isOwner(_account);
      const _required   = await _contract.required();
      const _ownerCount = await _contract.getOwnerCount();

      // update state
      setProvider(_provider);
      setSigner(_signer);
      setContract(_contract);
      setAccount(_account);
      setIsOwner(_isOwner);
      setRequired(Number(_required));
      setOwnerCount(Number(_ownerCount));

      // load all transactions
      await loadTransactions(_contract);

    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, []);

  // load all transactions
  const loadTransactions = useCallback(async (contractInstance) => {
    try {
      // use passed instance or state instance
      const _contract = contractInstance || contract;
      if (!_contract) return;

      // get total tx count by trying indices until it reverts
      // we do this by reading transactions array length via a workaround
      const txList = [];
      let i = 0;

      while (true) {
        try {
          const tx = await _contract.getTransaction(i);
          const approvers = await _contract.getApprovals(i);

          txList.push({
            id: i,
            to: tx.to,
            value: ethers.formatEther(tx.value),
            data: tx.data,
            executed: tx.executed,
            approvalCount: Number(tx.approvalCount),
            approvers: approvers,
          });
          i++;
        } catch {
          // no more transactions
          break;
        }
      }

      setTransactions(txList);
    } catch (err) {
      setError(err.message);
    }
  }, [contract]);

  //submit transaction
  const submitTransaction = useCallback(async (to, value, data = "0x") => {
    try {
      setError(null);
      setLoading(true);

      // convert ETH to wei — contract expects wei
      const valueInWei = ethers.parseEther(value.toString());

      const tx = await contract.submitTransaction(to, valueInWei, data);

      // wait for the transaction to be mined
      await tx.wait();

      // reload transactions to show the new one
      await loadTransactions();

    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [contract, loadTransactions]);

  //approve transaction
  const approveTransaction = useCallback(async (txId) => {
    try {
      setError(null);
      setLoading(true);

      const tx = await contract.approveTransaction(txId);
      await tx.wait();
      await loadTransactions();

    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [contract, loadTransactions]);

  //revoke approval
  const revokeApproval = useCallback(async (txId) => {
    try {
      setError(null);
      setLoading(true);

      const tx = await contract.revokeApproval(txId);
      await tx.wait();
      await loadTransactions();

    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [contract, loadTransactions]);

  //execute transaction
  const executeTransaction = useCallback(async (txId) => {
    try {
      setError(null);
      setLoading(true);

      const tx = await contract.executeTransaction(txId);
      await tx.wait();
      await loadTransactions();

    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [contract, loadTransactions]);

  return {
    // state
    account,
    isOwner,
    required,
    ownerCount,
    transactions,
    loading,
    error,
    // functions
    connectWallet,
    loadTransactions,
    submitTransaction,
    approveTransaction,
    revokeApproval,
    executeTransaction,
  };
}