import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import api from '../services/api';
import Navigation from '../components/Navigation';
import './MyProfile.css';

const MyProfile = () => {
  const { user } = useAuth();
  const [listings, setListings] = useState([]);
  const [ratings, setRatings] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchProfileData();
  }, []);

  const fetchProfileData = async () => {
    try {
      const [listingsRes, ratingsRes] = await Promise.all([
        api.get('/api/listings/my-listings'),
        api.get(`/api/ratings/user/${user?.userId}`)
      ]);
      setListings(listingsRes.data);
      setRatings(ratingsRes.data || []);
    } catch (err) {
      console.error('Failed to fetch profile data:', err);
      setRatings([]);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <>
        <Navigation />
        <div className="profile-page">Loading...</div>
      </>
    );
  }

  return (
    <>
      <Navigation />
      <div className="profile-page">
        <div className="container">
          <div className="profile-header">
            <h1>My Profile</h1>
            <div className="profile-info">
              <h2>{user?.fullName}</h2>
              <p>{user?.email}</p>
              <p className="trust-score">Trust Score: {user?.trustScore?.toFixed(1) || 'N/A'}</p>
              <p className="wallet-balance">Wallet Balance: ₹{user?.walletBalance || '0.00'}</p>
            </div>
          </div>

          <div className="profile-sections">
            <div className="section">
              <h2>My Listings ({listings.length})</h2>
              <div className="listings-grid">
                {listings.map(listing => (
                  <div key={listing.listingId} className="listing-card">
                    {listing.imageUrls && listing.imageUrls.length > 0 && (
                      <img src={listing.imageUrls[0]} alt={listing.title} />
                    )}
                    <div className="listing-info">
                      <h3>{listing.title}</h3>
                      <p className="price">₹{listing.price || 'Trade Only'}</p>
                      <p className={listing.isActive ? 'status active' : 'status inactive'}>
                        {listing.isActive ? 'Active' : 'Inactive'}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div className="section">
              <h2>My Ratings ({ratings.length})</h2>
              <div className="ratings-list">
                {ratings.map(rating => (
                  <div key={rating.ratingId} className="rating-item">
                    <div className="rating-header">
                      <span className="rating-value">{rating.ratingValue}/5</span>
                      <span className="from-user">From: {rating.fromUserName}</span>
                    </div>
                    {rating.reviewComment && (
                      <p className="review-comment">{rating.reviewComment}</p>
                    )}
                    {rating.listingTitle && (
                      <p className="listing-title">For: {rating.listingTitle}</p>
                    )}
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default MyProfile;
