import React from "react";

function WalletInfo({ required, ownerCount, transactions, balance }) {
  const stats = [
    { label: "Wallet Balance",     value: `${parseFloat(balance).toFixed(4)} ETH` },
    { label: "Required Approvals", value: required },
    { label: "Total Owners",       value: ownerCount },
    { label: "Total Transactions", value: transactions.length },
  ];

  return (
    <div className="grid grid-cols-4 gap-4 mb-6">
      {stats.map((stat) => (
        <div key={stat.label} className="bg-white rounded-xl p-5 shadow-sm border border-slate-100 text-center">
          <p className="text-3xl font-semibold text-slate-900">{stat.value}</p>
          <p className="text-sm text-slate-400 mt-1">{stat.label}</p>
        </div>
      ))}
    </div>
  );
}

export default WalletInfo;