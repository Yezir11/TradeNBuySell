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
  const [filteredListings, setFilteredListings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchQuery, setSearchQuery] = useState('');
  const [activeFilter, setActiveFilter] = useState('all');
  const [showMenu, setShowMenu] = useState(null);

  useEffect(() => {
    if (!authLoading && user?.userId) {
      fetchProfileData();
    } else if (!authLoading && !user) {
      setLoading(false);
      setError('Please log in to view your profile');
    }
  }, [authLoading, user]);

  // Close menu when clicking outside
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (showMenu && !event.target.closest('.listing-menu')) {
        setShowMenu(null);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [showMenu]);

  const fetchProfileData = async () => {
    if (!user?.userId) {
      setLoading(false);
      return;
    }

    try {
      setError('');
      const [profileRes, listingsRes] = await Promise.all([
        api.get('/api/auth/profile'),
        api.get('/api/listings/my-listings?activeOnly=false')
      ]);
      
      setProfile(profileRes.data);
      const listingsData = listingsRes.data || [];
      setListings(listingsData);
      setFilteredListings(listingsData);
    } catch (err) {
      console.error('Failed to fetch profile data:', err);
      setError(err.response?.data?.message || 'Failed to load profile data');
      setListings([]);
      setFilteredListings([]);
    } finally {
      setLoading(false);
    }
  };

  // Filter and search listings
  useEffect(() => {
    let filtered = listings;

    // Apply status filter
    if (activeFilter === 'active') {
      filtered = filtered.filter(l => l.isActive);
    } else if (activeFilter === 'inactive') {
      filtered = filtered.filter(l => !l.isActive);
    } else if (activeFilter === 'pending') {
      // Listings that are active but have moderation pending (we'll check if they have pending moderation)
      filtered = filtered.filter(l => l.isActive);
    } else if (activeFilter === 'moderated') {
      // Listings that were moderated (we can check this later if needed)
      filtered = filtered.filter(l => !l.isActive);
    }

    // Apply search query
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(l => 
        l.title.toLowerCase().includes(query) ||
        l.description.toLowerCase().includes(query)
      );
    }

    setFilteredListings(filtered);
  }, [listings, activeFilter, searchQuery]);

  const handleDeactivateListing = async (listingId) => {
    if (window.confirm('Are you sure you want to deactivate this listing?')) {
      try {
        await api.delete(`/api/listings/${listingId}`);
        // Refresh listings
        fetchProfileData();
      } catch (err) {
        console.error('Failed to deactivate listing:', err);
        alert(err.response?.data?.message || 'Failed to deactivate listing');
      }
    }
  };

  const handleRemoveListing = async (listingId) => {
    if (window.confirm('Are you sure you want to remove this listing? This action cannot be undone.')) {
      try {
        await api.delete(`/api/listings/${listingId}`);
        // Refresh listings
        fetchProfileData();
      } catch (err) {
        console.error('Failed to remove listing:', err);
        alert(err.response?.data?.message || 'Failed to remove listing');
      }
    }
  };

  const getStatusColor = (listing) => {
    if (!listing.isActive) return '#dc3545'; // Red for inactive
    return '#007bff'; // Blue for active
  };

  const getStatusText = (listing) => {
    if (!listing.isActive) return 'INACTIVE';
    return 'ACTIVE';
  };

  const getStatusMessage = (listing) => {
    if (!listing.isActive) {
      return 'This listing is inactive. If you sold it, you can remove it.';
    }
    return 'This listing is currently live';
  };

  const formatDate = (date) => {
    if (!date) return '';
    try {
      const d = new Date(date);
      if (isNaN(d.getTime())) return '';
      const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
      return `${months[d.getMonth()]} ${d.getDate()}, ${d.getFullYear().toString().slice(-2)}`;
    } catch (e) {
      return '';
    }
  };

  const getImageUrl = (imageUrl) => {
    if (!imageUrl) return null;
    // If it's already a full URL, return as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    // If it's a relative path starting with /, prepend the backend URL
    if (imageUrl.startsWith('/')) {
      const backendUrl = process.env.REACT_APP_API_URL || 'http://localhost:8080';
      return `${backendUrl}${imageUrl}`;
    }
    // Otherwise, assume it's a relative path and prepend the backend URL with /
    const backendUrl = process.env.REACT_APP_API_URL || 'http://localhost:8080';
    return `${backendUrl}/${imageUrl}`;
  };

  const getDateRange = (listing) => {
    const fromDate = formatDate(listing.createdAt);
    let toDate = '';
    
    if (listing.bidEndTime) {
      toDate = formatDate(listing.bidEndTime);
    } else if (listing.updatedAt && listing.updatedAt !== listing.createdAt) {
      toDate = formatDate(listing.updatedAt);
    }
    
    return { fromDate, toDate };
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

  const activeCount = listings.filter(l => l.isActive).length;
  const inactiveCount = listings.filter(l => !l.isActive).length;
  const pendingCount = 0; // Can be implemented later with moderation status
  const moderatedCount = 0; // Can be implemented later with moderation status

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
                <h2>My Listings</h2>
                <Link to="/post-listing" className="new-listing-btn">+ Create New Listing</Link>
              </div>
              
              {listings.length === 0 ? (
                <div className="empty-state">
                  <p>You haven't created any listings yet.</p>
                  <Link to="/post-listing" className="cta-link">Create Your First Listing</Link>
                </div>
              ) : (
                <>
                  {/* Search and Filter Section */}
                  <div className="listings-controls">
                    <div className="search-container">
                      <i className="fas fa-search search-icon"></i>
                      <input
                        type="text"
                        className="search-input"
                        placeholder="Search by Listing Title"
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                      />
                    </div>
                    <div className="filter-container">
                      <span className="filter-label">Filter By:</span>
                      <div className="filter-buttons">
                        <button
                          className={`filter-btn ${activeFilter === 'all' ? 'active' : ''}`}
                          onClick={() => setActiveFilter('all')}
                        >
                          View all ({listings.length})
                        </button>
                        <button
                          className={`filter-btn ${activeFilter === 'active' ? 'active' : ''}`}
                          onClick={() => setActiveFilter('active')}
                        >
                          Active Ads ({activeCount})
                        </button>
                        <button
                          className={`filter-btn ${activeFilter === 'inactive' ? 'active' : ''}`}
                          onClick={() => setActiveFilter('inactive')}
                        >
                          Inactive Ads ({inactiveCount})
                        </button>
                        <button
                          className={`filter-btn ${activeFilter === 'pending' ? 'active' : ''}`}
                          onClick={() => setActiveFilter('pending')}
                        >
                          Pending Ads ({pendingCount})
                        </button>
                        <button
                          className={`filter-btn ${activeFilter === 'moderated' ? 'active' : ''}`}
                          onClick={() => setActiveFilter('moderated')}
                        >
                          Moderated Ads ({moderatedCount})
                        </button>
                      </div>
                    </div>
                  </div>

                  {/* Listings List */}
                  <div className="listings-list">
                    {filteredListings.length === 0 ? (
                      <div className="empty-state">
                        <p>No listings match your search criteria.</p>
                      </div>
                    ) : (
                      filteredListings.map((listing, index) => {
                        const statusColor = getStatusColor(listing);
                        const statusText = getStatusText(listing);
                        const statusMessage = getStatusMessage(listing);
                        const { fromDate, toDate } = getDateRange(listing);
                        
                        // Debug: Log first listing to check data
                        if (index === 0) {
                          console.log('First listing data:', {
                            listingId: listing.listingId,
                            title: listing.title,
                            price: listing.price,
                            imageUrls: listing.imageUrls,
                            isActive: listing.isActive,
                            createdAt: listing.createdAt
                          });
                        }
                        
                        return (
                          <Link 
                            key={listing.listingId} 
                            to={`/listing/${listing.listingId}`}
                            className="listing-item-link"
                          >
                            <div className="listing-item">
                              <div className="status-bar" style={{ backgroundColor: statusColor }}></div>
                              <div className="listing-content">
                                <div className="listing-date-range">
                                  FROM: {fromDate} {toDate && `TO: ${toDate}`}
                                </div>
                                <div className="listing-main">
                                  <div className="listing-image-container">
                                    {listing.imageUrls && listing.imageUrls.length > 0 ? (
                                      <img 
                                        src={getImageUrl(listing.imageUrls[0])} 
                                        alt={listing.title || 'Listing image'}
                                        className="listing-image"
                                        onError={(e) => { 
                                          e.target.src = 'https://via.placeholder.com/150x150?text=No+Image';
                                          e.target.onerror = null;
                                        }}
                                      />
                                    ) : (
                                      <div className="listing-image-placeholder">No Image</div>
                                    )}
                                  </div>
                                  <div className="listing-details">
                                    <h3 className="listing-title">{listing.title || 'Untitled Listing'}</h3>
                                    {listing.description && (
                                      <p className="listing-description">
                                        {listing.description.length > 150 
                                          ? `${listing.description.substring(0, 150)}...` 
                                          : listing.description}
                                      </p>
                                    )}
                                    <div className="listing-price-badge-container">
                                      <p className="listing-price">
                                        {listing.price ? `₹${parseFloat(listing.price).toLocaleString('en-IN')}` : 'Trade Only'}
                                      </p>
                                      <button 
                                        className={`status-badge ${listing.isActive ? 'active' : 'inactive'}`} 
                                        type="button"
                                        onClick={(e) => {
                                          e.preventDefault();
                                          e.stopPropagation();
                                        }}
                                      >
                                        {statusText}
                                      </button>
                                    </div>
                                    <div className="listing-stats">
                                      <span>Views: {listing.bidCount || 0}</span>
                                      <span>Likes: 0</span>
                                    </div>
                                    {listing.category && (
                                      <span className="listing-category-badge">{listing.category}</span>
                                    )}
                                  </div>
                                </div>
                                <div className="listing-status-message">
                                  {statusMessage}
                                </div>
                                <div className="listing-actions">
                                  {listing.isActive ? (
                                    <>
                                      <button 
                                        className="action-btn mark-sold-btn"
                                        onClick={(e) => {
                                          e.preventDefault();
                                          e.stopPropagation();
                                          handleDeactivateListing(listing.listingId);
                                        }}
                                      >
                                        Mark as sold
                                      </button>
                                      <button 
                                        className="action-btn sell-faster-btn"
                                        onClick={(e) => {
                                          e.preventDefault();
                                          e.stopPropagation();
                                        }}
                                      >
                                        Sell faster now
                                      </button>
                                    </>
                                  ) : (
                                    <button 
                                      className="action-btn remove-btn"
                                      onClick={(e) => {
                                        e.preventDefault();
                                        e.stopPropagation();
                                        handleRemoveListing(listing.listingId);
                                      }}
                                    >
                                      Remove
                                    </button>
                                  )}
                                </div>
                                <div className="listing-menu">
                                  <button 
                                    className="menu-icon"
                                    onClick={(e) => {
                                      e.preventDefault();
                                      e.stopPropagation();
                                      setShowMenu(showMenu === listing.listingId ? null : listing.listingId);
                                    }}
                                  >
                                    <i className="fas fa-ellipsis-v"></i>
                                  </button>
                                  {showMenu === listing.listingId && (
                                    <div className="menu-dropdown" onClick={(e) => e.stopPropagation()}>
                                      <Link 
                                        to={`/listing/${listing.listingId}`} 
                                        className="menu-item"
                                        onClick={() => setShowMenu(null)}
                                      >
                                        View Details
                                      </Link>
                                      {listing.isActive ? (
                                        <button 
                                          className="menu-item"
                                          onClick={() => {
                                            handleDeactivateListing(listing.listingId);
                                            setShowMenu(null);
                                          }}
                                        >
                                          Deactivate
                                        </button>
                                      ) : (
                                        <button 
                                          className="menu-item"
                                          onClick={() => {
                                            handleRemoveListing(listing.listingId);
                                            setShowMenu(null);
                                          }}
                                        >
                                          Remove
                                        </button>
                                      )}
                                    </div>
                                  )}
                                </div>
                              </div>
                            </div>
                          </Link>
                        );
                      })
                    )}
                  </div>
                </>
              )}
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default MyProfile;
