import React, { useState, useEffect } from 'react';
import { useNavigate, useSearchParams, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import api from '../services/api';
import MarketplaceHeader from '../components/MarketplaceHeader';
import RatingDialog from '../components/RatingDialog';
import RatingButton from '../components/RatingButton';
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
  const [anchorEl, setAnchorEl] = useState(null);
  const [selectedListingId, setSelectedListingId] = useState(null);
  const [ratingDialog, setRatingDialog] = useState({
    open: false,
    toUserId: null,
    toUserName: null,
    listingId: null,
    listingTitle: null
  });

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



  const handleFinalizeBid = async (listingIdParam) => {
    if (!window.confirm('Are you sure you want to finalize this bid? This will close the listing and transfer funds.')) {
      return;
    }
    
    setError('');
    setSuccess('');
    setFinalizingBid(true);
    
    try {
      const response = await api.post(`/api/bids/listing/${listingIdParam}/finalize`);
      setSuccess('Bid finalized successfully! You can now rate the buyer.');
      
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

  const handleRateUser = async (toUserId, toUserName, listingId, listingTitle) => {
    setRatingDialog({
      open: true,
      toUserId,
      toUserName: toUserName || 'User',
      listingId,
      listingTitle
    });
  };

  const handleRatingSuccess = () => {
    // Refresh data after rating
    fetchBiddingData();
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
              <Paper elevation={2} sx={{ p: 3, backgroundColor: 'var(--tbs-bg-card)', color: 'var(--tbs-text)' }}>
                <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
                  <Typography variant="h5" sx={{ color: 'var(--tbs-text)' }}>My Bids</Typography>
                </Box>

                {myBids.length === 0 ? (
                  <Box textAlign="center" py={6}>
                    <Typography variant="h6" sx={{ color: 'var(--tbs-text-muted)' }} gutterBottom>
                      You haven't placed any bids yet.
                    </Typography>
                    <Typography variant="body2" sx={{ color: 'var(--tbs-text-muted)', mb: 2 }}>
                      Browse active listings to start bidding!
                    </Typography>
                    <Button 
                      variant="contained" 
                      component={Link}
                      to="/bids"
                      onClick={() => setActiveTab('active-listings')}
                      sx={{ 
                        backgroundColor: 'var(--tbs-primary)',
                        color: 'var(--tbs-text)',
                        '&:hover': {
                          backgroundColor: 'var(--tbs-primary-dark)'
                        }
                      }}
                    >
                      Browse Active Listings
                    </Button>
                  </Box>
                ) : (
                  <Stack spacing={2}>
                    {myBids.map(bid => (
                      <Card
                        key={bid.bidId}
                        sx={{
                          display: 'flex',
                          cursor: 'pointer',
                          backgroundColor: 'var(--tbs-bg-card)',
                          color: 'var(--tbs-text)',
                          '&:hover': {
                            boxShadow: 4,
                          },
                          borderLeft: `4px solid ${bid.isWinning ? 'var(--tbs-success)' : 'var(--tbs-red)'}`,
                          overflow: 'hidden',
                          maxWidth: '100%'
                        }}
                        onClick={() => navigate(`/listing/${bid.listingId}`)}
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
                          image={bid.listingImageUrl || 'https://via.placeholder.com/120x120?text=No+Image'}
                          alt={bid.listingTitle || 'Listing image'}
                          onError={(e) => {
                            e.target.src = 'https://via.placeholder.com/120x120?text=No+Image';
                            e.target.onerror = null;
                          }}
                        />
                        
                        {/* Content */}
                        <Box sx={{ display: 'flex', flexDirection: 'column', flex: 1, minWidth: 0, overflow: 'hidden' }}>
                          <CardContent sx={{ flex: 1, pb: 1, pt: 1.5, overflow: 'hidden', maxWidth: '100%' }}>
                            <Box display="flex" justifyContent="space-between" alignItems="flex-start" mb={0.5} sx={{ gap: 1 }}>
                              <Box flex={1} minWidth={0} sx={{ overflow: 'hidden', maxWidth: '100%' }}>
                                <Typography 
                                  variant="subtitle1" 
                                  fontWeight="bold" 
                                  sx={{ 
                                    mb: 0.5,
                                    color: 'var(--tbs-text)',
                                    overflow: 'hidden',
                                    textOverflow: 'ellipsis',
                                    display: '-webkit-box',
                                    WebkitLineClamp: 2,
                                    WebkitBoxOrient: 'vertical',
                                    wordBreak: 'break-word'
                                  }}
                                >
                                  {bid.listingTitle || 'Untitled Listing'}
                                </Typography>
                                <Stack direction="row" spacing={1} alignItems="center" mb={0.5}>
                                  <Chip
                                    label={bid.isWinning ? 'WINNING' : 'OUTBID'}
                                    size="small"
                                    sx={{
                                      backgroundColor: bid.isWinning ? 'var(--tbs-success)' : 'var(--tbs-red)',
                                      color: 'var(--tbs-text)'
                                    }}
                                  />
                                </Stack>
                                <Stack direction="row" spacing={2} alignItems="center" flexWrap="wrap" sx={{ mt: 1 }}>
                                  <Typography 
                                    variant="body2" 
                                    fontWeight="bold" 
                                    sx={{ color: 'var(--tbs-gold)' }}
                                  >
                                    Bid Amount: ₹{parseFloat(bid.bidAmount).toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                                  </Typography>
                                  <Typography 
                                    variant="caption" 
                                    sx={{ color: 'var(--tbs-text-muted)', wordBreak: 'break-word' }}
                                  >
                                    Placed: {new Date(bid.bidTime).toLocaleString()}
                                  </Typography>
                                </Stack>
                              </Box>
                            </Box>
                          </CardContent>
                          <CardActions sx={{ px: 2, pb: 1.5, flexDirection: 'column', alignItems: 'stretch', gap: 1 }}>
                            <Button
                              variant="contained"
                              component={Link}
                              to={`/listing/${bid.listingId}`}
                              onClick={(e) => e.stopPropagation()}
                              sx={{
                                backgroundColor: 'var(--tbs-gold)',
                                color: '#11152A',
                                fontWeight: 'bold',
                                '&:hover': {
                                  backgroundColor: 'var(--tbs-gold-light)',
                                }
                              }}
                            >
                              View Listing
                            </Button>
                            {/* Rate Seller button for winning bids (only show if bid is winning) */}
                            {bid.isWinning && (
                              <RatingButton
                                toUserId={null} // Will be fetched from listing by RatingButton
                                toUserName={null} // Will be fetched from listing by RatingButton
                                listingId={bid.listingId}
                                listingTitle={bid.listingTitle}
                                onRated={handleRateUser}
                              />
                            )}
                          </CardActions>
                        </Box>
                      </Card>
                    ))}
                  </Stack>
                )}
              </Paper>
            </div>
          )}

          {activeTab === 'active-listings' && (
            <div className="active-listings-section">
              <Paper elevation={2} sx={{ p: 3, backgroundColor: 'var(--tbs-bg-card)', color: 'var(--tbs-text)' }}>
                <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
                  <Typography variant="h5" sx={{ color: 'var(--tbs-text)' }}>Active Biddable Listings</Typography>
                </Box>

                {activeListings.length === 0 ? (
                  <Box textAlign="center" py={6}>
                    <Typography variant="h6" sx={{ color: 'var(--tbs-text-muted)' }} gutterBottom>
                      No active biddable listings available.
                    </Typography>
                  </Box>
                ) : (
                  <>
                    {/* Listings */}
                    {activeListings.length === 0 ? (
                        <Box textAlign="center" py={4}>
                          <Typography variant="body1" sx={{ color: 'var(--tbs-text-muted)' }}>
                            No active biddable listings available.
                          </Typography>
                        </Box>
                    ) : (
                      <Stack spacing={2}>
                        {activeListings.map(listing => {
                          const timeRemaining = getTimeRemaining(listing.bidEndTime);
                          const ended = isBidEnded(listing.bidEndTime);
                          
                          return (
                            <Card
                              key={listing.listingId}
                              sx={{
                                display: 'flex',
                                cursor: 'pointer',
                                backgroundColor: 'var(--tbs-bg-card)',
                                color: 'var(--tbs-text)',
                                '&:hover': {
                                  boxShadow: 4,
                                },
                                borderLeft: `4px solid ${ended ? 'var(--tbs-warning)' : 'var(--tbs-primary)'}`,
                                overflow: 'hidden',
                                maxWidth: '100%'
                              }}
                              onClick={() => navigate(`/listing/${listing.listingId}`)}
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
                              
                                <Box sx={{ display: 'flex', flexDirection: 'column', flex: 1, minWidth: 0, overflow: 'hidden' }}>
                                  <CardContent sx={{ flex: 1, pb: 1, pt: 1.5, overflow: 'hidden', maxWidth: '100%' }}>
                                    <Box display="flex" justifyContent="space-between" alignItems="flex-start" mb={0.5} sx={{ gap: 1 }}>
                                      <Box flex={1} minWidth={0} sx={{ overflow: 'hidden', maxWidth: '100%' }}>
                                        <Typography 
                                          variant="subtitle1" 
                                          fontWeight="bold" 
                                          sx={{ 
                                            mb: 0.5,
                                            color: 'var(--tbs-text)',
                                            overflow: 'hidden',
                                            textOverflow: 'ellipsis',
                                            display: '-webkit-box',
                                            WebkitLineClamp: 2,
                                            WebkitBoxOrient: 'vertical',
                                            wordBreak: 'break-word'
                                          }}
                                        >
                                          {listing.title || 'Untitled Listing'}
                                        </Typography>
                                        <Stack direction="row" spacing={1} alignItems="center" mb={0.5}>
                                          {listing.category && (
                                            <Chip 
                                              label={listing.category} 
                                              size="small" 
                                              variant="outlined"
                                              sx={{ 
                                                borderColor: 'var(--tbs-border)',
                                                color: 'var(--tbs-text)'
                                              }}
                                            />
                                          )}
                                          <Chip
                                            label={ended ? 'ENDED' : 'ACTIVE'}
                                            size="small"
                                            sx={{
                                              backgroundColor: ended ? 'var(--tbs-warning)' : 'var(--tbs-primary)',
                                              color: 'var(--tbs-text)'
                                            }}
                                          />
                                          <Chip
                                            label="BIDDABLE"
                                            size="small"
                                            sx={{
                                              backgroundColor: 'var(--tbs-gold)',
                                              color: 'var(--tbs-text)'
                                            }}
                                          />
                                        </Stack>
                                        <Typography
                                          variant="body2"
                                          sx={{
                                            color: 'var(--tbs-text-muted)',
                                            overflow: 'hidden',
                                            textOverflow: 'ellipsis',
                                            display: '-webkit-box',
                                            WebkitLineClamp: 2,
                                            WebkitBoxOrient: 'vertical',
                                            mb: 0.5,
                                            wordBreak: 'break-word'
                                          }}
                                        >
                                          {listing.description || 'No description'}
                                        </Typography>
                                        <Stack direction="row" spacing={2} alignItems="center" flexWrap="wrap" sx={{ mt: 1 }}>
                                          <Typography 
                                            variant="body2" 
                                            fontWeight="bold" 
                                            sx={{ color: 'var(--tbs-gold)' }}
                                          >
                                            Starting: ₹{listing.startingPrice 
                                              ? parseFloat(listing.startingPrice).toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) 
                                              : 'N/A'}
                                          </Typography>
                                          {listing.highestBid && (
                                            <Typography 
                                              variant="body2" 
                                              fontWeight="bold" 
                                              sx={{ color: 'var(--tbs-success)' }}
                                            >
                                              Highest: ₹{parseFloat(listing.highestBid).toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                                            </Typography>
                                          )}
                                          <Box display="flex" alignItems="center" gap={0.5}>
                                            <GavelIcon sx={{ fontSize: 14, color: 'var(--tbs-text-muted)' }} />
                                            <Typography variant="caption" sx={{ color: 'var(--tbs-text-muted)' }}>
                                              {listing.bidCount || 0} bid{listing.bidCount !== 1 ? 's' : ''}
                                            </Typography>
                                          </Box>
                                          {listing.bidEndTime && (
                                            <Typography 
                                              variant="caption" 
                                              sx={{ 
                                                color: ended ? 'var(--tbs-red)' : 'var(--tbs-text-muted)',
                                                wordBreak: 'break-word'
                                              }}
                                            >
                                              {ended ? 'Ended' : `Ends: ${new Date(listing.bidEndTime).toLocaleString()}`}
                                              {timeRemaining && !ended && ` (${timeRemaining} remaining)`}
                                            </Typography>
                                          )}
                                        </Stack>
                                      </Box>
                                    </Box>
                                  </CardContent>
                                  <CardActions sx={{ px: 2, pb: 1.5 }}>
                                    <Button
                                      variant="contained"
                                      onClick={(e) => {
                                        e.stopPropagation();
                                        handleListingSelect(listing);
                                      }}
                                      disabled={ended}
                                      sx={{
                                        backgroundColor: ended ? 'var(--tbs-border)' : 'var(--tbs-info)',
                                        color: 'var(--tbs-text)',
                                        '&:hover': {
                                          backgroundColor: ended ? 'var(--tbs-border)' : 'var(--tbs-info-dark)'
                                        },
                                        '&:disabled': {
                                          backgroundColor: 'var(--tbs-border)',
                                          color: 'var(--tbs-text-muted)'
                                        }
                                      }}
                                    >
                                      {ended ? 'Bidding Ended' : 'Place Bid'}
                                    </Button>
                                  </CardActions>
                                </Box>
                              </Card>
                            );
                          })}
                        </Stack>
                    )}
                  </>
                )}
              </Paper>
            </div>
          )}

          {activeTab === 'my-listings' && (
            <div className="my-listings-section">
              <Paper elevation={2} sx={{ p: 3, backgroundColor: 'var(--tbs-bg-card)', color: 'var(--tbs-text)' }}>
                <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
                  <Typography variant="h5" sx={{ color: 'var(--tbs-text)' }}>My Biddable Listings</Typography>
                </Box>

                {myListings.length === 0 ? (
                  <Box textAlign="center" py={6}>
                    <Typography variant="h6" sx={{ color: 'var(--tbs-text-muted)' }} gutterBottom>
                      You haven't created any biddable listings yet.
                    </Typography>
                    <Button 
                      variant="contained" 
                      component={Link}
                      to="/post-listing"
                      sx={{ 
                        mt: 2,
                        backgroundColor: 'var(--tbs-primary)',
                        color: 'var(--tbs-text)',
                        '&:hover': {
                          backgroundColor: 'var(--tbs-primary-dark)'
                        }
                      }}
                    >
                      Create a Biddable Listing
                    </Button>
                  </Box>
                ) : (
                  <>
                    {/* Listings Grid */}
                    {myListings.length === 0 ? (
                      <Box textAlign="center" py={4}>
                        <Typography variant="body1" sx={{ color: 'var(--tbs-text-muted)' }}>
                          No listings available.
                        </Typography>
                      </Box>
                    ) : (
                      <Stack spacing={2}>
                        {myListings.map((listing) => {
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
                                backgroundColor: 'var(--tbs-bg-card)',
                                color: 'var(--tbs-text)',
                                '&:hover': {
                                  boxShadow: 4,
                                },
                                borderLeft: `4px solid ${ended ? 'var(--tbs-warning)' : 'var(--tbs-primary)'}`,
                                overflow: 'hidden',
                                maxWidth: '100%'
                              }}
                              onClick={() => navigate(`/listing/${listing.listingId}`)}
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
                              <Box sx={{ display: 'flex', flexDirection: 'column', flex: 1, minWidth: 0, overflow: 'hidden' }}>
                                <CardContent sx={{ flex: 1, pb: isSelected ? 1 : 1, pt: 1.5, overflow: 'hidden', maxWidth: '100%' }}>
                                  <Box display="flex" justifyContent="space-between" alignItems="flex-start" mb={0.5} sx={{ gap: 1 }}>
                                    <Box flex={1} minWidth={0} sx={{ overflow: 'hidden', maxWidth: '100%' }}>
                                      <Typography 
                                        variant="subtitle1" 
                                        fontWeight="bold" 
                                        sx={{ 
                                          mb: 0.5,
                                          color: 'var(--tbs-text)',
                                          overflow: 'hidden',
                                          textOverflow: 'ellipsis',
                                          display: '-webkit-box',
                                          WebkitLineClamp: 2,
                                          WebkitBoxOrient: 'vertical',
                                          wordBreak: 'break-word'
                                        }}
                                      >
                                        {listing.title || 'Untitled Listing'}
                                      </Typography>
                                      <Stack direction="row" spacing={1} alignItems="center" mb={0.5}>
                                        {listing.category && (
                                          <Chip 
                                            label={listing.category} 
                                            size="small" 
                                            variant="outlined"
                                            sx={{ 
                                              borderColor: 'var(--tbs-border)',
                                              color: 'var(--tbs-text)'
                                            }}
                                          />
                                        )}
                                        <Chip
                                          label={isActive ? (ended ? 'ENDED' : 'ACTIVE') : 'INACTIVE'}
                                          size="small"
                                          sx={{
                                            backgroundColor: isActive ? (ended ? 'var(--tbs-warning)' : 'var(--tbs-primary)') : 'var(--tbs-red)',
                                            color: 'var(--tbs-text)'
                                          }}
                                        />
                                        {listing.isBiddable && (
                                          <Chip
                                            label="BIDDABLE"
                                            size="small"
                                            sx={{
                                              backgroundColor: 'var(--tbs-gold)',
                                              color: 'var(--tbs-text)'
                                            }}
                                          />
                                        )}
                                      </Stack>
                                      <Typography
                                        variant="body2"
                                        sx={{
                                          color: 'var(--tbs-text-muted)',
                                          overflow: 'hidden',
                                          textOverflow: 'ellipsis',
                                          display: '-webkit-box',
                                          WebkitLineClamp: 2,
                                          WebkitBoxOrient: 'vertical',
                                          mb: 0.5,
                                          wordBreak: 'break-word'
                                        }}
                                      >
                                        {listing.description || 'No description'}
                                      </Typography>
                                      <Stack direction="row" spacing={2} alignItems="center" flexWrap="wrap" sx={{ mt: 1 }}>
                                        <Typography 
                                          variant="body2" 
                                          fontWeight="bold" 
                                          sx={{ color: 'var(--tbs-gold)' }}
                                        >
                                          Starting: ₹{listing.startingPrice 
                                            ? parseFloat(listing.startingPrice).toLocaleString('en-IN') 
                                            : 'N/A'}
                                        </Typography>
                                        {listing.highestBid && (
                                          <Typography 
                                            variant="body2" 
                                            fontWeight="bold" 
                                            sx={{ color: 'var(--tbs-success)' }}
                                          >
                                            Highest: ₹{parseFloat(listing.highestBid).toLocaleString('en-IN')}
                                          </Typography>
                                        )}
                                        <Box display="flex" alignItems="center" gap={0.5}>
                                          <GavelIcon sx={{ fontSize: 14, color: 'var(--tbs-text-muted)' }} />
                                          <Typography variant="caption" sx={{ color: 'var(--tbs-text-muted)' }}>
                                            {listing.bidCount || 0} bid{listing.bidCount !== 1 ? 's' : ''}
                                          </Typography>
                                        </Box>
                                        {listing.bidEndTime && (
                                          <Typography 
                                            variant="caption" 
                                            sx={{ 
                                              color: ended ? 'var(--tbs-red)' : 'var(--tbs-text-muted)',
                                              wordBreak: 'break-word'
                                            }}
                                          >
                                            {ended ? 'Ended' : `Ends: ${new Date(listing.bidEndTime).toLocaleString()}`}
                                            {timeRemaining && !ended && ` (${timeRemaining} remaining)`}
                                          </Typography>
                                        )}
                                        <Typography 
                                          variant="caption" 
                                          sx={{ color: 'var(--tbs-text-muted)', wordBreak: 'break-word' }}
                                        >
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
                                      <Typography variant="h6" gutterBottom sx={{ mt: 1, color: 'var(--tbs-text)' }}>
                                        Bids on "{listing.title}"
                                      </Typography>
                                      {bids.length === 0 ? (
                                        <Typography variant="body2" sx={{ mb: 2, color: 'var(--tbs-text-muted)' }}>
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
                                                    bgcolor: bid.isWinning ? 'rgba(40, 167, 69, 0.2)' : 'var(--tbs-bg-elevated)',
                                                    borderRadius: 1,
                                                    gap: 1,
                                                    flexWrap: 'wrap'
                                                  }}
                                                >
                                                  <Typography variant="body2" sx={{ color: 'var(--tbs-text)' }}>
                                                    {bid.userName || 'Unknown'}
                                                  </Typography>
                                                  <Typography 
                                                    variant="body2" 
                                                    fontWeight="bold" 
                                                    sx={{ color: 'var(--tbs-gold)' }}
                                                  >
                                                    ₹{parseFloat(bid.bidAmount).toFixed(2)}
                                                  </Typography>
                                                  <Typography variant="caption" sx={{ color: 'var(--tbs-text-muted)' }}>
                                                    {new Date(bid.bidTime).toLocaleString()}
                                                  </Typography>
                                                  <Chip
                                                    label={bid.isWinning ? 'Winning' : index === 0 ? 'Highest' : 'Outbid'}
                                                    size="small"
                                                    sx={{
                                                      backgroundColor: bid.isWinning ? 'var(--tbs-success)' : 'var(--tbs-bg-elevated)',
                                                      color: 'var(--tbs-text)',
                                                      border: !bid.isWinning ? '1px solid var(--tbs-border)' : 'none'
                                                    }}
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
                                              sx={{ mb: 1 }}
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
                                          {/* Rate Buyer button for finalized listings (inactive with winning bid) */}
                                          {!listing.isActive && 
                                           bids.length > 0 && 
                                           bids[0]?.isWinning && (
                                            <Box sx={{ mt: 1 }}>
                                              <RatingButton
                                                toUserId={bids[0]?.userId}
                                                toUserName={bids[0]?.userName}
                                                listingId={listing.listingId}
                                                listingTitle={listing.title}
                                                onRated={handleRateUser}
                                              />
                                            </Box>
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

      {/* Rating Dialog */}
      <RatingDialog
        open={ratingDialog.open}
        onClose={() => setRatingDialog({ ...ratingDialog, open: false })}
        onSuccess={handleRatingSuccess}
        toUserId={ratingDialog.toUserId}
        toUserName={ratingDialog.toUserName}
        listingId={ratingDialog.listingId}
        listingTitle={ratingDialog.listingTitle}
      />
    </>
  );
};

export default BiddingCenter;