import React from "react";

const shorten = (addr) => `${addr.slice(0, 6)}...${addr.slice(-4)}`;

function TransactionCard({ tx, account, isOwner, required, loading, onApprove, onRevoke, onExecute, onCancel }) {
  const hasApproved = tx.approvers.map(a => a.toLowerCase()).includes(account?.toLowerCase());

  const canExecute = tx.approvalCount >= required && !tx.executed && !tx.cancelled;

  const canCancel =
    !tx.executed &&
    !tx.cancelled &&
    tx.approvalCount < required;

  const handleCancel = () => {
    const confirmCancel = window.confirm(
      "Are you sure you want to cancel this transaction?"
    );

    if (confirmCancel) {
      onCancel(tx.id);
    }
  };

  return (
    <div className="bg-white rounded-xl p-5 shadow-sm border border-slate-100">
      <div className="flex justify-between items-start mb-3">
        <h3 className="font-semibold text-slate-900">Transaction #{tx.id}</h3>

        {tx.executed ? (
          <span className="bg-green-100 text-green-700 text-xs px-2 py-1 rounded-full">
            Executed
          </span>
        ) : tx.cancelled ? (
          <span className="bg-red-100 text-red-700 text-xs px-2 py-1 rounded-full">
            Cancelled
          </span>
        ) : tx.approvalCount >= required ? (
          <span className="bg-blue-100 text-blue-700 text-xs px-2 py-1 rounded-full">
            Ready
          </span>
        ) : (
          <span className="bg-amber-100 text-amber-700 text-xs px-2 py-1 rounded-full">
            Pending
          </span>
        )}
      </div>

      <div className="space-y-1 text-sm text-slate-600 mb-4">
        <p>
          <span className="text-slate-400">To:</span>{" "}
          <span className="font-mono">{shorten(tx.to)}</span>
        </p>

        <p>
          <span className="text-slate-400">Value:</span> {tx.value} ETH
        </p>

        <p>
          <span className="text-slate-400">Approvals:</span>{" "}
          {tx.approvalCount} / {required}
        </p>
      </div>

      {tx.approvers.length > 0 && (
        <div className="mb-4">
          <p className="text-xs text-slate-400 mb-1">Approvers</p>

          <div className="flex flex-wrap gap-1">
            {tx.approvers.map((addr) => (
              <span
                key={addr}
                className="font-mono text-xs bg-slate-100 px-2 py-0.5 rounded-full"
              >
                {shorten(addr)}
              </span>
            ))}
          </div>
        </div>
      )}

      {!tx.executed && !tx.cancelled && isOwner && (
        <div className="flex gap-2 mt-2">

          {!hasApproved && (
            <button
              onClick={() => onApprove(tx.id)}
              disabled={loading}
              className="bg-green-500 text-white text-xs px-3 py-1.5 rounded-lg hover:bg-green-600 disabled:opacity-50 transition-colors"
            >
              Approve
            </button>
          )}

          {hasApproved && tx.approvalCount < required && (
            <button
              onClick={() => onRevoke(tx.id)}
              disabled={loading}
              className="bg-amber-500 text-white text-xs px-3 py-1.5 rounded-lg hover:bg-amber-600 disabled:opacity-50 transition-colors"
            >
              Revoke
            </button>
          )}

          {canExecute && (
            <button
              onClick={() => onExecute(tx.id)}
              disabled={loading}
              className="bg-blue-600 text-white text-xs px-3 py-1.5 rounded-lg hover:bg-blue-700 disabled:opacity-50 transition-colors"
            >
              Execute
            </button>
          )}

          {canCancel && (
            <button
              onClick={handleCancel}
              disabled={loading}
              className="bg-red-500 text-white text-xs px-3 py-1.5 rounded-lg hover:bg-red-600 disabled:opacity-50 transition-colors"
            >
              Cancel
            </button>
          )}

        </div>
      )}
    </div>
  );
}

export default TransactionCard;