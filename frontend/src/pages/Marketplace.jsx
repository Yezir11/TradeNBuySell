import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import api from '../services/api';
import { useAuth } from '../context/AuthContext';
import Navigation from '../components/Navigation';
import './Marketplace.css';

const Marketplace = () => {
  const { isAuthenticated, user } = useAuth();
  const navigate = useNavigate();
  const [listings, setListings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [category, setCategory] = useState('');
  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [error, setError] = useState(null);

  useEffect(() => {
    setPage(0);
  }, [searchQuery, category]);

  useEffect(() => {
    fetchListings();
  }, [searchQuery, category, page]);

  const fetchListings = async () => {
    setLoading(true);
    setError(null);
    try {
      const params = { page, size: 12, nonBiddableOnly: true };
      if (searchQuery) params.search = searchQuery;
      if (category) params.category = category;

      const response = await api.get('/api/listings', { params });
      const data = response.data;
      setListings(data.content || []);
      setTotalPages(data.totalPages || 0);
      setTotalElements(data.totalElements || 0);
    } catch (error) {
      console.error('Failed to fetch listings:', error);
      setError(error.response?.data?.message || error.message || 'Failed to load listings. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handlePageChange = (newPage) => {
    if (newPage >= 0 && newPage < totalPages) {
      setPage(newPage);
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
  };

  const handleBuyClick = (e, listing) => {
    e.preventDefault();
    e.stopPropagation();
    
    if (!isAuthenticated) {
      const shouldSignIn = window.confirm('You need to sign in to purchase items. Would you like to sign in now?');
      if (shouldSignIn) {
        navigate('/auth');
      }
      return;
    }
    
    // Check if user is trying to buy their own listing
    if (user?.userId === listing.userId) {
      alert('You cannot buy your own listing.');
      return;
    }
    
    // Navigate to listing details page where they can complete the purchase
    navigate(`/listing/${listing.listingId}`);
  };

  const categories = ['Electronics', 'Books', 'Furniture', 'Clothing', 'Sports', 'Stationery', 'Other'];

  return (
    <>
      <Navigation />
      <div className="marketplace">
        <div className="container">
          <h1>Marketplace</h1>

          <div className="filters">
            <input
              type="text"
              placeholder="Search listings..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="search-input"
            />
            <select value={category} onChange={(e) => setCategory(e.target.value)}>
              <option value="">All Categories</option>
              {categories.map(cat => (
                <option key={cat} value={cat}>{cat}</option>
              ))}
            </select>
          </div>

          {loading ? (
            <div className="loading">Loading listings...</div>
          ) : error ? (
            <div className="error-message">
              <p>{error}</p>
              <button onClick={fetchListings} className="retry-btn">Retry</button>
            </div>
          ) : listings.length === 0 ? (
            <div className="no-listings">No listings found</div>
          ) : (
            <>
              <div className="listings-info">
                <p>Showing {listings.length} of {totalElements} listings (Page {page + 1} of {totalPages})</p>
              </div>
              <div className="listings-grid">
                {listings.map(listing => {
                  const isOwner = isAuthenticated && user?.userId === listing.userId;
                  const hasPrice = listing.price && parseFloat(listing.price) > 0;
                  
                  return (
                    <div key={listing.listingId} className="listing-card-container">
                      <Link to={`/listing/${listing.listingId}`} className="listing-card">
                        <div className="listing-card-wrapper" style={{ position: 'relative' }}>
                          {listing.isFeatured && (
                            <div className="featured-ribbon">
                              <span>FEATURED</span>
                            </div>
                          )}
                          {listing.imageUrls && listing.imageUrls.length > 0 && (
                            <img src={listing.imageUrls[0]} alt={listing.title} />
                          )}
                          <div className="listing-info">
                            <h3>{listing.title}</h3>
                            {listing.sellerName && (
                              <p className="seller-name">Sold by: {listing.sellerName}</p>
                            )}
                            <p className="price">₹{listing.price || 'Trade Only'}</p>
                            <p className="category">{listing.category}</p>
                            {listing.sellerTrustScore && (
                              <p className="trust-score">Trust Score: {listing.sellerTrustScore.toFixed(1)}</p>
                            )}
                            <div className="badges">
                              {listing.isTradeable && <span className="badge trade">Trade</span>}
                              {listing.isBiddable && <span className="badge bid">Bid</span>}
                            </div>
                          </div>
                        </div>
                      </Link>
                      {!isOwner && (
                        <>
                          {hasPrice && (
                            <button 
                              className="buy-btn"
                              onClick={(e) => handleBuyClick(e, listing)}
                            >
                              {isAuthenticated ? 'Buy Now' : 'Sign in to Buy'}
                            </button>
                          )}
                          {!hasPrice && listing.isTradeable && (
                            <button 
                              className="buy-btn trade-btn-marketplace"
                              onClick={(e) => {
                                e.preventDefault();
                                e.stopPropagation();
                                if (!isAuthenticated) {
                                  const shouldSignIn = window.confirm('You need to sign in to propose trades. Would you like to sign in now?');
                                  if (shouldSignIn) {
                                    navigate('/auth');
                                  }
                                } else {
                                  navigate(`/listing/${listing.listingId}`);
                                }
                              }}
                            >
                              {isAuthenticated ? 'View Details' : 'Sign in to Trade'}
                            </button>
                          )}
                          {!hasPrice && !listing.isTradeable && !listing.isBiddable && (
                            <button 
                              className="buy-btn view-btn-marketplace"
                              onClick={(e) => {
                                e.preventDefault();
                                e.stopPropagation();
                                navigate(`/listing/${listing.listingId}`);
                              }}
                            >
                              View Details
                            </button>
                          )}
                        </>
                      )}
                    </div>
                  );
                })}
              </div>
              {totalPages > 1 && (
                <div className="pagination">
                  <button
                    onClick={() => handlePageChange(page - 1)}
                    disabled={page === 0}
                    className="pagination-btn"
                  >
                    Previous
                  </button>
                  <div className="pagination-info">
                    {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
                      let pageNum;
                      if (totalPages <= 5) {
                        pageNum = i;
                      } else if (page < 3) {
                        pageNum = i;
                      } else if (page > totalPages - 4) {
                        pageNum = totalPages - 5 + i;
                      } else {
                        pageNum = page - 2 + i;
                      }
                      return (
                        <button
                          key={pageNum}
                          onClick={() => handlePageChange(pageNum)}
                          className={`pagination-btn ${page === pageNum ? 'active' : ''}`}
                        >
                          {pageNum + 1}
                        </button>
                      );
                    })}
                  </div>
                  <button
                    onClick={() => handlePageChange(page + 1)}
                    disabled={page >= totalPages - 1}
                    className="pagination-btn"
                  >
                    Next
                  </button>
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </>
  );
};

export default Marketplace;
