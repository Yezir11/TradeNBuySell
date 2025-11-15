import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import api from '../services/api';
import { useAuth } from '../context/AuthContext';
import Navigation from '../components/Navigation';
import './ListingDetails.css';

const ListingDetails = () => {
  const { listingId } = useParams();
  const { isAuthenticated, user } = useAuth();
  const [listing, setListing] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [isInWishlist, setIsInWishlist] = useState(false);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [showOfferModal, setShowOfferModal] = useState(false);
  const [offerAmount, setOfferAmount] = useState('');
  const [offerMessage, setOfferMessage] = useState('');
  const [submittingOffer, setSubmittingOffer] = useState(false);
  const [walletBalance, setWalletBalance] = useState(null);

  useEffect(() => {
    fetchListing();
    if (isAuthenticated) {
      checkWishlist();
      fetchWalletBalance();
    }
  }, [listingId, isAuthenticated]);

  const fetchWalletBalance = async () => {
    try {
      const response = await api.get('/api/auth/profile');
      setWalletBalance(response.data.walletBalance);
    } catch (err) {
      console.error('Failed to fetch wallet balance:', err);
    }
  };

  const fetchListing = async () => {
    try {
      const response = await api.get(`/api/listings/${listingId}`);
      setListing(response.data);
    } catch (err) {
      setError('Failed to load listing');
    } finally {
      setLoading(false);
    }
  };

  const checkWishlist = async () => {
    try {
      const response = await api.get(`/api/wishlist/${listingId}/check`);
      setIsInWishlist(response.data);
    } catch (err) {
      console.error('Failed to check wishlist:', err);
    }
  };

  const toggleWishlist = async () => {
    if (!isAuthenticated) {
      alert('Please login to add to wishlist');
      return;
    }

    try {
      if (isInWishlist) {
        await api.delete(`/api/wishlist/${listingId}`);
        setIsInWishlist(false);
      } else {
        await api.post(`/api/wishlist/${listingId}`);
        setIsInWishlist(true);
      }
    } catch (err) {
      console.error('Failed to update wishlist:', err);
    }
  };

  const handleBuyNowClick = () => {
    if (!isAuthenticated) {
      const shouldSignIn = window.confirm('You need to sign in to make a purchase offer. Would you like to sign in now?');
      if (shouldSignIn) {
        window.location.href = '/auth';
      }
      return;
    }

    if (listing.price && parseFloat(listing.price) > 0) {
      setShowOfferModal(true);
      setOfferAmount(listing.price); // Pre-fill with listing price
    } else {
      alert('This listing does not have a price. It is trade-only.');
    }
  };

  const handleSubmitOffer = async (e) => {
    e.preventDefault();
    
    if (!offerAmount || parseFloat(offerAmount) <= 0) {
      alert('Please enter a valid offer amount');
      return;
    }

    setSubmittingOffer(true);
    try {
      await api.post('/api/offers', {
        listingId: listingId,
        offerAmount: parseFloat(offerAmount),
        message: offerMessage
      });
      
      alert('Your offer has been sent to the seller! Check your chat for updates.');
      setShowOfferModal(false);
      setOfferAmount('');
      setOfferMessage('');
      
      // Navigate to chat with seller
      window.location.href = `/chat?userId=${listing.userId}&listingId=${listingId}`;
    } catch (err) {
      console.error('Failed to submit offer:', err);
      alert(err.response?.data?.message || 'Failed to submit offer. Please try again.');
    } finally {
      setSubmittingOffer(false);
    }
  };

  if (loading) {
    return (
      <>
        <Navigation />
        <div className="listing-details">Loading...</div>
      </>
    );
  }

  if (error || !listing) {
    return (
      <>
        <Navigation />
        <div className="listing-details">Error: {error || 'Listing not found'}</div>
      </>
    );
  }

  const isOwner = isAuthenticated && user?.userId === listing.userId;

  return (
    <>
      <Navigation />
      <div className="listing-details">
        <div className="container">
          <Link to="/marketplace" className="back-link">← Back to Marketplace</Link>

          <div className="listing-content">
            <div className="listing-images">
              {listing.imageUrls && listing.imageUrls.length > 0 ? (
                <>
                  <div className="main-image">
                    <img src={listing.imageUrls[currentImageIndex]} alt={listing.title} />
                  </div>
                  {listing.imageUrls.length > 1 && (
                    <div className="thumbnail-images">
                      {listing.imageUrls.map((url, index) => (
                        <img
                          key={index}
                          src={url}
                          alt={`${listing.title} ${index + 1}`}
                          className={index === currentImageIndex ? 'active' : ''}
                          onClick={() => setCurrentImageIndex(index)}
                        />
                      ))}
                    </div>
                  )}
                </>
              ) : (
                <div className="no-image">No image available</div>
              )}
            </div>

            <div className="listing-info">
              <h1>{listing.title}</h1>
              <div className="listing-meta">
                <p className="price">₹{listing.price || 'Trade Only'}</p>
                <p className="category">{listing.category}</p>
                {listing.sellerTrustScore && (
                  <p className="trust-score">Seller Trust Score: {listing.sellerTrustScore.toFixed(1)}</p>
                )}
              </div>

              <div className="badges">
                {listing.isTradeable && <span className="badge trade">Tradeable</span>}
                {listing.isBiddable && <span className="badge bid">Biddable</span>}
                {listing.highestBid && (
                  <span className="badge bid-info">Highest Bid: ₹{listing.highestBid}</span>
                )}
              </div>

              <div className="description">
                <h2>Description</h2>
                <p>{listing.description}</p>
              </div>

              {listing.tags && listing.tags.length > 0 && (
                <div className="tags">
                  {listing.tags.map((tag, index) => (
                    <span key={index} className="tag">{tag}</span>
                  ))}
                </div>
              )}

              {!isOwner && isAuthenticated && (
                <div className="actions">
                  <button onClick={toggleWishlist} className="wishlist-btn">
                    {isInWishlist ? '❤️ Remove from Wishlist' : '🤍 Add to Wishlist'}
                  </button>
                  <Link to={`/chat?userId=${listing.userId}&listingId=${listingId}`} className="contact-btn">
                    Contact Seller
                  </Link>
                  {listing.price && parseFloat(listing.price) > 0 && !listing.isBiddable && (
                    <button onClick={handleBuyNowClick} className="buy-now-btn">
                      Buy Now
                    </button>
                  )}
                  {listing.isTradeable && (
                    <Link to={`/trades?listingId=${listingId}`} className="trade-btn">
                      Propose Trade
                    </Link>
                  )}
                  {listing.isBiddable && (
                    <Link to={`/bids?listingId=${listingId}`} className="bid-btn">
                      Place Bid
                    </Link>
                  )}
                </div>
              )}

              {isOwner && (
                <div className="owner-actions">
                  <Link to={`/listing/${listingId}/edit`} className="edit-btn">Edit Listing</Link>
                  <button className="delete-btn">Deactivate Listing</button>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Offer Modal */}
      {showOfferModal && (
        <div className="modal-overlay" onClick={() => setShowOfferModal(false)}>
          <div className="modal-content offer-modal" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Make a Purchase Offer</h2>
              <button className="close-btn" onClick={() => setShowOfferModal(false)}>×</button>
            </div>
            <div className="modal-body">
              <div className="listing-summary">
                {listing.imageUrls && listing.imageUrls.length > 0 && (
                  <img src={listing.imageUrls[0]} alt={listing.title} className="listing-thumbnail" />
                )}
                <div>
                  <h3>{listing.title}</h3>
                  <p className="original-price">Original Price: ₹{listing.price}</p>
                </div>
              </div>
              
              <form onSubmit={handleSubmitOffer}>
                <div className="form-group">
                  <label htmlFor="offerAmount">Your Offer Amount (₹)</label>
                  <input
                    type="number"
                    id="offerAmount"
                    value={offerAmount}
                    onChange={(e) => setOfferAmount(e.target.value)}
                    min="1"
                    step="0.01"
                    required
                    placeholder="Enter your offer"
                  />
                  {walletBalance !== null && (
                    <p className="wallet-info">
                      Your wallet balance: ₹{parseFloat(walletBalance).toFixed(2)}
                      {parseFloat(offerAmount) > parseFloat(walletBalance) && (
                        <span className="insufficient-funds"> (Insufficient funds)</span>
                      )}
                    </p>
                  )}
                </div>
                
                <div className="form-group">
                  <label htmlFor="offerMessage">Message to Seller (Optional)</label>
                  <textarea
                    id="offerMessage"
                    value={offerMessage}
                    onChange={(e) => setOfferMessage(e.target.value)}
                    rows="4"
                    placeholder="Add a message to the seller..."
                  />
                </div>
                
                <div className="modal-actions">
                  <button type="button" className="btn-cancel" onClick={() => setShowOfferModal(false)}>
                    Cancel
                  </button>
                  <button type="submit" className="btn-submit" disabled={submittingOffer}>
                    {submittingOffer ? 'Submitting...' : 'Place Offer'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default ListingDetails;
