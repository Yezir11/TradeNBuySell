import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../services/api';
import MarketplaceHeader from '../components/MarketplaceHeader';
import './PostListing.css';

const PostListing = () => {
  const navigate = useNavigate();
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
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [showFlaggedDialog, setShowFlaggedDialog] = useState(false);
  const [flaggedListingId, setFlaggedListingId] = useState(null);

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
    if (images.length === 0) {
      setError('At least one image is required');
      return;
    }
    
    setLoading(true);

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

      const response = await api.post('/api/listings', listingData);
      
      // Images are now mandatory, so this should always execute
      const imagesResponse = await api.post(`/api/listings/${response.data.listingId}/images`, images);

      // Check if listing was flagged by moderation
      if (imagesResponse.data.warning || !imagesResponse.data.listingActive) {
        setFlaggedListingId(response.data.listingId);
        setShowFlaggedDialog(true);
      } else {
        navigate(`/listing/${response.data.listingId}`);
      }
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to create listing');
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <MarketplaceHeader showSearch={false} />
      <div className="post-listing-page">
        <div className="container">
          <h1>Post a New Listing</h1>

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
                  <small style={{ color: '#666', display: 'block', marginTop: '4px' }}>
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
              <input
                type="file"
                multiple
                accept="image/*"
                onChange={handleImageUpload}
                disabled={uploading}
                required
              />
              {uploading && <p>Uploading images...</p>}
              {images.length > 0 && (
                <div className="uploaded-images">
                  {images.map((url, index) => (
                    <img key={index} src={url} alt={`Upload ${index + 1}`} />
                  ))}
                </div>
              )}
              {images.length === 0 && !uploading && (
                <small style={{ color: '#d32f2f', display: 'block', marginTop: '4px' }}>
                  At least one image is required
                </small>
              )}
            </div>

            <button type="submit" disabled={loading} className="submit-btn">
              {loading ? 'Creating...' : 'Create Listing'}
            </button>
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
                    Your listing has been flagged by our AI content moderation system and is pending admin review.
                  </p>
                  <p>
                    <strong>What happens next?</strong>
                  </p>
                  <ul>
                    <li>Your listing is currently inactive and not visible to other users</li>
                    <li>An admin will review your listing shortly</li>
                    <li>You will be notified once the review is complete</li>
                    <li>If approved, your listing will be activated automatically</li>
                  </ul>
                  <p>
                    <strong>Listing ID:</strong> {flaggedListingId}
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
                      navigate(`/listing/${flaggedListingId}`);
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

export default PostListing;
