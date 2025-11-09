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

  useEffect(() => {
    fetchListing();
    if (isAuthenticated) {
      checkWishlist();
    }
  }, [listingId, isAuthenticated]);

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
    </>
  );
};

export default ListingDetails;
