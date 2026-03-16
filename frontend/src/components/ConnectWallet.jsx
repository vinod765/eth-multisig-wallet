import React from "react";

const shorten = (addr) => `${addr.slice(0, 6)}...${addr.slice(-4)}`;

function ConnectWallet({ account, isOwner, loading, onConnect }) {
  if (!account) {
    return (
      <button
        onClick={onConnect}
        disabled={loading}
        className="bg-slate-900 text-white px-5 py-2 rounded-full hover:bg-slate-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
      >
        {loading ? "Connecting..." : "Connect Wallet"}
      </button>
    );
  }

  return (
    <div className="flex items-center gap-2">
      <span className="font-mono text-sm bg-slate-100 px-3 py-1 rounded-full">
        {shorten(account)}
      </span>
      <span className={`text-xs px-2 py-1 rounded-full text-white ${isOwner ? "bg-green-500" : "bg-slate-400"}`}>
        {isOwner ? "Owner" : "Not Owner"}
      </span>
    </div>
  );
}

export default ConnectWallet;