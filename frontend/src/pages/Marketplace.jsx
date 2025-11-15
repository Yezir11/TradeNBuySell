import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import api from '../services/api';
import { useAuth } from '../context/AuthContext';
import MarketplaceHeader from '../components/MarketplaceHeader';
import './Marketplace.css';

const Marketplace = () => {
  const { isAuthenticated, user } = useAuth();
  const navigate = useNavigate();
  const [listings, setListings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [category, setCategory] = useState('');
  const [minPrice, setMinPrice] = useState(0);
  const [maxPrice, setMaxPrice] = useState(200000);
  const [sortBy, setSortBy] = useState('date'); // date, price_low, price_high
  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [error, setError] = useState(null);
  const [priceRange, setPriceRange] = useState([0, 200000]);

  const categories = ['Electronics', 'Books', 'Furniture', 'Clothing', 'Sports', 'Stationery', 'Appliances', 'Other'];

  useEffect(() => {
    setPage(0);
  }, [searchQuery, category, minPrice, maxPrice, sortBy]);

  useEffect(() => {
    fetchListings();
  }, [searchQuery, category, minPrice, maxPrice, sortBy, page]);

  const fetchListings = async () => {
    setLoading(true);
    setError(null);
    try {
      const params = { page, size: 12, nonBiddableOnly: true };
      if (searchQuery) params.search = searchQuery;
      if (category) params.category = category;

      const response = await api.get('/api/listings', { params });
      let data = response.data;
      let fetchedListings = data.content || [];

      // Client-side filtering by price
      if (minPrice > 0 || maxPrice < 200000) {
        fetchedListings = fetchedListings.filter(listing => {
          if (!listing.price || listing.price === 0) return true; // Trade-only items
          const price = parseFloat(listing.price);
          return price >= minPrice && price <= maxPrice;
        });
      }

      // Client-side sorting
      fetchedListings = [...fetchedListings].sort((a, b) => {
        if (sortBy === 'price_low') {
          const priceA = a.price ? parseFloat(a.price) : Infinity;
          const priceB = b.price ? parseFloat(b.price) : Infinity;
          return priceA - priceB;
        } else if (sortBy === 'price_high') {
          const priceA = a.price ? parseFloat(a.price) : 0;
          const priceB = b.price ? parseFloat(b.price) : 0;
          return priceB - priceA;
        } else { // date (default)
          return new Date(b.createdAt) - new Date(a.createdAt);
        }
      });

      // Separate featured and regular listings
      const featuredListings = fetchedListings.filter(l => l.isFeatured);
      const regularListings = fetchedListings.filter(l => !l.isFeatured);

      // Featured listings first, then regular
      setListings([...featuredListings, ...regularListings]);
      setTotalPages(data.totalPages || 0);
      setTotalElements(fetchedListings.length);
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

  const handleSearch = (e) => {
    e.preventDefault();
    setPage(0);
    fetchListings();
  };

  const handleCategoryClick = (cat) => {
    setCategory(cat === category ? '' : cat);
    setPage(0);
  };

  const handlePriceRangeChange = (e) => {
    const value = parseInt(e.target.value);
    if (e.target.id === 'minPrice') {
      setMinPrice(value);
      setPriceRange([value, priceRange[1]]);
    } else {
      setMaxPrice(value);
      setPriceRange([priceRange[0], value]);
    }
  };

  const handleApplyPriceFilter = () => {
    setPage(0);
    fetchListings();
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
    
    if (user?.userId === listing.userId) {
      alert('You cannot buy your own listing.');
      return;
    }
    
    navigate(`/listing/${listing.listingId}`);
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffTime = Math.abs(now - date);
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffDays === 0) return 'Today';
    if (diffDays === 1) return 'Yesterday';
    if (diffDays < 7) return `${diffDays} days ago`;
    return date.toLocaleDateString('en-IN', { day: 'numeric', month: 'short' });
  };

  const handleSearchChange = (query) => {
    setSearchQuery(query);
    setPage(0);
  };

  const handleSearchSubmit = (query) => {
    // This is called when user explicitly submits (Enter key or button click)
    // The search is already handled by onSearchChange, but we can use this for immediate search if needed
    setSearchQuery(query);
    setPage(0);
  };

  return (
    <>
      <MarketplaceHeader onSearchChange={handleSearchChange} onSearchSubmit={handleSearchSubmit} initialSearchQuery={searchQuery} />

      {/* Category Navigation Bar */}
      <div className="category-nav-bar">
        <div className="category-nav-container">
          <Link to="/marketplace" className={`category-nav-item ${!category ? 'active' : ''}`}>
            ALL CATEGORIES
          </Link>
          {categories.map(cat => (
            <button
              key={cat}
              className={`category-nav-item ${category === cat ? 'active' : ''}`}
              onClick={() => handleCategoryClick(cat)}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      <div className="marketplace">
        <div className="marketplace-container">
          {/* Breadcrumbs */}
          <div className="breadcrumbs">
            <Link to="/">Home</Link>
            <span>/</span>
            <span>Marketplace</span>
            {category && (
              <>
                <span>/</span>
                <span>{category}</span>
              </>
            )}
          </div>

          {/* Page Title */}
          <div className="marketplace-title-section">
            <h1>{totalElements} Listings in Marketplace</h1>
            {category && <p>Browse {category.toLowerCase()} listings on TradeNBuySell</p>}
          </div>

          <div className="marketplace-content">
            {/* Left Sidebar - Filters */}
            <div className="marketplace-sidebar">
              <div className="sidebar-section">
                <h3>CATEGORIES</h3>
                <div className="category-filters">
                  <button
                    className={`category-filter-item ${!category ? 'active' : ''}`}
                    onClick={() => handleCategoryClick('')}
                  >
                    All Categories
                  </button>
                  {categories.map(cat => (
                    <button
                      key={cat}
                      className={`category-filter-item ${category === cat ? 'active' : ''}`}
                      onClick={() => handleCategoryClick(cat)}
                    >
                      {cat}
                    </button>
                  ))}
                </div>
              </div>

              <div className="sidebar-section">
                <h3>BUDGET</h3>
                <div className="budget-filter">
                  <div className="price-inputs">
                    <input
                      type="number"
                      id="minPrice"
                      placeholder="Min"
                      value={minPrice || ''}
                      onChange={(e) => setMinPrice(parseInt(e.target.value) || 0)}
                      onBlur={handleApplyPriceFilter}
                    />
                    <span>to</span>
                    <input
                      type="number"
                      id="maxPrice"
                      placeholder="Max"
                      value={maxPrice === 200000 ? '' : maxPrice}
                      onChange={(e) => setMaxPrice(parseInt(e.target.value) || 200000)}
                      onBlur={handleApplyPriceFilter}
                    />
                  </div>
                  <div className="price-slider-wrapper">
                    <input
                      type="range"
                      min="0"
                      max="200000"
                      step="1000"
                      value={priceRange[0]}
                      onChange={(e) => {
                        const newMin = parseInt(e.target.value);
                        setPriceRange([newMin, priceRange[1]]);
                        setMinPrice(newMin);
                      }}
                      className="price-slider"
                    />
                    <input
                      type="range"
                      min="0"
                      max="200000"
                      step="1000"
                      value={priceRange[1]}
                      onChange={(e) => {
                        const newMax = parseInt(e.target.value);
                        setPriceRange([priceRange[0], newMax]);
                        setMaxPrice(newMax);
                      }}
                      className="price-slider"
                    />
                  </div>
                  <button className="apply-filter-btn" onClick={handleApplyPriceFilter}>
                    Apply
                  </button>
                </div>
              </div>
            </div>

            {/* Main Content Area */}
            <div className="marketplace-main">
              {/* Listings Info and Sort */}
              <div className="listings-header">
                <div className="listings-count">
                  {totalElements} {totalElements === 1 ? 'ad' : 'ads'} in Marketplace
                </div>
                <div className="sort-options">
                  <span>SORT BY:</span>
                  <select value={sortBy} onChange={(e) => setSortBy(e.target.value)} className="sort-select">
                    <option value="date">Date Published</option>
                    <option value="price_low">Price: Low to High</option>
                    <option value="price_high">Price: High to Low</option>
                  </select>
                </div>
              </div>

              {/* Listings Grid */}
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
                  <div className="listings-grid">
                    {listings.map(listing => {
                      const isOwner = isAuthenticated && user?.userId === listing.userId;
                      const hasPrice = listing.price && parseFloat(listing.price) > 0;
                      
                      return (
                        <div key={listing.listingId} className="listing-card-olx">
                          <Link to={`/listing/${listing.listingId}`} className="listing-card-link">
                            <div className="listing-image-wrapper">
                              {listing.isFeatured && (
                                <div className="featured-tag-olx">FEATURED</div>
                              )}
                              {listing.imageUrls && listing.imageUrls.length > 0 ? (
                                <img src={listing.imageUrls[0]} alt={listing.title} className="listing-image-olx" />
                              ) : (
                                <div className="no-image-placeholder">No Image</div>
                              )}
                              <button 
                                className="favorite-btn-olx"
                                onClick={(e) => {
                                  e.preventDefault();
                                  e.stopPropagation();
                                  // TODO: Add to wishlist
                                }}
                              >
                                <i className="far fa-heart"></i>
                              </button>
                            </div>
                            <div className="listing-content-olx">
                              <div className="listing-price-olx">₹{listing.price ? parseFloat(listing.price).toLocaleString('en-IN') : 'Trade Only'}</div>
                              <div className="listing-title-olx">{listing.title}</div>
                              <div className="listing-meta-olx">
                                {listing.category && (
                                  <span className="listing-category-olx">{listing.category}</span>
                                )}
                                {listing.sellerName && (
                                  <span className="listing-seller-olx">{listing.sellerName}</span>
                                )}
                              </div>
                              <div className="listing-date-olx">{formatDate(listing.createdAt)}</div>
                            </div>
                          </Link>
                          {!isOwner && hasPrice && (
                            <button 
                              className="buy-btn-olx"
                              onClick={(e) => handleBuyClick(e, listing)}
                            >
                              {isAuthenticated ? 'Buy Now' : 'Sign in to Buy'}
                            </button>
                          )}
                        </div>
                      );
                    })}
                  </div>

                  {/* Pagination */}
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
        </div>
      </div>
    </>
  );
};

export default Marketplace;
