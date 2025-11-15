import React, { useState, useEffect } from 'react';
import { useNavigate, useSearchParams, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import api from '../services/api';
import MarketplaceHeader from '../components/MarketplaceHeader';
import {
  Box,
  Card,
  CardContent,
  CardMedia,
  CardActions,
  Button,
  TextField,
  Chip,
  Typography,
  IconButton,
  Menu,
  MenuItem,
  InputAdornment,
  ToggleButton,
  ToggleButtonGroup,
  Stack,
  Divider,
  Container,
  Paper,
  CircularProgress,
  Alert
} from '@mui/material';
import {
  Search as SearchIcon,
  MoreVert as MoreVertIcon,
  Visibility as VisibilityIcon,
  Gavel as GavelIcon
} from '@mui/icons-material';
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
  const [searchQuery, setSearchQuery] = useState('');
  const [anchorEl, setAnchorEl] = useState(null);
  const [selectedListingId, setSelectedListingId] = useState(null);

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
        api.get('/api/listings?biddableOnly=true&page=0&size=100').catch(() => ({ data: { content: [] } })),
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

  const handleMenuOpen = (event, listingId) => {
    event.preventDefault();
    event.stopPropagation();
    setAnchorEl(event.currentTarget);
    setSelectedListingId(listingId);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
    setSelectedListingId(null);
  };

  const getImageUrl = (imageUrl) => {
    if (!imageUrl) return 'https://via.placeholder.com/120x120?text=No+Image';
    if (imageUrl.startsWith('http')) return imageUrl;
    return `${process.env.REACT_APP_API_URL || 'http://localhost:8080'}${imageUrl}`;
  };

  const getDateRange = (listing) => {
    if (!listing.createdAt) return { fromDate: 'N/A', toDate: null };
    const fromDate = new Date(listing.createdAt).toLocaleDateString('en-US', { 
      month: 'short', 
      day: 'numeric',
      year: 'numeric'
    });
    const toDate = listing.updatedAt && listing.updatedAt !== listing.createdAt
      ? new Date(listing.updatedAt).toLocaleDateString('en-US', { 
          month: 'short', 
          day: 'numeric',
          year: 'numeric'
        })
      : null;
    return { fromDate, toDate };
  };

  const filteredMyListings = myListings.filter(listing => {
    const matchesSearch = !searchQuery || 
      (listing.title && listing.title.toLowerCase().includes(searchQuery.toLowerCase())) ||
      (listing.description && listing.description.toLowerCase().includes(searchQuery.toLowerCase()));
    return matchesSearch;
  });

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
        <MarketplaceHeader showSearch={false} />
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
      <MarketplaceHeader showSearch={false} />
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
              <Paper elevation={2} sx={{ p: 3 }}>
                <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
                  <Typography variant="h5">My Biddable Listings</Typography>
                </Box>

                {myListings.length === 0 ? (
                  <Box textAlign="center" py={6}>
                    <Typography variant="h6" color="text.secondary" gutterBottom>
                      You haven't created any biddable listings yet.
                    </Typography>
                    <Button 
                      variant="contained" 
                      color="primary" 
                      component={Link}
                      to="/post-listing"
                      sx={{ mt: 2 }}
                    >
                      Create a Biddable Listing
                    </Button>
                  </Box>
                ) : (
                  <>
                    {/* Search */}
                    <Stack spacing={2} mb={3}>
                      <TextField
                        fullWidth
                        placeholder="Search by Listing Title"
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        InputProps={{
                          startAdornment: (
                            <InputAdornment position="start">
                              <SearchIcon />
                            </InputAdornment>
                          ),
                        }}
                        size="small"
                      />
                    </Stack>

                    {/* Listings Grid */}
                    {filteredMyListings.length === 0 ? (
                      <Box textAlign="center" py={4}>
                        <Typography variant="body1" color="text.secondary">
                          No listings match your search criteria.
                        </Typography>
                      </Box>
                    ) : (
                      <Stack spacing={2}>
                        {filteredMyListings.map((listing) => {
                          const { fromDate, toDate } = getDateRange(listing);
                          const isActive = listing.isActive;
                          const ended = isBidEnded(listing.bidEndTime);
                          const timeRemaining = listing.bidEndTime ? getTimeRemaining(listing.bidEndTime) : null;
                          const isSelected = selectedMyListing?.listingId === listing.listingId;
                          
                          return (
                            <Card
                              key={listing.listingId}
                              sx={{
                                display: 'flex',
                                cursor: 'pointer',
                                '&:hover': {
                                  boxShadow: 4,
                                },
                                borderLeft: `4px solid ${isActive ? (ended ? '#ff9800' : '#1976d2') : '#d32f2f'}`,
                                border: isSelected ? '2px solid #1976d2' : undefined,
                              }}
                              onClick={() => handleMyListingSelect(listing)}
                            >
                              {/* Image */}
                              <CardMedia
                                component="img"
                                sx={{
                                  width: 120,
                                  height: 120,
                                  objectFit: 'cover',
                                  flexShrink: 0,
                                }}
                                image={listing.imageUrls && listing.imageUrls.length > 0 
                                  ? getImageUrl(listing.imageUrls[0])
                                  : 'https://via.placeholder.com/120x120?text=No+Image'
                                }
                                alt={listing.title || 'Listing image'}
                                onError={(e) => {
                                  e.target.src = 'https://via.placeholder.com/120x120?text=No+Image';
                                  e.target.onerror = null;
                                }}
                              />
                              
                              {/* Content */}
                              <Box sx={{ display: 'flex', flexDirection: 'column', flex: 1, minWidth: 0 }}>
                                <CardContent sx={{ flex: 1, pb: isSelected ? 1 : 1, pt: 1.5 }}>
                                  <Box display="flex" justifyContent="space-between" alignItems="flex-start" mb={0.5}>
                                    <Box flex={1} minWidth={0}>
                                      <Typography 
                                        variant="subtitle1" 
                                        fontWeight="bold" 
                                        noWrap
                                        sx={{ mb: 0.5 }}
                                      >
                                        {listing.title || 'Untitled Listing'}
                                      </Typography>
                                      <Stack direction="row" spacing={1} alignItems="center" mb={0.5}>
                                        {listing.category && (
                                          <Chip 
                                            label={listing.category} 
                                            size="small" 
                                            variant="outlined"
                                          />
                                        )}
                                        <Chip
                                          label={isActive ? (ended ? 'ENDED' : 'ACTIVE') : 'INACTIVE'}
                                          size="small"
                                          color={isActive ? (ended ? 'warning' : 'primary') : 'error'}
                                        />
                                        {listing.isBiddable && (
                                          <Chip
                                            label="BIDDABLE"
                                            size="small"
                                            color="secondary"
                                          />
                                        )}
                                      </Stack>
                                      <Typography
                                        variant="body2"
                                        color="text.secondary"
                                        sx={{
                                          overflow: 'hidden',
                                          textOverflow: 'ellipsis',
                                          display: '-webkit-box',
                                          WebkitLineClamp: 1,
                                          WebkitBoxOrient: 'vertical',
                                          mb: 0.5,
                                        }}
                                      >
                                        {listing.description || 'No description'}
                                      </Typography>
                                      <Stack direction="row" spacing={2} alignItems="center" flexWrap="wrap">
                                        <Typography variant="body2" fontWeight="bold" color="primary">
                                          Starting: ₹{listing.startingPrice 
                                            ? parseFloat(listing.startingPrice).toLocaleString('en-IN') 
                                            : 'N/A'}
                                        </Typography>
                                        {listing.highestBid && (
                                          <Typography variant="body2" fontWeight="bold" color="success.main">
                                            Highest: ₹{parseFloat(listing.highestBid).toLocaleString('en-IN')}
                                          </Typography>
                                        )}
                                        <Box display="flex" alignItems="center" gap={0.5}>
                                          <GavelIcon sx={{ fontSize: 14 }} />
                                          <Typography variant="caption" color="text.secondary">
                                            {listing.bidCount || 0} bid{listing.bidCount !== 1 ? 's' : ''}
                                          </Typography>
                                        </Box>
                                        {listing.bidEndTime && (
                                          <Typography variant="caption" color={ended ? 'error.main' : 'text.secondary'}>
                                            {ended ? 'Ended' : `Ends: ${new Date(listing.bidEndTime).toLocaleString()}`}
                                            {timeRemaining && !ended && ` (${timeRemaining} remaining)`}
                                          </Typography>
                                        )}
                                        <Typography variant="caption" color="text.secondary">
                                          FROM: {fromDate} {toDate && `TO: ${toDate}`}
                                        </Typography>
                                      </Stack>
                                    </Box>
                                    
                                    {/* Menu Icon */}
                                    <IconButton
                                      size="small"
                                      onClick={(e) => handleMenuOpen(e, listing.listingId)}
                                      sx={{ ml: 1 }}
                                    >
                                      <MoreVertIcon />
                                    </IconButton>
                                  </Box>
                                </CardContent>
                                
                                {isSelected && (
                                  <>
                                    <Divider />
                                    {/* Bids Detail Section */}
                                    <CardActions sx={{ px: 2, py: 1, flexDirection: 'column', alignItems: 'stretch' }}>
                                      <Typography variant="h6" gutterBottom sx={{ mt: 1 }}>
                                        Bids on "{listing.title}"
                                      </Typography>
                                      {bids.length === 0 ? (
                                        <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                                          No bids yet on this listing.
                                        </Typography>
                                      ) : (
                                        <>
                                          <Box sx={{ mb: 2 }}>
                                            <Stack spacing={1}>
                                              {bids.map((bid, index) => (
                                                <Box 
                                                  key={bid.bidId}
                                                  sx={{
                                                    display: 'flex',
                                                    justifyContent: 'space-between',
                                                    alignItems: 'center',
                                                    p: 1,
                                                    bgcolor: bid.isWinning ? 'success.light' : 'grey.100',
                                                    borderRadius: 1
                                                  }}
                                                >
                                                  <Typography variant="body2">
                                                    {bid.userName || 'Unknown'}
                                                  </Typography>
                                                  <Typography variant="body2" fontWeight="bold" color="primary">
                                                    ₹{parseFloat(bid.bidAmount).toFixed(2)}
                                                  </Typography>
                                                  <Typography variant="caption" color="text.secondary">
                                                    {new Date(bid.bidTime).toLocaleString()}
                                                  </Typography>
                                                  <Chip
                                                    label={bid.isWinning ? 'Winning' : index === 0 ? 'Highest' : 'Outbid'}
                                                    size="small"
                                                    color={bid.isWinning ? 'success' : 'default'}
                                                  />
                                                </Box>
                                              ))}
                                            </Stack>
                                          </Box>
                                          {listing.isActive && 
                                           bids.length > 0 && 
                                           isBidEnded(listing.bidEndTime) && (
                                            <Button
                                              variant="contained"
                                              color="success"
                                              onClick={(e) => {
                                                e.preventDefault();
                                                e.stopPropagation();
                                                handleFinalizeBid(listing.listingId);
                                              }}
                                              disabled={finalizingBid}
                                              fullWidth
                                            >
                                              {finalizingBid ? 'Finalizing...' : 'Finalize Winning Bid'}
                                            </Button>
                                          )}
                                          {listing.isActive && 
                                           !isBidEnded(listing.bidEndTime) && (
                                            <Alert severity="info" sx={{ mb: 1 }}>
                                              Bidding is still active. You can finalize after the bidding ends.
                                            </Alert>
                                          )}
                                        </>
                                      )}
                                    </CardActions>
                                  </>
                                )}
                              </Box>
                            </Card>
                          );
                        })}
                      </Stack>
                    )}
                  </>
                )}
              </Paper>

              {/* Menu */}
              <Menu
                anchorEl={anchorEl}
                open={Boolean(anchorEl)}
                onClose={handleMenuClose}
              >
                <MenuItem
                  onClick={() => {
                    if (selectedListingId) {
                      navigate(`/listing/${selectedListingId}`);
                    }
                    handleMenuClose();
                  }}
                >
                  View Details
                </MenuItem>
              </Menu>
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