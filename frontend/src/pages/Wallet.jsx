import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import api from '../services/api';
import MarketplaceHeader from '../components/MarketplaceHeader';
import './Wallet.css';

const Wallet = () => {
  const { user } = useAuth();
  const [balance, setBalance] = useState(0);
  const [transactions, setTransactions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [addFundsAmount, setAddFundsAmount] = useState('');
  const [showAddFunds, setShowAddFunds] = useState(false);

  useEffect(() => {
    fetchWalletData();
  }, []);

  const fetchWalletData = async () => {
    try {
      const [balanceRes, transactionsRes] = await Promise.all([
        api.get('/api/wallet/balance'),
        api.get('/api/wallet/transactions')
      ]);
      setBalance(balanceRes.data);
      setTransactions(transactionsRes.data);
    } catch (err) {
      console.error('Failed to fetch wallet data:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleAddFunds = async (e) => {
    e.preventDefault();
    try {
      await api.post('/api/wallet/add-funds', {
        amount: parseFloat(addFundsAmount),
        description: 'Top up'
      });
      setAddFundsAmount('');
      setShowAddFunds(false);
      fetchWalletData();
    } catch (err) {
      alert('Failed to add funds');
    }
  };

  if (loading) {
    return (
      <>
        <MarketplaceHeader showSearch={false} />
        <div className="wallet-page">Loading...</div>
      </>
    );
  }

  return (
    <>
      <MarketplaceHeader showSearch={false} />
      <div className="wallet-page">
        <div className="container">
          <h1>My Wallet</h1>

          <div className="wallet-balance-card">
            <h2>Current Balance</h2>
            <p className="balance-amount">₹{balance.toFixed(2)}</p>
            <button onClick={() => setShowAddFunds(!showAddFunds)} className="add-funds-btn">
              Add Funds
            </button>
            {showAddFunds && (
              <form onSubmit={handleAddFunds} className="add-funds-form">
                <input
                  type="number"
                  placeholder="Amount"
                  value={addFundsAmount}
                  onChange={(e) => setAddFundsAmount(e.target.value)}
                  step="0.01"
                  min="0"
                  required
                />
                <div className="form-buttons">
                  <button type="submit">Add</button>
                  <button type="button" onClick={() => setShowAddFunds(false)}>Cancel</button>
                </div>
              </form>
            )}
          </div>

          <div className="transactions-section">
            <h2>Transaction History</h2>
            <div className="transactions-list">
              {transactions.length === 0 ? (
                <p className="no-transactions">No transactions yet</p>
              ) : (
                transactions.map(transaction => (
                  <div key={transaction.transactionId} className="transaction-item">
                    <div className="transaction-details">
                      <p className="transaction-reason">{transaction.reason}</p>
                      <p className="transaction-description">{transaction.description || 'N/A'}</p>
                      <p className="transaction-date">
                        {new Date(transaction.timestamp).toLocaleString()}
                      </p>
                    </div>
                    <p className={`transaction-amount ${transaction.type}`}>
                      {transaction.type === 'CREDIT' ? '+' : '-'}₹{transaction.amount.toFixed(2)}
                    </p>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Wallet;
