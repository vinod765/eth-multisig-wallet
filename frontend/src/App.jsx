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
    balance,
    connectWallet,
    submitTransaction,
    approveTransaction,
    revokeApproval,
    cancelTransaction,
    executeTransaction,
  } = useMultiSig();

  return (
    <div style={{ minHeight: "100vh", background: "linear-gradient(135deg,#eef2ff,#f8fafc)", padding: "30px" }}>
      <div style={{ maxWidth: "950px", margin: "0 auto" }}>

        <header style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "40px" }}>
          <h1 style={{ fontSize: "26px", fontWeight: "600" }}>🔐 MultiSig Wallet</h1>
          {account && <ConnectWallet account={account} isOwner={isOwner} loading={loading} />}
        </header>

        {error && (
          <div style={{ background: "#fee2e2", padding: "12px", borderRadius: "8px", marginBottom: "20px" }}>
            {error}
          </div>
        )}

        {!account && (
          <div style={{ textAlign: "center", padding: "80px 20px", background: "white", borderRadius: "14px", boxShadow: "0 8px 30px rgba(0,0,0,0.06)" }}>
            <h2 style={{ fontSize: "34px", marginBottom: "10px" }}>Secure Shared Crypto Wallet</h2>
            <p style={{ color: "#64748b", marginBottom: "35px", maxWidth: "550px", marginInline: "auto" }}>
              A multi-signature wallet requires multiple approvals before a transaction can be executed.
              Perfect for DAOs, teams and shared treasury management.
            </p>
            <button
              onClick={connectWallet}
              disabled={loading}
              style={{ padding: "14px 26px", fontSize: "16px", borderRadius: "10px", border: "none", background: "#4f46e5", color: "white", cursor: "pointer", fontWeight: "600" }}
            >
              {loading ? "Connecting..." : "Connect Wallet"}
            </button>

            <div style={{ marginTop: "50px", display: "grid", gridTemplateColumns: "repeat(auto-fit,minmax(200px,1fr))", gap: "20px" }}>
              <Feature title="🔐 Secure"       text="Transactions require multiple approvals before execution." />
              <Feature title="👥 Shared Control" text="Perfect for teams managing funds together." />
              <Feature title="⚡ Transparent"   text="All proposals and approvals are visible on-chain." />
            </div>
          </div>
        )}

        {account && (
          <>
            <WalletInfo
              required={required}
              ownerCount={ownerCount}
              transactions={transactions}
              balance={balance}
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
              onCancel={cancelTransaction}
            />
          </>
        )}
      </div>
    </div>
  );
}

function Feature({ title, text }) {
  return (
    <div style={{ background: "#f8fafc", padding: "20px", borderRadius: "10px" }}>
      <h3 style={{ marginBottom: "8px" }}>{title}</h3>
      <p style={{ color: "#64748b", fontSize: "14px" }}>{text}</p>
    </div>
  );
}

export default App;