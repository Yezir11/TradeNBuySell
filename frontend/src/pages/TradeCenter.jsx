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
  const [myTradeableListings, setMyTradeableListings] = useState([]);
  const [allTradeableListings, setAllTradeableListings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showTradeModal, setShowTradeModal] = useState(false);
  const [selectedListing, setSelectedListing] = useState(null);
  const [formStep, setFormStep] = useState(1); // 1: Select listing to request, 2: Select offerings, 3: Cash adjustment
  const [tradeForm, setTradeForm] = useState({
    requestedListingId: listingId || '',
    offeringListingIds: [],
    cashAdjustmentAmount: ''
  });
  const [error, setError] = useState('');
  const [checkingListings, setCheckingListings] = useState(false);

  useEffect(() => {
    fetchTrades();
    fetchMyTradeableListings();
  }, []);

  useEffect(() => {
    if (listingId) {
      if (myTradeableListings.length > 0) {
        fetchSelectedListing();
        setShowTradeModal(true);
      } else {
        // User clicked trade from listing but has no tradeable listings
        setError('You must have at least one active tradeable listing to create a trade. Please create a listing first.');
        navigate('/trades'); // Remove listingId from URL
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [listingId, myTradeableListings.length, user?.userId]);

  useEffect(() => {
    if (showTradeModal && formStep === 1) {
      fetchAllTradeableListings();
    }
  }, [showTradeModal, formStep]);

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

  const fetchMyTradeableListings = async () => {
    try {
      const response = await api.get('/api/listings/my-listings?activeOnly=true');
      // Filter to only tradeable listings
      const tradeableListings = response.data.filter(listing => listing.isTradeable === true);
      setMyTradeableListings(tradeableListings);
    } catch (err) {
      console.error('Failed to fetch my listings:', err);
    }
  };

  const fetchAllTradeableListings = async () => {
    try {
      setCheckingListings(true);
      setError('');
      // Fetch all active listings (may need to paginate for large datasets)
      // Using a large size to get all listings, but in production you might want to implement pagination
      const response = await api.get('/api/listings?page=0&size=1000');
      // Filter to only tradeable listings that are not the user's own
      const tradeableListings = (response.data.content || response.data || []).filter(listing => 
        listing.isTradeable === true && 
        listing.isActive === true && 
        listing.userId !== user?.userId
      );
      setAllTradeableListings(tradeableListings);
      if (tradeableListings.length === 0) {
        setError('No tradable listings available at the moment.');
      }
    } catch (err) {
      console.error('Failed to fetch tradable listings:', err);
      setError('Failed to load tradable listings. Please try again later.');
    } finally {
      setCheckingListings(false);
    }
  };

  const fetchSelectedListing = async () => {
    if (!listingId) return;
    try {
      const response = await api.get(`/api/listings/${listingId}`);
      const listing = response.data;
      if (!listing.isTradeable) {
        setError('This listing is not available for trading.');
        navigate('/trades'); // Remove listingId from URL
        return;
      }
      if (!listing.isActive) {
        setError('This listing is no longer active.');
        navigate('/trades'); // Remove listingId from URL
        return;
      }
      if (listing.userId === user?.userId) {
        setError('You cannot trade with your own listing.');
        navigate('/trades'); // Remove listingId from URL
        return;
      }
      setSelectedListing(listing);
      setTradeForm(prev => ({ ...prev, requestedListingId: listingId }));
      setFormStep(2); // Move to offerings step if listing is valid
      setError('');
    } catch (err) {
      console.error('Failed to fetch listing:', err);
      setError('Failed to load listing. Please try again.');
      navigate('/trades'); // Remove listingId from URL
    }
  };

  const handleNewTradeClick = () => {
    // Check if user has any tradeable listings first
    if (myTradeableListings.length === 0) {
      setError('You must have at least one active tradeable listing to create a trade. Please create a listing first.');
      // Show error in a temporary alert or notification
      alert('You must have at least one active tradeable listing to create a trade. Please create a listing first.');
      return;
    }
    
    // Reset form state
    setError('');
    setFormStep(1);
    setTradeForm({ requestedListingId: '', offeringListingIds: [], cashAdjustmentAmount: '' });
    setSelectedListing(null);
    setShowTradeModal(true);
  };

  const handleListingSelect = (listingId) => {
    const listing = allTradeableListings.find(l => l.listingId === listingId);
    if (listing) {
      setSelectedListing(listing);
      setTradeForm(prev => ({ ...prev, requestedListingId: listingId }));
      setFormStep(2); // Move to offerings step
      setError('');
    }
  };

  const handleTradeSubmit = async (e) => {
    e.preventDefault();
    setError('');
    
    if (!tradeForm.requestedListingId) {
      setError('Please select a listing to request');
      return;
    }
    
    if (tradeForm.offeringListingIds.length === 0 && (!tradeForm.cashAdjustmentAmount || parseFloat(tradeForm.cashAdjustmentAmount) <= 0)) {
      setError('Please select at least one offering listing or provide a cash adjustment amount greater than 0');
      return;
    }
    
    try {
      const tradeData = {
        requestedListingId: tradeForm.requestedListingId,
        offeringListingIds: tradeForm.offeringListingIds.length > 0 ? tradeForm.offeringListingIds : [],
        cashAdjustmentAmount: tradeForm.cashAdjustmentAmount ? parseFloat(tradeForm.cashAdjustmentAmount) : null
      };
      await api.post('/api/trades', tradeData);
      setShowTradeModal(false);
      setTradeForm({ requestedListingId: '', offeringListingIds: [], cashAdjustmentAmount: '' });
      setFormStep(1);
      setSelectedListing(null);
      setError('');
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

  const handleModalClose = () => {
    setShowTradeModal(false);
    setFormStep(1);
    setTradeForm({ requestedListingId: '', offeringListingIds: [], cashAdjustmentAmount: '' });
    setSelectedListing(null);
    setError('');
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
            <button onClick={handleNewTradeClick} className="new-trade-btn">
              New Trade
            </button>
          </div>

          {showTradeModal && (
            <div className="modal-overlay" onClick={handleModalClose}>
              <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                <h2>Create New Trade</h2>
                {error && <div className="error-message">{error}</div>}
                
                {formStep === 1 && (
                  <div className="trade-form-step">
                    <h3>Step 1: Select Listing to Request</h3>
                    <p>Choose a listing from another user that you want to trade for.</p>
                    {checkingListings ? (
                      <div className="loading-message">Loading tradable listings...</div>
                    ) : allTradeableListings.length === 0 ? (
                      <div className="info-message">No tradable listings available at the moment.</div>
                    ) : (
                      <div className="listings-grid-container">
                        <div className="listings-grid">
                          {allTradeableListings.map(listing => (
                            <div
                              key={listing.listingId}
                              className={`listing-card-selectable ${
                                tradeForm.requestedListingId === listing.listingId ? 'selected' : ''
                              }`}
                              onClick={() => handleListingSelect(listing.listingId)}
                            >
                              {listing.imageUrls && listing.imageUrls.length > 0 && (
                                <img
                                  src={listing.imageUrls[0]}
                                  alt={listing.title}
                                  className="listing-card-image"
                                  onError={(e) => {
                                    e.target.src = 'https://via.placeholder.com/200x150?text=No+Image';
                                  }}
                                />
                              )}
                              <div className="listing-card-content">
                                <h4>{listing.title}</h4>
                                <p className="listing-price">
                                  {listing.price ? `₹${parseFloat(listing.price).toFixed(2)}` : 'Trade Only'}
                                </p>
                                <p className="listing-category">{listing.category}</p>
                                <p className="listing-description">
                                  {listing.description.length > 100
                                    ? `${listing.description.substring(0, 100)}...`
                                    : listing.description}
                                </p>
                                {listing.sellerName && (
                                  <p className="listing-seller">Seller: {listing.sellerName}</p>
                                )}
                                {listing.sellerTrustScore && (
                                  <p className="listing-trust">
                                    Trust Score: {listing.sellerTrustScore.toFixed(1)}/5.0
                                  </p>
                                )}
                              </div>
                              {tradeForm.requestedListingId === listing.listingId && (
                                <div className="selected-indicator">✓ Selected</div>
                              )}
                            </div>
                          ))}
                        </div>
                      </div>
                    )}
                    <div className="modal-buttons">
                      <button type="button" onClick={handleModalClose} className="cancel-btn">
                        Cancel
                      </button>
                      {selectedListing && (
                        <button type="button" onClick={() => setFormStep(2)} className="next-btn">
                          Next: Select Your Offerings →
                        </button>
                      )}
                    </div>
                  </div>
                )}

                    {formStep === 2 && (
                  <div className="trade-form-step">
                    <h3>Step 2: Select Your Offerings</h3>
                    <p>Select one or more listings you want to offer in exchange. You can select multiple listings.</p>
                    {myTradeableListings.length === 0 ? (
                      <div className="error-message">
                        You don't have any active tradeable listings. Please create a tradeable listing first.
                      </div>
                    ) : (
                      <>
                        <div className="listings-grid-container">
                          <div className="listings-grid">
                            {myTradeableListings.map(listing => {
                              const isSelected = tradeForm.offeringListingIds.includes(listing.listingId);
                              return (
                                <div
                                  key={listing.listingId}
                                  className={`listing-card-selectable ${isSelected ? 'selected' : ''}`}
                                  onClick={() => {
                                    if (isSelected) {
                                      setTradeForm({
                                        ...tradeForm,
                                        offeringListingIds: tradeForm.offeringListingIds.filter(
                                          id => id !== listing.listingId
                                        )
                                      });
                                    } else {
                                      setTradeForm({
                                        ...tradeForm,
                                        offeringListingIds: [...tradeForm.offeringListingIds, listing.listingId]
                                      });
                                    }
                                  }}
                                >
                                  {listing.imageUrls && listing.imageUrls.length > 0 && (
                                    <img
                                      src={listing.imageUrls[0]}
                                      alt={listing.title}
                                      className="listing-card-image"
                                      onError={(e) => {
                                        e.target.src = 'https://via.placeholder.com/200x150?text=No+Image';
                                      }}
                                    />
                                  )}
                                  <div className="listing-card-content">
                                    <h4>{listing.title}</h4>
                                    <p className="listing-price">
                                      {listing.price ? `₹${parseFloat(listing.price).toFixed(2)}` : 'Trade Only'}
                                    </p>
                                    <p className="listing-category">{listing.category}</p>
                                    <p className="listing-description">
                                      {listing.description.length > 100
                                        ? `${listing.description.substring(0, 100)}...`
                                        : listing.description}
                                    </p>
                                  </div>
                                  {isSelected && (
                                    <div className="selected-indicator">✓ Selected</div>
                                  )}
                                </div>
                              );
                            })}
                          </div>
                        </div>
                        {tradeForm.offeringListingIds.length > 0 && (
                          <div className="selected-count">
                            {tradeForm.offeringListingIds.length} listing{tradeForm.offeringListingIds.length !== 1 ? 's' : ''} selected
                          </div>
                        )}
                        {selectedListing && (
                          <div className="trade-summary">
                            <h4>Trade Summary</h4>
                            <div className="trade-summary-item">
                              <strong>You are requesting:</strong>
                              <p>{selectedListing.title} - ₹{selectedListing.price || 'Trade Only'}</p>
                            </div>
                            <div className="trade-summary-item">
                              <strong>You are offering:</strong>
                              {tradeForm.offeringListingIds.length > 0 ? (
                                <ul>
                                  {tradeForm.offeringListingIds.map(id => {
                                    const listing = myTradeableListings.find(l => l.listingId === id);
                                    return listing ? (
                                      <li key={id}>{listing.title} - ₹{listing.price || 'Trade Only'}</li>
                                    ) : null;
                                  })}
                                </ul>
                              ) : (
                                <p>No listings selected (cash only trade)</p>
                              )}
                            </div>
                          </div>
                        )}
                      </>
                    )}
                    <div className="modal-buttons">
                      <button type="button" onClick={() => setFormStep(1)} className="back-btn">
                        ← Back
                      </button>
                      <button 
                        type="button" 
                        onClick={() => {
                          // Validate: must have at least one offering or cash adjustment will be added in step 3
                          if (tradeForm.offeringListingIds.length === 0) {
                            // Allow proceeding if user wants to add cash in step 3
                            setFormStep(3);
                          } else {
                            setFormStep(3);
                          }
                        }} 
                        className="next-btn"
                        disabled={myTradeableListings.length === 0}
                      >
                        Next: Cash Adjustment →
                      </button>
                    </div>
                  </div>
                )}

                {formStep === 3 && (
                  <form onSubmit={handleTradeSubmit} className="trade-form-step">
                    <h3>Step 3: Cash Adjustment (Optional)</h3>
                    <p>Add cash to balance the trade if needed.</p>
                    <div className="form-group">
                      <label>Cash Adjustment (₹)</label>
                      <input
                        type="number"
                        step="0.01"
                        min="0"
                        value={tradeForm.cashAdjustmentAmount}
                        onChange={(e) => setTradeForm({ ...tradeForm, cashAdjustmentAmount: e.target.value })}
                        placeholder="0.00"
                      />
                      <small>Optional: Additional cash to balance the trade</small>
                    </div>
                    {selectedListing && (
                      <div className="trade-summary">
                        <h4>Final Trade Summary</h4>
                        <div className="trade-summary-item">
                          <strong>You are requesting:</strong>
                          <p>{selectedListing.title} - ₹{selectedListing.price || 'Trade Only'}</p>
                        </div>
                        <div className="trade-summary-item">
                          <strong>You are offering:</strong>
                          {tradeForm.offeringListingIds.length > 0 ? (
                            <ul>
                              {tradeForm.offeringListingIds.map(id => {
                                const listing = myTradeableListings.find(l => l.listingId === id);
                                return listing ? (
                                  <li key={id}>{listing.title} - ₹{listing.price || 'Trade Only'}</li>
                                ) : null;
                              })}
                            </ul>
                          ) : (
                            <p>No listings selected</p>
                          )}
                        </div>
                        {tradeForm.cashAdjustmentAmount && parseFloat(tradeForm.cashAdjustmentAmount) > 0 && (
                          <div className="trade-summary-item">
                            <strong>Cash Adjustment:</strong>
                            <p>+₹{parseFloat(tradeForm.cashAdjustmentAmount).toFixed(2)}</p>
                          </div>
                        )}
                      </div>
                    )}
                    <div className="modal-buttons">
                      <button type="button" onClick={() => setFormStep(2)} className="back-btn">
                        ← Back
                      </button>
                      <button type="submit" className="submit-btn">Create Trade</button>
                      <button type="button" onClick={handleModalClose} className="cancel-btn">
                        Cancel
                      </button>
                    </div>
                  </form>
                )}
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
