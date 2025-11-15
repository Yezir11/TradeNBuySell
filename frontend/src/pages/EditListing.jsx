import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import api from '../services/api';
import MarketplaceHeader from '../components/MarketplaceHeader';
import './PostListing.css';

const EditListing = () => {
  const { listingId } = useParams();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    price: '',
    category: '',
    isTradeable: false,
    isBiddable: false,
    startingPrice: '',
    bidIncrement: '',
    bidStartTime: '',
    bidEndTime: '',
    tags: ''
  });
  const [images, setImages] = useState([]);
  const [existingImages, setExistingImages] = useState([]);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [showFlaggedDialog, setShowFlaggedDialog] = useState(false);
  const [newListingId, setNewListingId] = useState(null);

  useEffect(() => {
    fetchListing();
  }, [listingId]);

  const fetchListing = async () => {
    try {
      const response = await api.get(`/api/listings/${listingId}`);
      const listing = response.data;
      
      // Format dates for datetime-local inputs
      const formatDateForInput = (dateString) => {
        if (!dateString) return '';
        const date = new Date(dateString);
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');
        return `${year}-${month}-${day}T${hours}:${minutes}`;
      };

      setFormData({
        title: listing.title || '',
        description: listing.description || '',
        price: listing.price ? parseFloat(listing.price).toString() : '',
        category: listing.category || '',
        isTradeable: listing.isTradeable || false,
        isBiddable: listing.isBiddable || false,
        startingPrice: listing.startingPrice ? parseFloat(listing.startingPrice).toString() : '',
        bidIncrement: listing.bidIncrement ? parseFloat(listing.bidIncrement).toString() : '',
        bidStartTime: formatDateForInput(listing.bidStartTime),
        bidEndTime: formatDateForInput(listing.bidEndTime),
        tags: listing.tags ? listing.tags.join(', ') : ''
      });

      if (listing.imageUrls && listing.imageUrls.length > 0) {
        setExistingImages(listing.imageUrls);
      }
    } catch (err) {
      setError('Failed to load listing');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
  };

  const handleImageUpload = async (e) => {
    const files = Array.from(e.target.files);
    if (files.length === 0) return;

    setUploading(true);
    try {
      const formData = new FormData();
      files.forEach(file => formData.append('files', file));

      const response = await api.post('/api/upload/images', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
      setImages(prev => [...prev, ...response.data]);
    } catch (err) {
      setError('Failed to upload images');
    } finally {
      setUploading(false);
    }
  };

  const removeExistingImage = (index) => {
    setExistingImages(prev => prev.filter((_, i) => i !== index));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    
    // Validate required fields
    if (!formData.title.trim()) {
      setError('Title is required');
      return;
    }
    if (!formData.description.trim()) {
      setError('Description is required');
      return;
    }
    if (!formData.category) {
      setError('Category is required');
      return;
    }
    if (!formData.price && !formData.isTradeable && !formData.isBiddable) {
      setError('Price is required if listing is neither tradeable nor biddable');
      return;
    }
    if (formData.isBiddable) {
      if (!formData.startingPrice) {
        setError('Starting price is required for biddable listings');
        return;
      }
      if (!formData.bidIncrement) {
        setError('Bid increment is required for biddable listings');
        return;
      }
      if (!formData.bidStartTime) {
        setError('Bid start time is required for biddable listings');
        return;
      }
      if (!formData.bidEndTime) {
        setError('Bid end time is required for biddable listings');
        return;
      }
    }
    if (!formData.tags.trim()) {
      setError('Tags are required');
      return;
    }
    
    // Check if we have at least one image (either existing or new)
    const allImages = [...existingImages, ...images];
    if (allImages.length === 0) {
      setError('At least one image is required');
      return;
    }
    
    setSubmitting(true);

    try {
      const tagsArray = formData.tags.split(',').map(tag => tag.trim()).filter(tag => tag);
      
      const listingData = {
        title: formData.title.trim(),
        description: formData.description.trim(),
        price: formData.price ? parseFloat(formData.price) : null,
        category: formData.category,
        isTradeable: formData.isTradeable,
        isBiddable: formData.isBiddable,
        startingPrice: formData.startingPrice ? parseFloat(formData.startingPrice) : null,
        bidIncrement: formData.bidIncrement ? parseFloat(formData.bidIncrement) : null,
        bidStartTime: formData.bidStartTime || null,
        bidEndTime: formData.bidEndTime || null,
        tags: tagsArray
      };

      // Call the edit endpoint which creates a new listing and deactivates the old one
      const response = await api.post(`/api/listings/${listingId}/edit`, listingData);
      
      // Combine existing and new images
      const allImageUrls = [...existingImages, ...images];
      
      // Add images to the new listing
      const imagesResponse = await api.post(`/api/listings/${response.data.listingId}/images`, allImageUrls);

      // Check if listing was flagged by moderation
      if (imagesResponse.data.warning || !imagesResponse.data.listingActive) {
        setNewListingId(response.data.listingId);
        setShowFlaggedDialog(true);
      } else {
        navigate(`/listing/${response.data.listingId}`);
      }
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to update listing');
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <>
        <MarketplaceHeader showSearch={false} />
        <div className="post-listing-page">
          <div className="container">
            <p>Loading listing...</p>
          </div>
        </div>
      </>
    );
  }

  return (
    <>
      <MarketplaceHeader showSearch={false} />
      <div className="post-listing-page">
        <div className="container">
          <h1>Edit Listing</h1>
          <p style={{ color: 'var(--tbs-text-muted)', marginBottom: '20px' }}>
            Editing this listing will create a new listing and deactivate the current one. The new listing will go through moderation review.
          </p>

          {error && <div className="error-message">{error}</div>}

          <form onSubmit={handleSubmit} className="listing-form">
            <div className="form-group">
              <label>Title *</label>
              <input
                type="text"
                name="title"
                value={formData.title}
                onChange={handleInputChange}
                required
              />
            </div>

            <div className="form-group">
              <label>Description *</label>
              <textarea
                name="description"
                value={formData.description}
                onChange={handleInputChange}
                rows="5"
                required
              />
            </div>

            <div className="form-row">
              <div className="form-group">
                <label>Price (₹) *</label>
                <input
                  type="number"
                  name="price"
                  value={formData.price}
                  onChange={handleInputChange}
                  step="0.01"
                  min="0"
                  required={!formData.isTradeable && !formData.isBiddable}
                />
                {!formData.isTradeable && !formData.isBiddable && (
                  <small style={{ color: 'var(--tbs-text-muted)', display: 'block', marginTop: '4px' }}>
                    Required if not tradeable or biddable
                  </small>
                )}
              </div>

              <div className="form-group">
                <label>Category *</label>
                <select
                  name="category"
                  value={formData.category}
                  onChange={handleInputChange}
                  required
                >
                  <option value="">Select Category</option>
                  <option value="Electronics">Electronics</option>
                  <option value="Books">Books</option>
                  <option value="Furniture">Furniture</option>
                  <option value="Clothing">Clothing</option>
                  <option value="Sports">Sports</option>
                  <option value="Stationery">Stationery</option>
                  <option value="Appliances">Appliances</option>
                  <option value="Other">Other</option>
                </select>
              </div>
            </div>

            <div className="form-row">
              <div className="form-group checkbox-group">
                <label>
                  <input
                    type="checkbox"
                    name="isTradeable"
                    checked={formData.isTradeable}
                    onChange={handleInputChange}
                  />
                  Tradeable
                </label>
              </div>

              <div className="form-group checkbox-group">
                <label>
                  <input
                    type="checkbox"
                    name="isBiddable"
                    checked={formData.isBiddable}
                    onChange={handleInputChange}
                  />
                  Biddable
                </label>
              </div>
            </div>

            {formData.isBiddable && (
              <div className="bidding-section">
                <h3>Bidding Details *</h3>
                <div className="form-row">
                  <div className="form-group">
                    <label>Starting Price (₹) *</label>
                    <input
                      type="number"
                      name="startingPrice"
                      value={formData.startingPrice}
                      onChange={handleInputChange}
                      step="0.01"
                      min="0"
                      required
                    />
                  </div>

                  <div className="form-group">
                    <label>Bid Increment (₹) *</label>
                    <input
                      type="number"
                      name="bidIncrement"
                      value={formData.bidIncrement}
                      onChange={handleInputChange}
                      step="0.01"
                      min="0"
                      required
                    />
                  </div>
                </div>

                <div className="form-row">
                  <div className="form-group">
                    <label>Bid Start Time *</label>
                    <input
                      type="datetime-local"
                      name="bidStartTime"
                      value={formData.bidStartTime}
                      onChange={handleInputChange}
                      required
                    />
                  </div>

                  <div className="form-group">
                    <label>Bid End Time *</label>
                    <input
                      type="datetime-local"
                      name="bidEndTime"
                      value={formData.bidEndTime}
                      onChange={handleInputChange}
                      required
                    />
                  </div>
                </div>
              </div>
            )}

            <div className="form-group">
              <label>Tags (comma separated) *</label>
              <input
                type="text"
                name="tags"
                value={formData.tags}
                onChange={handleInputChange}
                placeholder="e.g., laptop, electronics, dell"
                required
              />
            </div>

            <div className="form-group">
              <label>Images *</label>
              
              {/* Existing Images */}
              {existingImages.length > 0 && (
                <div className="existing-images-section" style={{ marginBottom: '15px' }}>
                  <p style={{ marginBottom: '10px', color: 'var(--tbs-text-muted)' }}>Current Images (click to remove):</p>
                  <div className="uploaded-images">
                    {existingImages.map((url, index) => (
                      <div key={index} style={{ position: 'relative', display: 'inline-block' }}>
                        <img src={url} alt={`Existing ${index + 1}`} />
                        <button
                          type="button"
                          onClick={() => removeExistingImage(index)}
                          style={{
                            position: 'absolute',
                            top: '5px',
                            right: '5px',
                            background: 'var(--tbs-red)',
                            color: 'white',
                            border: 'none',
                            borderRadius: '50%',
                            width: '24px',
                            height: '24px',
                            cursor: 'pointer',
                            fontSize: '14px'
                          }}
                        >
                          ×
                        </button>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* New Image Upload */}
              <input
                type="file"
                multiple
                accept="image/*"
                onChange={handleImageUpload}
                disabled={uploading}
              />
              {uploading && <p>Uploading images...</p>}
              {images.length > 0 && (
                <div className="uploaded-images" style={{ marginTop: '15px' }}>
                  <p style={{ marginBottom: '10px', color: 'var(--tbs-text-muted)' }}>New Images:</p>
                  {images.map((url, index) => (
                    <img key={index} src={url} alt={`Upload ${index + 1}`} />
                  ))}
                </div>
              )}
              {existingImages.length === 0 && images.length === 0 && !uploading && (
                <small style={{ color: 'var(--tbs-red)', display: 'block', marginTop: '4px' }}>
                  At least one image is required
                </small>
              )}
            </div>

            <div style={{ display: 'flex', gap: '10px' }}>
              <button 
                type="button" 
                onClick={() => navigate(-1)} 
                className="btn-secondary"
                style={{ flex: 1 }}
              >
                Cancel
              </button>
              <button type="submit" disabled={submitting} className="submit-btn" style={{ flex: 2 }}>
                {submitting ? 'Creating New Listing...' : 'Save as New Listing'}
              </button>
            </div>
          </form>

          {/* Flagged Listing Dialog */}
          {showFlaggedDialog && (
            <div className="modal-overlay" onClick={() => setShowFlaggedDialog(false)}>
              <div className="modal-content flagged-dialog" onClick={(e) => e.stopPropagation()}>
                <div className="flagged-dialog-header">
                  <h2>⚠️ Listing Flagged for Review</h2>
                </div>
                <div className="flagged-dialog-body">
                  <p>
                    Your edited listing has been flagged by our AI content moderation system and is pending admin review.
                  </p>
                  <p>
                    <strong>What happens next?</strong>
                  </p>
                  <ul>
                    <li>Your new listing is currently inactive and not visible to other users</li>
                    <li>The original listing has been deactivated</li>
                    <li>An admin will review your listing shortly</li>
                    <li>You will be notified once the review is complete</li>
                    <li>If approved, your listing will be activated automatically</li>
                  </ul>
                  <p>
                    <strong>New Listing ID:</strong> {newListingId}
                  </p>
                </div>
                <div className="flagged-dialog-actions">
                  <button 
                    className="btn-primary" 
                    onClick={() => {
                      setShowFlaggedDialog(false);
                      navigate('/');
                    }}
                  >
                    Go to Home
                  </button>
                  <button 
                    className="btn-secondary" 
                    onClick={() => {
                      setShowFlaggedDialog(false);
                      navigate(`/listing/${newListingId}`);
                    }}
                  >
                    View Listing
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </>
  );
};

export default EditListing;

