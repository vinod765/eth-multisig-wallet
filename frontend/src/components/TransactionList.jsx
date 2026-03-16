import React from "react";
import TransactionCard from "./TransactionCard";

function TransactionList({ transactions, account, isOwner, required, loading, onApprove, onRevoke, onExecute, onCancel }) {
  return (
    <div>
      <h2 className="text-lg font-semibold text-slate-900 mb-4">Transactions</h2>
      {!transactions || transactions.length === 0 ? (
        <div className="bg-white rounded-xl p-8 text-center text-slate-400 border border-slate-100 shadow-sm">
          No transactions yet
        </div>
      ) : (
        <div className="space-y-3">
          {transactions.map((tx) => (
            <TransactionCard
              key={tx.id}
              tx={tx}
              account={account}
              isOwner={isOwner}
              required={required}
              loading={loading}
              onApprove={onApprove}
              onRevoke={onRevoke}
              onExecute={onExecute}
              onCancel={onCancel}
            />
          ))}
        </div>
      )}
    </div>
  );
}

export default TransactionList;