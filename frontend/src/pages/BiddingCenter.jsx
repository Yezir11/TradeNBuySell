import React, { useState, useEffect } from 'react';
import { useNavigate, useSearchParams, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import api from '../services/api';
import Navigation from '../components/Navigation';
import './BiddingCenter.css';

const BiddingCenter = () => {
  const { user, isAuthenticated, loading: authLoading } = useAuth();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const listingId = searchParams.get('listingId');
  
  const [bids, setBids] = useState([]);
  const [myBids, setMyBids] = useState([]);
  const [myListings, setMyListings] = useState([]);
  const [activeListings, setActiveListings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [placingBid, setPlacingBid] = useState(false);
  const [finalizingBid, setFinalizingBid] = useState(false);
  const [showBidModal, setShowBidModal] = useState(false);
  const [selectedListing, setSelectedListing] = useState(null);
  const [selectedMyListing, setSelectedMyListing] = useState(null);
  const [bidAmount, setBidAmount] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [activeTab, setActiveTab] = useState('my-bids');

  useEffect(() => {
    if (!authLoading) {
      if (!isAuthenticated || !user) {
        navigate('/auth');
        return;
      }
      fetchBiddingData();
      if (listingId) {
        fetchListingDetails();
        setShowBidModal(true);
      }
    }
  }, [isAuthenticated, user, authLoading, listingId, navigate]);

  const fetchBiddingData = async () => {
    if (!user?.userId) return;
    
    try {
      setError('');
      const [myBidsRes, listingsRes, myListingsRes] = await Promise.all([
        api.get('/api/bids/my-bids').catch(() => ({ data: [] })),
        api.get('/api/listings?category=&search=&page=0&size=100').catch(() => ({ data: { content: [] } })),
        api.get('/api/listings/my-listings?activeOnly=false').catch(() => ({ data: [] }))
      ]);
      
      setMyBids(myBidsRes.data || []);
      
      // Filter out user's own listings and only show active biddable listings
      const allListings = listingsRes.data.content || [];
      const filteredListings = allListings.filter(l => 
        l.isBiddable && 
        l.isActive && 
        l.userId !== user.userId &&
        (!l.bidEndTime || new Date(l.bidEndTime) > new Date())
      );
      setActiveListings(filteredListings);
      
      // Filter user's own biddable listings
      const myBiddableListings = (myListingsRes.data || []).filter(l => l.isBiddable);
      setMyListings(myBiddableListings);
    } catch (err) {
      console.error('Failed to fetch bidding data:', err);
      setError(err.response?.data?.message || 'Failed to load bidding data');
    } finally {
      setLoading(false);
    }
  };

  const fetchListingDetails = async () => {
    if (!listingId) return;
    try {
      const response = await api.get(`/api/listings/${listingId}`);
      setSelectedListing(response.data);
      await fetchListingBids(listingId);
      if (response.data.highestBid) {
        setBidAmount((parseFloat(response.data.highestBid) + (response.data.bidIncrement || 0)).toString());
      } else if (response.data.startingPrice) {
        setBidAmount(response.data.startingPrice.toString());
      }
    } catch (err) {
      console.error('Failed to fetch listing:', err);
      setError(err.response?.data?.message || 'Failed to fetch listing details');
    }
  };

  const fetchListingBids = async (listingIdParam) => {
    try {
      const response = await api.get(`/api/bids/listing/${listingIdParam}`);
      setBids(response.data || []);
    } catch (err) {
      console.error('Failed to fetch bids:', err);
      setBids([]);
    }
  };

  const handlePlaceBid = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    setPlacingBid(true);
    
    try {
      const targetListingId = selectedListing?.listingId || listingId;
      await api.post('/api/bids', {
        listingId: targetListingId,
        bidAmount: parseFloat(bidAmount)
      });
      
      setSuccess('Bid placed successfully!');
      setShowBidModal(false);
      setBidAmount('');
      setSelectedListing(null);
      
      // Refresh all data
      await fetchBiddingData();
      if (targetListingId) {
        await fetchListingBids(targetListingId);
      }
      
      // Clear success message after 3 seconds
      setTimeout(() => setSuccess(''), 3000);
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to place bid');
    } finally {
      setPlacingBid(false);
    }
  };

  const handleListingSelect = async (listing) => {
    setSelectedListing(listing);
    setError('');
    setSuccess('');
    setShowBidModal(true);
    
    // Calculate minimum bid amount
    if (listing.highestBid) {
      const minBid = parseFloat(listing.highestBid) + (listing.bidIncrement || 0);
      setBidAmount(minBid.toString());
    } else if (listing.startingPrice) {
      setBidAmount(listing.startingPrice.toString());
    }
    
    await fetchListingBids(listing.listingId);
  };

  const handleMyListingSelect = async (listing) => {
    setSelectedMyListing(listing);
    setError('');
    setSuccess('');
    await fetchListingBids(listing.listingId);
  };

  const handleFinalizeBid = async (listingIdParam) => {
    if (!window.confirm('Are you sure you want to finalize this bid? This will close the listing and transfer funds.')) {
      return;
    }
    
    setError('');
    setSuccess('');
    setFinalizingBid(true);
    
    try {
      await api.post(`/api/bids/listing/${listingIdParam}/finalize`);
      setSuccess('Bid finalized successfully!');
      
      // Refresh all data
      await fetchBiddingData();
      setSelectedMyListing(null);
      setBids([]);
      
      // Clear success message after 3 seconds
      setTimeout(() => setSuccess(''), 3000);
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to finalize bid');
    } finally {
      setFinalizingBid(false);
    }
  };

  const getTimeRemaining = (endTime) => {
    if (!endTime) return null;
    const now = new Date();
    const end = new Date(endTime);
    const diff = end - now;
    
    if (diff <= 0) return 'Ended';
    
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
    
    if (days > 0) return `${days}d ${hours}h`;
    if (hours > 0) return `${hours}h ${minutes}m`;
    return `${minutes}m`;
  };

  const isBidEnded = (endTime) => {
    if (!endTime) return false;
    return new Date(endTime) <= new Date();
  };

  if (authLoading || loading) {
    return (
      <>
        <Navigation />
        <div className="bidding-center">
          <div className="container">
            <div className="loading-container">
              <p>Loading...</p>
            </div>
          </div>
        </div>
      </>
    );
  }

  if (!isAuthenticated || !user) {
    return null; // Will redirect to auth
  }

  return (
    <>
      <Navigation />
      <div className="bidding-center">
        <div className="container">
          <h1>Bidding Center</h1>

          {error && <div className="error-message">{error}</div>}
          {success && <div className="success-message">{success}</div>}

          <div className="tabs">
            <button
              className={activeTab === 'my-bids' ? 'active' : ''}
              onClick={() => {
                setActiveTab('my-bids');
                setSelectedMyListing(null);
                setBids([]);
              }}
            >
              My Bids ({myBids.length})
            </button>
            <button
              className={activeTab === 'active-listings' ? 'active' : ''}
              onClick={() => {
                setActiveTab('active-listings');
                setSelectedMyListing(null);
                setBids([]);
              }}
            >
              Active Listings ({activeListings.length})
            </button>
            <button
              className={activeTab === 'my-listings' ? 'active' : ''}
              onClick={() => {
                setActiveTab('my-listings');
                setSelectedMyListing(null);
                setBids([]);
              }}
            >
              My Listings ({myListings.length})
            </button>
          </div>

          {activeTab === 'my-bids' && (
            <div className="my-bids-section">
              <h2>My Bids</h2>
              {myBids.length === 0 ? (
                <div className="no-bids">
                  <p>You haven't placed any bids yet.</p>
                  <p>Browse active listings to start bidding!</p>
                </div>
              ) : (
                <div className="bids-list">
                  {myBids.map(bid => (
                    <div key={bid.bidId} className="bid-card">
                      <div className="bid-header">
                        <Link to={`/listing/${bid.listingId}`} className="listing-link">
                          <h3>{bid.listingTitle || 'Untitled Listing'}</h3>
                        </Link>
                        <span className={`bid-status ${bid.isWinning ? 'winning' : 'outbid'}`}>
                          {bid.isWinning ? 'Winning' : 'Outbid'}
                        </span>
                      </div>
                      <div className="bid-details">
                        <div>
                          <p className="bid-amount">₹{parseFloat(bid.bidAmount).toFixed(2)}</p>
                          <p className="bid-time">Placed: {new Date(bid.bidTime).toLocaleString()}</p>
                        </div>
                        <Link to={`/listing/${bid.listingId}`} className="view-listing-btn">
                          View Listing
                        </Link>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {activeTab === 'active-listings' && (
            <div className="active-listings-section">
              <h2>Active Biddable Listings</h2>
              {activeListings.length === 0 ? (
                <div className="no-listings">
                  <p>No active biddable listings available.</p>
                </div>
              ) : (
                <div className="listings-grid">
                  {activeListings.map(listing => {
                    const timeRemaining = getTimeRemaining(listing.bidEndTime);
                    const ended = isBidEnded(listing.bidEndTime);
                    
                    return (
                      <div key={listing.listingId} className="listing-card">
                        {listing.imageUrls && listing.imageUrls.length > 0 && (
                          <img 
                            src={listing.imageUrls[0]} 
                            alt={listing.title}
                            onError={(e) => {
                              e.target.src = 'https://via.placeholder.com/300x200?text=No+Image';
                            }}
                          />
                        )}
                        <div className="listing-info">
                          <Link to={`/listing/${listing.listingId}`} className="listing-title-link">
                            <h3>{listing.title}</h3>
                          </Link>
                          <p className="price">Starting: ₹{listing.startingPrice ? parseFloat(listing.startingPrice).toFixed(2) : 'N/A'}</p>
                          {listing.highestBid && (
                            <p className="highest-bid">Highest: ₹{parseFloat(listing.highestBid).toFixed(2)}</p>
                          )}
                          <p className="bid-count">
                            {listing.bidCount || 0} bid{listing.bidCount !== 1 ? 's' : ''}
                          </p>
                          {listing.bidEndTime && (
                            <p className={`end-time ${ended ? 'ended' : ''}`}>
                              {ended ? 'Ended' : `Ends: ${new Date(listing.bidEndTime).toLocaleString()}`}
                              {timeRemaining && !ended && (
                                <span className="time-remaining"> ({timeRemaining} remaining)</span>
                              )}
                            </p>
                          )}
                          <button
                            onClick={() => handleListingSelect(listing)}
                            className="bid-now-btn"
                            disabled={ended}
                          >
                            {ended ? 'Bidding Ended' : 'Place Bid'}
                          </button>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          )}

          {activeTab === 'my-listings' && (
            <div className="my-listings-section">
              <h2>My Biddable Listings</h2>
              {myListings.length === 0 ? (
                <div className="no-listings">
                  <p>You don't have any biddable listings.</p>
                  <Link to="/post-listing" className="create-listing-link">Create a biddable listing</Link>
                </div>
              ) : (
                <div className="my-listings-container">
                  <div className="listings-list">
                    {myListings.map(listing => {
                      const ended = isBidEnded(listing.bidEndTime);
                      const timeRemaining = getTimeRemaining(listing.bidEndTime);
                      
                      return (
                        <div 
                          key={listing.listingId} 
                          className={`listing-item ${selectedMyListing?.listingId === listing.listingId ? 'selected' : ''}`}
                          onClick={() => handleMyListingSelect(listing)}
                        >
                          <div className="listing-item-content">
                            {listing.imageUrls && listing.imageUrls.length > 0 && (
                              <img 
                                src={listing.imageUrls[0]} 
                                alt={listing.title}
                                className="listing-item-image"
                                onError={(e) => {
                                  e.target.src = 'https://via.placeholder.com/100x100?text=No+Image';
                                }}
                              />
                            )}
                            <div className="listing-item-info">
                              <h3>{listing.title}</h3>
                              <p className="price">Starting: ₹{listing.startingPrice ? parseFloat(listing.startingPrice).toFixed(2) : 'N/A'}</p>
                              {listing.highestBid && (
                                <p className="highest-bid">Highest: ₹{parseFloat(listing.highestBid).toFixed(2)}</p>
                              )}
                              <p className="bid-count">{listing.bidCount || 0} bid{listing.bidCount !== 1 ? 's' : ''}</p>
                              {listing.bidEndTime && (
                                <p className={`end-time ${ended ? 'ended' : ''}`}>
                                  {ended ? 'Ended' : `Ends: ${new Date(listing.bidEndTime).toLocaleString()}`}
                                  {timeRemaining && !ended && (
                                    <span className="time-remaining"> ({timeRemaining} remaining)</span>
                                  )}
                                </p>
                              )}
                              <span className={`status-badge ${listing.isActive ? 'active' : 'inactive'}`}>
                                {listing.isActive ? 'Active' : 'Inactive'}
                              </span>
                            </div>
                          </div>
                        </div>
                      );
                    })}
                  </div>
                  
                  {selectedMyListing && (
                    <div className="listing-bids-detail">
                      <h3>Bids on "{selectedMyListing.title}"</h3>
                      {bids.length === 0 ? (
                        <div className="no-bids">
                          <p>No bids yet on this listing.</p>
                        </div>
                      ) : (
                        <>
                          <div className="bids-table">
                            <div className="bids-table-header">
                              <span>Bidder</span>
                              <span>Amount</span>
                              <span>Time</span>
                              <span>Status</span>
                            </div>
                            {bids.map((bid, index) => (
                              <div key={bid.bidId} className="bids-table-row">
                                <span>{bid.userName || 'Unknown'}</span>
                                <span className="bid-amount">₹{parseFloat(bid.bidAmount).toFixed(2)}</span>
                                <span>{new Date(bid.bidTime).toLocaleString()}</span>
                                <span className={`bid-status-badge ${bid.isWinning ? 'winning' : 'outbid'}`}>
                                  {bid.isWinning ? 'Winning' : index === 0 ? 'Highest' : 'Outbid'}
                                </span>
                              </div>
                            ))}
                          </div>
                          {selectedMyListing.isActive && 
                           bids.length > 0 && 
                           isBidEnded(selectedMyListing.bidEndTime) && (
                            <button
                              onClick={() => handleFinalizeBid(selectedMyListing.listingId)}
                              className="finalize-bid-btn"
                              disabled={finalizingBid}
                            >
                              {finalizingBid ? 'Finalizing...' : 'Finalize Winning Bid'}
                            </button>
                          )}
                          {selectedMyListing.isActive && 
                           !isBidEnded(selectedMyListing.bidEndTime) && (
                            <p className="info-message">
                              Bidding is still active. You can finalize after the bidding ends.
                            </p>
                          )}
                        </>
                      )}
                    </div>
                  )}
                </div>
              )}
            </div>
          )}

          {showBidModal && selectedListing && (
            <div className="modal-overlay" onClick={() => {
              setShowBidModal(false);
              setError('');
              setSuccess('');
            }}>
              <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                <button 
                  className="modal-close-btn"
                  onClick={() => {
                    setShowBidModal(false);
                    setError('');
                    setSuccess('');
                  }}
                >
                  ×
                </button>
                <h2>Place Bid</h2>
                <div className="listing-summary">
                  <h3>{selectedListing.title}</h3>
                  <p>Starting Price: ₹{selectedListing.startingPrice ? parseFloat(selectedListing.startingPrice).toFixed(2) : 'N/A'}</p>
                  {selectedListing.highestBid && (
                    <p>Current Highest: ₹{parseFloat(selectedListing.highestBid).toFixed(2)}</p>
                  )}
                  {selectedListing.bidIncrement && (
                    <p>Bid Increment: ₹{parseFloat(selectedListing.bidIncrement).toFixed(2)}</p>
                  )}
                  {selectedListing.bidEndTime && (
                    <p>Ends: {new Date(selectedListing.bidEndTime).toLocaleString()}</p>
                  )}
                  {selectedListing.bidCount !== undefined && (
                    <p>Total Bids: {selectedListing.bidCount}</p>
                  )}
                </div>

                {bids.length > 0 && (
                  <div className="recent-bids">
                    <h4>Recent Bids</h4>
                    <div className="bids-list-small">
                      {bids.slice(0, 5).map(bid => (
                        <div key={bid.bidId} className="bid-item-small">
                          <span>{bid.userName || 'Unknown'}</span>
                          <span className="bid-amount">₹{parseFloat(bid.bidAmount).toFixed(2)}</span>
                          <span className="bid-time">{new Date(bid.bidTime).toLocaleString()}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {error && <div className="error-message">{error}</div>}
                {success && <div className="success-message">{success}</div>}

                <form onSubmit={handlePlaceBid}>
                  <div className="form-group">
                    <label>Bid Amount (₹)</label>
                    <input
                      type="number"
                      step="0.01"
                      min={
                        selectedListing.highestBid 
                          ? parseFloat(selectedListing.highestBid) + (parseFloat(selectedListing.bidIncrement) || 0)
                          : parseFloat(selectedListing.startingPrice) || 0
                      }
                      value={bidAmount}
                      onChange={(e) => setBidAmount(e.target.value)}
                      required
                      disabled={placingBid || isBidEnded(selectedListing.bidEndTime)}
                    />
                    {selectedListing.bidIncrement && selectedListing.highestBid && (
                      <small>
                        Minimum bid: ₹{(parseFloat(selectedListing.highestBid) + parseFloat(selectedListing.bidIncrement)).toFixed(2)}
                      </small>
                    )}
                    {!selectedListing.highestBid && selectedListing.startingPrice && (
                      <small>
                        Minimum bid: ₹{parseFloat(selectedListing.startingPrice).toFixed(2)}
                      </small>
                    )}
                  </div>

                  <div className="modal-buttons">
                    <button 
                      type="submit" 
                      className="submit-btn"
                      disabled={placingBid || isBidEnded(selectedListing.bidEndTime)}
                    >
                      {placingBid ? 'Placing Bid...' : 'Place Bid'}
                    </button>
                    <button 
                      type="button" 
                      onClick={() => {
                        setShowBidModal(false);
                        setError('');
                        setSuccess('');
                      }} 
                      className="cancel-btn"
                      disabled={placingBid}
                    >
                      Cancel
                    </button>
                  </div>
                </form>
              </div>
            </div>
          )}
        </div>
      </div>
    </>
  );
};

export default BiddingCenter;