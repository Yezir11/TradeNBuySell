import React, { useState, useEffect } from 'react';
import { useNavigate, useSearchParams, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import api from '../services/api';
import Navigation from '../components/Navigation';
import './TradeCenter.css';

const TradeCenter = () => {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const listingId = searchParams.get('listingId');
  
  const [trades, setTrades] = useState([]);
  const [listings, setListings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showTradeModal, setShowTradeModal] = useState(false);
  const [selectedListing, setSelectedListing] = useState(null);
  const [tradeForm, setTradeForm] = useState({
    requestedListingId: listingId || '',
    offeringListingIds: [],
    cashAdjustmentAmount: ''
  });
  const [error, setError] = useState('');

  useEffect(() => {
    fetchTrades();
    if (listingId) {
      fetchSelectedListing();
      setShowTradeModal(true);
    }
    fetchMyListings();
  }, [listingId]);

  const fetchTrades = async () => {
    try {
      const response = await api.get('/api/trades');
      setTrades(response.data);
    } catch (err) {
      console.error('Failed to fetch trades:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchMyListings = async () => {
    try {
      const response = await api.get('/api/listings/my-listings?activeOnly=true');
      setListings(response.data);
    } catch (err) {
      console.error('Failed to fetch listings:', err);
    }
  };

  const fetchSelectedListing = async () => {
    if (!listingId) return;
    try {
      const response = await api.get(`/api/listings/${listingId}`);
      setSelectedListing(response.data);
      setTradeForm(prev => ({ ...prev, requestedListingId: listingId }));
    } catch (err) {
      console.error('Failed to fetch listing:', err);
    }
  };

  const handleTradeSubmit = async (e) => {
    e.preventDefault();
    setError('');
    try {
      const tradeData = {
        requestedListingId: tradeForm.requestedListingId,
        offeringListingIds: tradeForm.offeringListingIds,
        cashAdjustmentAmount: tradeForm.cashAdjustmentAmount ? parseFloat(tradeForm.cashAdjustmentAmount) : null
      };
      await api.post('/api/trades', tradeData);
      setShowTradeModal(false);
      setTradeForm({ requestedListingId: '', offeringListingIds: [], cashAdjustmentAmount: '' });
      fetchTrades();
      navigate('/trades');
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to create trade');
    }
  };

  const handleTradeAction = async (tradeId, action) => {
    try {
      await api.post(`/api/trades/${tradeId}/${action}`);
      fetchTrades();
    } catch (err) {
      alert(err.response?.data?.message || `Failed to ${action} trade`);
    }
  };

  const getTradeStatus = (trade) => {
    if (trade.status === 'PENDING') {
      if (trade.recipientId === user?.userId) {
        return 'Awaiting your response';
      } else {
        return 'Pending recipient response';
      }
    }
    return trade.status;
  };

  if (loading) {
    return (
      <>
        <Navigation />
        <div className="trade-center">Loading...</div>
      </>
    );
  }

  return (
    <>
      <Navigation />
      <div className="trade-center">
        <div className="container">
          <div className="trade-header">
            <h1>Trade Center</h1>
            <button onClick={() => setShowTradeModal(true)} className="new-trade-btn">
              New Trade
            </button>
          </div>

          {showTradeModal && (
            <div className="modal-overlay" onClick={() => setShowTradeModal(false)}>
              <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                <h2>Create New Trade</h2>
                {error && <div className="error-message">{error}</div>}
                <form onSubmit={handleTradeSubmit}>
                  <div className="form-group">
                    <label>Requested Listing</label>
                    <input
                      type="text"
                      placeholder="Listing ID or URL"
                      value={tradeForm.requestedListingId}
                      onChange={(e) => setTradeForm({ ...tradeForm, requestedListingId: e.target.value })}
                      required
                    />
                    {selectedListing && (
                      <div className="selected-listing">
                        <h4>{selectedListing.title}</h4>
                        <p>Price: ₹{selectedListing.price || 'Trade Only'}</p>
                      </div>
                    )}
                  </div>

                  <div className="form-group">
                    <label>Your Offerings</label>
                    <select
                      multiple
                      value={tradeForm.offeringListingIds}
                      onChange={(e) => setTradeForm({
                        ...tradeForm,
                        offeringListingIds: Array.from(e.target.selectedOptions, option => option.value)
                      })}
                      size="5"
                    >
                      {listings.map(listing => (
                        <option key={listing.listingId} value={listing.listingId}>
                          {listing.title} - ₹{listing.price || 'Trade Only'}
                        </option>
                      ))}
                    </select>
                    <small>Hold Ctrl/Cmd to select multiple listings</small>
                  </div>

                  <div className="form-group">
                    <label>Cash Adjustment (₹)</label>
                    <input
                      type="number"
                      step="0.01"
                      min="0"
                      value={tradeForm.cashAdjustmentAmount}
                      onChange={(e) => setTradeForm({ ...tradeForm, cashAdjustmentAmount: e.target.value })}
                    />
                    <small>Optional: Additional cash to balance the trade</small>
                  </div>

                  <div className="modal-buttons">
                    <button type="submit" className="submit-btn">Create Trade</button>
                    <button type="button" onClick={() => setShowTradeModal(false)} className="cancel-btn">
                      Cancel
                    </button>
                  </div>
                </form>
              </div>
            </div>
          )}

          <div className="trades-section">
            <h2>My Trades</h2>
            {trades.length === 0 ? (
              <div className="no-trades">No trades yet</div>
            ) : (
              <div className="trades-list">
                {trades.map(trade => (
                  <div key={trade.tradeId} className="trade-card">
                    <div className="trade-header-info">
                      <h3>Trade #{trade.tradeId.substring(0, 8)}</h3>
                      <span className={`trade-status ${trade.status.toLowerCase()}`}>
                        {getTradeStatus(trade)}
                      </span>
                    </div>

                    <div className="trade-details">
                      <div className="trade-side">
                        <h4>You {trade.initiatorId === user?.userId ? '(Initiator)' : '(Recipient)'}</h4>
                        {trade.initiatorId === user?.userId ? (
                          trade.offeringListingTitles && trade.offeringListingTitles.length > 0 ? (
                            <ul>
                              {trade.offeringListingTitles.map((title, index) => (
                                <li key={index}>{title}</li>
                              ))}
                            </ul>
                          ) : (
                            <p>No offerings</p>
                          )
                        ) : (
                          <p>{trade.requestedListingTitle}</p>
                        )}
                      </div>

                      <div className="trade-arrow">⇄</div>

                      <div className="trade-side">
                        <h4>{trade.initiatorId === user?.userId ? 'Recipient' : 'Initiator'}</h4>
                        {trade.initiatorId === user?.userId ? (
                          <p>{trade.requestedListingTitle}</p>
                        ) : (
                          trade.offeringListingTitles && trade.offeringListingTitles.length > 0 ? (
                            <ul>
                              {trade.offeringListingTitles.map((title, index) => (
                                <li key={index}>{title}</li>
                              ))}
                            </ul>
                          ) : (
                            <p>No offerings</p>
                          )
                        )}
                      </div>
                    </div>

                    {trade.cashAdjustmentAmount && parseFloat(trade.cashAdjustmentAmount) !== 0 && (
                      <div className="cash-adjustment">
                        Cash Adjustment: {trade.initiatorId === user?.userId ? '+' : '-'}₹{Math.abs(trade.cashAdjustmentAmount)}
                      </div>
                    )}

                    <div className="trade-actions">
                      {trade.status === 'PENDING' && trade.recipientId === user?.userId && (
                        <>
                          <button
                            onClick={() => handleTradeAction(trade.tradeId, 'accept')}
                            className="accept-btn"
                          >
                            Accept
                          </button>
                          <button
                            onClick={() => handleTradeAction(trade.tradeId, 'reject')}
                            className="reject-btn"
                          >
                            Reject
                          </button>
                        </>
                      )}
                      {trade.status === 'PENDING' && trade.initiatorId === user?.userId && (
                        <button
                          onClick={() => handleTradeAction(trade.tradeId, 'cancel')}
                          className="cancel-trade-btn"
                        >
                          Cancel
                        </button>
                      )}
                      <Link to={`/trade/${trade.tradeId}`} className="view-btn">
                        View Details
                      </Link>
                    </div>

                    <div className="trade-meta">
                      <p>Created: {new Date(trade.createdAt).toLocaleString()}</p>
                      {trade.resolvedAt && (
                        <p>Resolved: {new Date(trade.resolvedAt).toLocaleString()}</p>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </>
  );
};

export default TradeCenter;
