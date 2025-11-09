import React, { useState, useEffect } from 'react';
import { useNavigate, useSearchParams, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import api from '../services/api';
import Navigation from '../components/Navigation';
import './BiddingCenter.css';

const BiddingCenter = () => {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const listingId = searchParams.get('listingId');
  
  const [bids, setBids] = useState([]);
  const [myBids, setMyBids] = useState([]);
  const [activeListings, setActiveListings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showBidModal, setShowBidModal] = useState(false);
  const [selectedListing, setSelectedListing] = useState(null);
  const [bidAmount, setBidAmount] = useState('');
  const [error, setError] = useState('');
  const [activeTab, setActiveTab] = useState('my-bids');

  useEffect(() => {
    fetchBiddingData();
    if (listingId) {
      fetchListingDetails();
      setShowBidModal(true);
    }
  }, [listingId]);

  const fetchBiddingData = async () => {
    try {
      const [myBidsRes, listingsRes] = await Promise.all([
        api.get('/api/bids/my-bids'),
        api.get('/api/listings?category=&search=&page=0&size=100')
      ]);
      setMyBids(myBidsRes.data);
      setActiveListings(listingsRes.data.content?.filter(l => l.isBiddable && l.isActive) || []);
    } catch (err) {
      console.error('Failed to fetch bidding data:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchListingDetails = async () => {
    if (!listingId) return;
    try {
      const response = await api.get(`/api/listings/${listingId}`);
      setSelectedListing(response.data);
      if (response.data.highestBid) {
        setBidAmount((parseFloat(response.data.highestBid) + (response.data.bidIncrement || 0)).toString());
      } else if (response.data.startingPrice) {
        setBidAmount(response.data.startingPrice.toString());
      }
    } catch (err) {
      console.error('Failed to fetch listing:', err);
    }
  };

  const fetchListingBids = async (listingId) => {
    try {
      const response = await api.get(`/api/bids/listing/${listingId}`);
      setBids(response.data);
    } catch (err) {
      console.error('Failed to fetch bids:', err);
    }
  };

  const handlePlaceBid = async (e) => {
    e.preventDefault();
    setError('');
    try {
      await api.post('/api/bids', {
        listingId: selectedListing?.listingId || listingId,
        bidAmount: parseFloat(bidAmount)
      });
      setShowBidModal(false);
      setBidAmount('');
      fetchBiddingData();
      if (selectedListing) {
        fetchListingBids(selectedListing.listingId);
      }
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to place bid');
    }
  };

  const handleListingSelect = async (listing) => {
    setSelectedListing(listing);
    setShowBidModal(true);
    if (listing.highestBid) {
      setBidAmount((parseFloat(listing.highestBid) + (listing.bidIncrement || 0)).toString());
    } else if (listing.startingPrice) {
      setBidAmount(listing.startingPrice.toString());
    }
    await fetchListingBids(listing.listingId);
  };

  if (loading) {
    return (
      <>
        <Navigation />
        <div className="bidding-center">Loading...</div>
      </>
    );
  }

  return (
    <>
      <Navigation />
      <div className="bidding-center">
        <div className="container">
          <h1>Bidding Center</h1>

          <div className="tabs">
            <button
              className={activeTab === 'my-bids' ? 'active' : ''}
              onClick={() => setActiveTab('my-bids')}
            >
              My Bids
            </button>
            <button
              className={activeTab === 'active-listings' ? 'active' : ''}
              onClick={() => setActiveTab('active-listings')}
            >
              Active Listings
            </button>
          </div>

          {activeTab === 'my-bids' && (
            <div className="my-bids-section">
              <h2>My Bids</h2>
              {myBids.length === 0 ? (
                <div className="no-bids">No bids yet</div>
              ) : (
                <div className="bids-list">
                  {myBids.map(bid => (
                    <div key={bid.bidId} className="bid-card">
                      <div className="bid-header">
                        <Link to={`/listing/${bid.listingId}`} className="listing-link">
                          <h3>{bid.listingTitle}</h3>
                        </Link>
                        <span className={`bid-status ${bid.isWinning ? 'winning' : 'outbid'}`}>
                          {bid.isWinning ? 'Winning' : 'Outbid'}
                        </span>
                      </div>
                      <div className="bid-details">
                        <p className="bid-amount">₹{bid.bidAmount.toFixed(2)}</p>
                        <p className="bid-time">Placed: {new Date(bid.bidTime).toLocaleString()}</p>
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
                <div className="no-listings">No active biddable listings</div>
              ) : (
                <div className="listings-grid">
                  {activeListings.map(listing => (
                    <div key={listing.listingId} className="listing-card">
                      {listing.imageUrls && listing.imageUrls.length > 0 && (
                        <img src={listing.imageUrls[0]} alt={listing.title} />
                      )}
                      <div className="listing-info">
                        <h3>{listing.title}</h3>
                        <p className="price">Starting: ₹{listing.startingPrice || 'N/A'}</p>
                        {listing.highestBid && (
                          <p className="highest-bid">Highest: ₹{listing.highestBid.toFixed(2)}</p>
                        )}
                        {listing.bidCount > 0 && (
                          <p className="bid-count">{listing.bidCount} bid(s)</p>
                        )}
                        {listing.bidEndTime && (
                          <p className="end-time">
                            Ends: {new Date(listing.bidEndTime).toLocaleString()}
                          </p>
                        )}
                        <button
                          onClick={() => handleListingSelect(listing)}
                          className="bid-now-btn"
                        >
                          Place Bid
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {showBidModal && selectedListing && (
            <div className="modal-overlay" onClick={() => setShowBidModal(false)}>
              <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                <h2>Place Bid</h2>
                <div className="listing-summary">
                  <h3>{selectedListing.title}</h3>
                  <p>Starting Price: ₹{selectedListing.startingPrice || 'N/A'}</p>
                  {selectedListing.highestBid && (
                    <p>Current Highest: ₹{selectedListing.highestBid.toFixed(2)}</p>
                  )}
                  {selectedListing.bidIncrement && (
                    <p>Bid Increment: ₹{selectedListing.bidIncrement}</p>
                  )}
                  {selectedListing.bidEndTime && (
                    <p>Ends: {new Date(selectedListing.bidEndTime).toLocaleString()}</p>
                  )}
                </div>

                {bids.length > 0 && (
                  <div className="recent-bids">
                    <h4>Recent Bids</h4>
                    <div className="bids-list-small">
                      {bids.slice(0, 5).map(bid => (
                        <div key={bid.bidId} className="bid-item-small">
                          <span>{bid.userName}</span>
                          <span>₹{bid.bidAmount.toFixed(2)}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {error && <div className="error-message">{error}</div>}

                <form onSubmit={handlePlaceBid}>
                  <div className="form-group">
                    <label>Bid Amount (₹)</label>
                    <input
                      type="number"
                      step="0.01"
                      min={selectedListing.highestBid ? selectedListing.highestBid + (selectedListing.bidIncrement || 0) : selectedListing.startingPrice}
                      value={bidAmount}
                      onChange={(e) => setBidAmount(e.target.value)}
                      required
                    />
                    {selectedListing.bidIncrement && selectedListing.highestBid && (
                      <small>
                        Minimum: ₹{(selectedListing.highestBid + selectedListing.bidIncrement).toFixed(2)}
                      </small>
                    )}
                  </div>

                  <div className="modal-buttons">
                    <button type="submit" className="submit-btn">Place Bid</button>
                    <button type="button" onClick={() => setShowBidModal(false)} className="cancel-btn">
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
