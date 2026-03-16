import React from "react";

import ConnectWallet from "./components/ConnectWallet";
import WalletInfo from "./components/WalletInfo";
import SubmitTransaction from "./components/SubmitTransaction";
import TransactionList from "./components/TransactionList";

import { useMultiSig } from "./hooks/useMultiSig";

function App() {
  const {
    account,
    isOwner,
    loading,
    error,
    required,
    ownerCount,
    transactions,
    connectWallet,
    submitTransaction,
    approveTransaction,
    revokeApproval,
    executeTransaction
  } = useMultiSig();

  return (
    <div style={{ padding: "20px", maxWidth: "900px", margin: "0 auto" }}>
      
      {/* Header */}
      <header
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          marginBottom: "20px"
        }}
      >
        <h1>MultiSig Wallet</h1>

        <ConnectWallet
          account={account}
          isOwner={isOwner}
          loading={loading}
          onConnect={connectWallet}
        />
      </header>

      {/* Error message */}
      {error && (
        <div
          style={{
            background: "#ffdddd",
            padding: "10px",
            borderRadius: "6px",
            marginBottom: "20px"
          }}
        >
          {error}
        </div>
      )}

      {/* Wallet UI */}
      {account && (
        <>
          <WalletInfo
            required={required}
            ownerCount={ownerCount}
            transactions={transactions}
          />

          <SubmitTransaction
            isOwner={isOwner}
            loading={loading}
            onSubmit={submitTransaction}
          />

          <TransactionList
            transactions={transactions}
            account={account}
            isOwner={isOwner}
            required={required}
            loading={loading}
            onApprove={approveTransaction}
            onRevoke={revokeApproval}
            onExecute={executeTransaction}
          />
        </>
      )}
    </div>
  );
}

export default App;