import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { Link, useNavigate } from 'react-router-dom';
import api from '../services/api';
import Navigation from '../components/Navigation';
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
  Alert,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Radio,
  RadioGroup,
  FormControl,
  FormLabel
} from '@mui/material';
import {
  Search as SearchIcon,
  MoreVert as MoreVertIcon,
  Sell as SellIcon,
  Delete as DeleteIcon,
  Visibility as VisibilityIcon,
  Favorite as FavoriteIcon,
  CheckCircle as CheckCircleIcon
} from '@mui/icons-material';
// CSS is now handled by MUI components - keeping import for any custom overrides if needed
// import './MyProfile.css';

const MyProfile = () => {
  const { user, loading: authLoading } = useAuth();
  const [profile, setProfile] = useState(null);
  const [listings, setListings] = useState([]);
  const [filteredListings, setFilteredListings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchQuery, setSearchQuery] = useState('');
  const [activeFilter, setActiveFilter] = useState('all');
  const [anchorEl, setAnchorEl] = useState(null);
  const [selectedListingId, setSelectedListingId] = useState(null);
  const [showSellFasterModal, setShowSellFasterModal] = useState(false);
  const [selectedListingForFeature, setSelectedListingForFeature] = useState(null);
  const [featuredPackages, setFeaturedPackages] = useState([]);
  const [selectedPackage, setSelectedPackage] = useState(null);
  const [featuringListing, setFeaturingListing] = useState(false);
  const [walletBalance, setWalletBalance] = useState(null);
  const navigate = useNavigate();

  const fetchProfileData = React.useCallback(async () => {
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
      setWalletBalance(profileRes.data.walletBalance);
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
  }, [user?.userId]);

  const fetchFeaturedPackages = async () => {
    try {
      const response = await api.get('/api/featured/packages');
      setFeaturedPackages(response.data || []);
    } catch (err) {
      console.error('Failed to fetch featured packages:', err);
      alert('Failed to load featured packages. Please try again.');
    }
  };

  const handleSellFasterClick = async (listingId, e) => {
    e.preventDefault();
    e.stopPropagation();
    setSelectedListingForFeature(listingId);
    setShowSellFasterModal(true);
    await fetchFeaturedPackages();
  };

  const handleFeatureListing = async () => {
    if (!selectedPackage || !selectedListingForFeature) {
      alert('Please select a package');
      return;
    }

    if (!walletBalance || parseFloat(walletBalance) < parseFloat(selectedPackage.price)) {
      alert('Insufficient wallet balance. Please add funds to your wallet.');
      return;
    }

    if (!window.confirm(`Are you sure you want to feature this listing for ₹${selectedPackage.price}?`)) {
      return;
    }

    try {
      setFeaturingListing(true);
      await api.post('/api/featured/feature', {
        listingId: selectedListingForFeature,
        packageId: selectedPackage.packageId
      });
      
      alert('Listing featured successfully!');
      setShowSellFasterModal(false);
      setSelectedPackage(null);
      setSelectedListingForFeature(null);
      // Refresh profile data to update wallet balance and listing status
      fetchProfileData();
    } catch (err) {
      console.error('Failed to feature listing:', err);
      alert(err.response?.data?.message || err.response?.data?.error || 'Failed to feature listing. Please try again.');
    } finally {
      setFeaturingListing(false);
    }
  };

  useEffect(() => {
    if (!authLoading && user?.userId) {
      fetchProfileData();
    } else if (!authLoading && !user) {
      setLoading(false);
      setError('Please log in to view your profile');
    }
  }, [authLoading, user, fetchProfileData]);

  // Filter and search listings
  useEffect(() => {
    let filtered = listings;

    // Apply status filter
    if (activeFilter === 'active') {
      filtered = filtered.filter(l => l.isActive);
    } else if (activeFilter === 'inactive') {
      filtered = filtered.filter(l => !l.isActive);
    } else if (activeFilter === 'pending') {
      filtered = filtered.filter(l => l.isActive);
    } else if (activeFilter === 'moderated') {
      filtered = filtered.filter(l => !l.isActive);
    }

    // Apply search query
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(l => 
        (l.title && l.title.toLowerCase().includes(query)) ||
        (l.description && l.description.toLowerCase().includes(query))
      );
    }

    setFilteredListings(filtered);
  }, [listings, activeFilter, searchQuery]);

  const handleDeactivateListing = async (listingId, closeMenu = false) => {
    if (window.confirm('Are you sure you want to deactivate this listing?')) {
      try {
        await api.delete(`/api/listings/${listingId}`);
        fetchProfileData();
        if (closeMenu) handleMenuClose();
      } catch (err) {
        console.error('Failed to deactivate listing:', err);
        alert(err.response?.data?.message || 'Failed to deactivate listing');
      }
    } else if (closeMenu) {
      handleMenuClose();
    }
  };

  const handleRemoveListing = async (listingId, closeMenu = false) => {
    if (window.confirm('Are you sure you want to remove this listing? This action cannot be undone.')) {
      try {
        await api.delete(`/api/listings/${listingId}`);
        fetchProfileData();
        if (closeMenu) handleMenuClose();
      } catch (err) {
        console.error('Failed to remove listing:', err);
        alert(err.response?.data?.message || 'Failed to remove listing');
      }
    } else if (closeMenu) {
      handleMenuClose();
    }
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

  const handleFilterChange = (event, newFilter) => {
    if (newFilter !== null) {
      setActiveFilter(newFilter);
    }
  };

  const getImageUrl = (imageUrl) => {
    if (!imageUrl) return null;
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    if (imageUrl.startsWith('/')) {
      const backendUrl = process.env.REACT_APP_API_URL || 'http://localhost:8080';
      return `${backendUrl}${imageUrl}`;
    }
    const backendUrl = process.env.REACT_APP_API_URL || 'http://localhost:8080';
    return `${backendUrl}/${imageUrl}`;
  };

  const formatDate = (date) => {
    if (!date) return '';
    try {
      let d;
      if (Array.isArray(date)) {
        d = new Date(date[0], date[1] || 0, date[2] || 1);
      } else {
        d = new Date(date);
      }
      if (isNaN(d.getTime())) return '';
      const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
      return `${months[d.getMonth()]} ${d.getDate()}, ${d.getFullYear().toString().slice(-2)}`;
    } catch (e) {
      console.error('Error formatting date:', e);
      return '';
    }
  };

  const getDateRange = (listing) => {
    if (!listing) return { fromDate: '', toDate: '' };
    
    const fromDate = formatDate(listing.createdAt);
    let toDate = '';
    
    if (listing.bidEndTime) {
      toDate = formatDate(listing.bidEndTime);
    } else if (listing.updatedAt) {
      const created = new Date(listing.createdAt);
      const updated = new Date(listing.updatedAt);
      if (updated.getTime() - created.getTime() > 24 * 60 * 60 * 1000) {
        toDate = formatDate(listing.updatedAt);
      }
    }
    
    return { fromDate, toDate };
  };

  if (authLoading || loading) {
    return (
      <>
        <Navigation />
        <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
          <Box display="flex" justifyContent="center" alignItems="center" minHeight="50vh">
            <CircularProgress />
          </Box>
        </Container>
      </>
    );
  }

  if (error && !profile) {
    return (
      <>
        <Navigation />
        <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
          <Alert severity="error">{error}</Alert>
        </Container>
      </>
    );
  }

  if (!profile) {
    return (
      <>
        <Navigation />
        <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
          <Alert severity="error">Unable to load profile data</Alert>
        </Container>
      </>
    );
  }

  const activeCount = listings.filter(l => l.isActive).length;
  const inactiveCount = listings.filter(l => !l.isActive).length;
  const pendingCount = 0;
  const moderatedCount = 0;

  return (
    <>
      <Navigation />
      <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
        {/* Profile Header */}
        <Paper elevation={2} sx={{ p: 3, mb: 3 }}>
          <Typography variant="h4" gutterBottom>
            My Profile
          </Typography>
          <Stack direction="row" spacing={3} flexWrap="wrap">
            <Typography variant="h6">{profile.fullName || user?.fullName || 'User'}</Typography>
            <Typography variant="body2" color="text.secondary">
              {profile.email || user?.email}
            </Typography>
            <Chip 
              label={`Trust Score: ${profile.trustScore ? profile.trustScore.toFixed(1) : 'N/A'}`} 
              color="primary" 
              variant="outlined"
            />
            <Chip 
              label={`Wallet: ₹${profile.walletBalance ? parseFloat(profile.walletBalance).toFixed(2) : '0.00'}`} 
              color="success" 
              variant="outlined"
            />
            {profile.registeredAt && (
              <Chip 
                label={`Member Since: ${new Date(profile.registeredAt).toLocaleDateString()}`} 
                variant="outlined"
              />
            )}
          </Stack>
          {profile.isSuspended && (
            <Alert severity="warning" sx={{ mt: 2 }}>
              ⚠️ Your account is currently suspended
            </Alert>
          )}
        </Paper>

        {/* My Listings Section */}
        <Paper elevation={2} sx={{ p: 3 }}>
          <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
            <Typography variant="h5">My Listings</Typography>
            <Button 
              variant="contained" 
              color="primary" 
              component={Link}
              to="/post-listing"
              startIcon={<SellIcon />}
            >
              Create New Listing
            </Button>
          </Box>

          {listings.length === 0 ? (
            <Box textAlign="center" py={6}>
              <Typography variant="h6" color="text.secondary" gutterBottom>
                You haven't created any listings yet.
              </Typography>
              <Button 
                variant="contained" 
                color="primary" 
                component={Link}
                to="/post-listing"
                sx={{ mt: 2 }}
              >
                Create Your First Listing
              </Button>
            </Box>
          ) : (
            <>
              {/* Search and Filter */}
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
                <Box>
                  <Typography variant="body2" color="text.secondary" gutterBottom>
                    Filter By:
                  </Typography>
                  <ToggleButtonGroup
                    value={activeFilter}
                    exclusive
                    onChange={handleFilterChange}
                    aria-label="listing filter"
                    size="small"
                    sx={{ flexWrap: 'wrap', gap: 1 }}
                  >
                    <ToggleButton value="all" aria-label="all">
                      View all ({listings.length})
                    </ToggleButton>
                    <ToggleButton value="active" aria-label="active">
                      Active Ads ({activeCount})
                    </ToggleButton>
                    <ToggleButton value="inactive" aria-label="inactive">
                      Inactive Ads ({inactiveCount})
                    </ToggleButton>
                    <ToggleButton value="pending" aria-label="pending">
                      Pending Ads ({pendingCount})
                    </ToggleButton>
                    <ToggleButton value="moderated" aria-label="moderated">
                      Moderated Ads ({moderatedCount})
                    </ToggleButton>
                  </ToggleButtonGroup>
                </Box>
              </Stack>

              {/* Listings Grid */}
              {filteredListings.length === 0 ? (
                <Box textAlign="center" py={4}>
                  <Typography variant="body1" color="text.secondary">
                    No listings match your search criteria.
                  </Typography>
                </Box>
              ) : (
                <Stack spacing={2}>
                  {filteredListings.map((listing) => {
                    const { fromDate, toDate } = getDateRange(listing);
                    const isActive = listing.isActive;
                    
                    return (
                      <Card
                        key={listing.listingId}
                        sx={{
                          display: 'flex',
                          cursor: 'pointer',
                          '&:hover': {
                            boxShadow: 4,
                          },
                          borderLeft: `4px solid ${isActive ? '#1976d2' : '#d32f2f'}`,
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
                        <Box sx={{ display: 'flex', flexDirection: 'column', flex: 1, minWidth: 0 }}>
                          <CardContent sx={{ flex: 1, pb: 1, pt: 1.5 }}>
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
                                    label={isActive ? 'ACTIVE' : 'INACTIVE'}
                                    size="small"
                                    color={isActive ? 'primary' : 'error'}
                                  />
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
                                    {listing.price 
                                      ? `₹${parseFloat(listing.price).toLocaleString('en-IN')}` 
                                      : 'Trade Only'}
                                  </Typography>
                                  <Box display="flex" alignItems="center" gap={0.5}>
                                    <VisibilityIcon sx={{ fontSize: 14 }} />
                                    <Typography variant="caption" color="text.secondary">
                                      {listing.bidCount || 0}
                                    </Typography>
                                  </Box>
                                  <Box display="flex" alignItems="center" gap={0.5}>
                                    <FavoriteIcon sx={{ fontSize: 14 }} />
                                    <Typography variant="caption" color="text.secondary">
                                      0
                                    </Typography>
                                  </Box>
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
                          
                          <Divider />
                          
                          {/* Actions */}
                          <CardActions sx={{ px: 2, py: 1, justifyContent: 'space-between' }}>
                            <Box>
                              {isActive ? (
                                <>
                                  <Button
                                    size="small"
                                    color="success"
                                    startIcon={<CheckCircleIcon />}
                                    onClick={(e) => {
                                      e.preventDefault();
                                      e.stopPropagation();
                                      handleDeactivateListing(listing.listingId, false);
                                    }}
                                  >
                                    Mark as sold
                                  </Button>
                                  <Button
                                    size="small"
                                    color="primary"
                                    onClick={(e) => handleSellFasterClick(listing.listingId, e)}
                                  >
                                    Sell faster now
                                  </Button>
                                </>
                              ) : (
                                <Button
                                  size="small"
                                  color="error"
                                  startIcon={<DeleteIcon />}
                                  onClick={(e) => {
                                    e.preventDefault();
                                    e.stopPropagation();
                                    handleRemoveListing(listing.listingId, false);
                                  }}
                                >
                                  Remove
                                </Button>
                              )}
                            </Box>
                            <Typography variant="caption" color="text.secondary">
                              {isActive ? 'This listing is currently live' : 'This listing is inactive'}
                            </Typography>
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
          {selectedListingId && listings.find(l => l.listingId === selectedListingId)?.isActive ? (
            <MenuItem
              onClick={() => {
                if (selectedListingId) {
                  handleDeactivateListing(selectedListingId, true);
                }
              }}
            >
              Deactivate
            </MenuItem>
          ) : (
            <MenuItem
              onClick={() => {
                if (selectedListingId) {
                  handleRemoveListing(selectedListingId, true);
                }
              }}
            >
              Remove
            </MenuItem>
          )}
        </Menu>

        {/* Sell Faster Now Modal */}
        <Dialog 
          open={showSellFasterModal} 
          onClose={() => {
            setShowSellFasterModal(false);
            setSelectedPackage(null);
            setSelectedListingForFeature(null);
          }}
          maxWidth="md"
          fullWidth
        >
          <DialogTitle>
            Sell Faster Now - Feature Your Listing
            <Typography variant="body2" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
              Get your listing featured at the top of the marketplace for increased visibility
            </Typography>
          </DialogTitle>
          <DialogContent>
            {walletBalance !== null && (
              <Alert severity="info" sx={{ mb: 2 }}>
                Your wallet balance: ₹{parseFloat(walletBalance).toFixed(2)}
              </Alert>
            )}
            
            {featuredPackages.length === 0 ? (
              <Box textAlign="center" py={4}>
                <CircularProgress />
                <Typography variant="body2" sx={{ mt: 2 }}>Loading packages...</Typography>
              </Box>
            ) : (
              <FormControl component="fieldset" fullWidth>
                <FormLabel component="legend" sx={{ mb: 2, fontWeight: 'bold' }}>
                  Select a Featured Package
                </FormLabel>
                <RadioGroup
                  value={selectedPackage?.packageId || ''}
                  onChange={(e) => {
                    const pkg = featuredPackages.find(p => p.packageId === e.target.value);
                    setSelectedPackage(pkg || null);
                  }}
                >
                  <Stack spacing={2}>
                    {featuredPackages.map((pkg) => (
                      <Card 
                        key={pkg.packageId}
                        variant="outlined"
                        sx={{
                          border: selectedPackage?.packageId === pkg.packageId ? 2 : 1,
                          borderColor: selectedPackage?.packageId === pkg.packageId ? 'primary.main' : 'divider',
                          cursor: 'pointer',
                          '&:hover': {
                            boxShadow: 2,
                          }
                        }}
                        onClick={() => setSelectedPackage(pkg)}
                      >
                        <CardContent>
                          <Box display="flex" alignItems="center" justifyContent="space-between">
                            <Box display="flex" alignItems="center" flex={1}>
                              <Radio 
                                value={pkg.packageId}
                                checked={selectedPackage?.packageId === pkg.packageId}
                              />
                              <Box ml={2} flex={1}>
                                <Typography variant="h6">{pkg.packageName}</Typography>
                                <Typography variant="body2" color="text.secondary" sx={{ mt: 0.5 }}>
                                  {pkg.description}
                                </Typography>
                                <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
                                  Duration: {pkg.durationDays} days
                                </Typography>
                              </Box>
                            </Box>
                            <Typography variant="h5" color="primary" fontWeight="bold" sx={{ ml: 2 }}>
                              ₹{parseFloat(pkg.price).toFixed(2)}
                            </Typography>
                          </Box>
                          {walletBalance !== null && parseFloat(walletBalance) < parseFloat(pkg.price) && (
                            <Alert severity="warning" sx={{ mt: 2 }}>
                              Insufficient balance. You need ₹{(parseFloat(pkg.price) - parseFloat(walletBalance)).toFixed(2)} more.
                            </Alert>
                          )}
                        </CardContent>
                      </Card>
                    ))}
                  </Stack>
                </RadioGroup>
              </FormControl>
            )}
          </DialogContent>
          <DialogActions>
            <Button 
              onClick={() => {
                setShowSellFasterModal(false);
                setSelectedPackage(null);
                setSelectedListingForFeature(null);
              }}
              disabled={featuringListing}
            >
              Cancel
            </Button>
            <Button 
              onClick={handleFeatureListing}
              variant="contained"
              color="primary"
              disabled={!selectedPackage || featuringListing || (walletBalance !== null && parseFloat(walletBalance) < parseFloat(selectedPackage.price))}
            >
              {featuringListing ? <CircularProgress size={20} /> : `Pay ₹${selectedPackage ? parseFloat(selectedPackage.price).toFixed(2) : '0.00'}`}
            </Button>
          </DialogActions>
        </Dialog>
      </Container>
    </>
  );
};

export default MyProfile;
