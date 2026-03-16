import React, { useState } from "react";

function SubmitTransaction({ isOwner, loading, onSubmit }) {
  const [to, setTo]     = useState("");
  const [value, setValue] = useState("");
  const [data, setData]   = useState("0x");

  if (!isOwner) return null;

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!to || !value) return;
    await onSubmit(to, value, data);
    setTo("");
    setValue("");
    setData("0x");
  };

  const inputClass = "w-full border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900";

  return (
    <div className="bg-white rounded-xl p-6 shadow-sm border border-slate-100">
      <h2 className="text-lg font-semibold text-slate-900 mb-4">Submit Transaction</h2>
      <form onSubmit={handleSubmit} className="space-y-3">
        <input
          type="text"
          placeholder="Recipient address (0x...)"
          value={to}
          onChange={(e) => setTo(e.target.value)}
          className={inputClass}
        />
        <input
          type="text"
          placeholder="ETH value (e.g. 0.1)"
          value={value}
          onChange={(e) => setValue(e.target.value)}
          className={inputClass}
        />
        <input
          type="text"
          placeholder="Calldata (hex, optional)"
          value={data}
          onChange={(e) => setData(e.target.value)}
          className={inputClass}
        />
        <button
          type="submit"
          disabled={loading}
          className="w-full bg-slate-900 text-white py-2 rounded-lg hover:bg-slate-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors text-sm font-medium"
        >
          {loading ? "Submitting..." : "Submit Transaction"}
        </button>
      </form>
    </div>
  );
}

export default SubmitTransaction;