import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { Link } from 'react-router-dom';
import api from '../services/api';
import Navigation from '../components/Navigation';
import './MyProfile.css';

const MyProfile = () => {
  const { user, loading: authLoading } = useAuth();
  const [profile, setProfile] = useState(null);
  const [listings, setListings] = useState([]);
  const [ratings, setRatings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    if (!authLoading && user?.userId) {
      fetchProfileData();
    } else if (!authLoading && !user) {
      setLoading(false);
      setError('Please log in to view your profile');
    }
  }, [authLoading, user]);

  const fetchProfileData = async () => {
    if (!user?.userId) {
      setLoading(false);
      return;
    }

    try {
      setError('');
      const [profileRes, listingsRes, ratingsRes] = await Promise.all([
        api.get('/api/auth/profile'),
        api.get('/api/listings/my-listings?activeOnly=false'),
        api.get(`/api/ratings/user/${user.userId}`).catch(() => ({ data: [] }))
      ]);
      
      setProfile(profileRes.data);
      setListings(listingsRes.data || []);
      setRatings(ratingsRes.data || []);
    } catch (err) {
      console.error('Failed to fetch profile data:', err);
      setError(err.response?.data?.message || 'Failed to load profile data');
      setListings([]);
      setRatings([]);
    } finally {
      setLoading(false);
    }
  };

  if (authLoading || loading) {
    return (
      <>
        <Navigation />
        <div className="profile-page">
          <div className="container">
            <div className="loading-container">
              <p>Loading profile...</p>
            </div>
          </div>
        </div>
      </>
    );
  }

  if (error && !profile) {
    return (
      <>
        <Navigation />
        <div className="profile-page">
          <div className="container">
            <div className="error-container">
              <p>{error}</p>
              <Link to="/auth" className="login-link">Please log in</Link>
            </div>
          </div>
        </div>
      </>
    );
  }

  if (!profile) {
    return (
      <>
        <Navigation />
        <div className="profile-page">
          <div className="container">
            <div className="error-container">
              <p>Unable to load profile data</p>
            </div>
          </div>
        </div>
      </>
    );
  }

  const activeListings = listings.filter(l => l.isActive);
  const inactiveListings = listings.filter(l => !l.isActive);

  return (
    <>
      <Navigation />
      <div className="profile-page">
        <div className="container">
          <div className="profile-header">
            <h1>My Profile</h1>
            <div className="profile-info">
              <h2>{profile.fullName || user?.fullName || 'User'}</h2>
              <p className="profile-email">{profile.email || user?.email}</p>
              <div className="profile-stats">
                <div className="stat-item">
                  <span className="stat-label">Trust Score:</span>
                  <span className="trust-score">{profile.trustScore ? profile.trustScore.toFixed(1) : 'N/A'}</span>
                </div>
                <div className="stat-item">
                  <span className="stat-label">Wallet Balance:</span>
                  <span className="wallet-balance">₹{profile.walletBalance ? parseFloat(profile.walletBalance).toFixed(2) : '0.00'}</span>
                </div>
                {profile.registeredAt && (
                  <div className="stat-item">
                    <span className="stat-label">Member Since:</span>
                    <span>{new Date(profile.registeredAt).toLocaleDateString()}</span>
                  </div>
                )}
              </div>
              {profile.isSuspended && (
                <div className="suspended-warning">
                  ⚠️ Your account is currently suspended
                </div>
              )}
            </div>
          </div>

          {error && (
            <div className="error-message">
              {error}
            </div>
          )}

          <div className="profile-sections">
            <div className="section">
              <div className="section-header">
                <h2>My Listings ({listings.length})</h2>
                <Link to="/post-listing" className="new-listing-btn">+ Create New Listing</Link>
              </div>
              
              {listings.length === 0 ? (
                <div className="empty-state">
                  <p>You haven't created any listings yet.</p>
                  <Link to="/post-listing" className="cta-link">Create Your First Listing</Link>
                </div>
              ) : (
                <>
                  {activeListings.length > 0 && (
                    <div className="listings-section">
                      <h3>Active Listings ({activeListings.length})</h3>
                      <div className="listings-grid">
                        {activeListings.map(listing => (
                          <Link key={listing.listingId} to={`/listing/${listing.listingId}`} className="listing-card-link">
                            <div className="listing-card">
                              {listing.imageUrls && listing.imageUrls.length > 0 ? (
                                <img src={listing.imageUrls[0]} alt={listing.title} onError={(e) => { e.target.src = '/placeholder-image.jpg'; }} />
                              ) : (
                                <div className="listing-image-placeholder">No Image</div>
                              )}
                              <div className="listing-info">
                                <h3>{listing.title}</h3>
                                <p className="price">₹{listing.price ? parseFloat(listing.price).toFixed(2) : 'Trade Only'}</p>
                                <p className="status active">Active</p>
                                {listing.isTradeable && <span className="badge tradeable">Tradeable</span>}
                                {listing.isBiddable && <span className="badge biddable">Biddable</span>}
                              </div>
                            </div>
                          </Link>
                        ))}
                      </div>
                    </div>
                  )}

                  {inactiveListings.length > 0 && (
                    <div className="listings-section">
                      <h3>Inactive Listings ({inactiveListings.length})</h3>
                      <div className="listings-grid">
                        {inactiveListings.map(listing => (
                          <Link key={listing.listingId} to={`/listing/${listing.listingId}`} className="listing-card-link">
                            <div className="listing-card">
                              {listing.imageUrls && listing.imageUrls.length > 0 ? (
                                <img src={listing.imageUrls[0]} alt={listing.title} onError={(e) => { e.target.src = '/placeholder-image.jpg'; }} />
                              ) : (
                                <div className="listing-image-placeholder">No Image</div>
                              )}
                              <div className="listing-info">
                                <h3>{listing.title}</h3>
                                <p className="price">₹{listing.price ? parseFloat(listing.price).toFixed(2) : 'Trade Only'}</p>
                                <p className="status inactive">Inactive</p>
                              </div>
                            </div>
                          </Link>
                        ))}
                      </div>
                    </div>
                  )}
                </>
              )}
            </div>

            <div className="section">
              <h2>My Ratings ({ratings.length})</h2>
              {ratings.length === 0 ? (
                <div className="empty-state">
                  <p>You haven't received any ratings yet.</p>
                </div>
              ) : (
                <div className="ratings-list">
                  {ratings.map(rating => (
                    <div key={rating.ratingId} className="rating-item">
                      <div className="rating-header">
                        <span className="rating-value">{rating.ratingValue}/5</span>
                        <span className="from-user">From: {rating.fromUserName || 'Unknown User'}</span>
                      </div>
                      {rating.reviewComment && (
                        <p className="review-comment">"{rating.reviewComment}"</p>
                      )}
                      {rating.listingTitle && (
                        <p className="listing-title">For: {rating.listingTitle}</p>
                      )}
                      {rating.timestamp && (
                        <p className="rating-date">{new Date(rating.timestamp).toLocaleDateString()}</p>
                      )}
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default MyProfile;
