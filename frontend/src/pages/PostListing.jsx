import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../services/api';
import Navigation from '../components/Navigation';
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
    setLoading(true);

    try {
      const tagsArray = formData.tags.split(',').map(tag => tag.trim()).filter(tag => tag);
      
      const listingData = {
        title: formData.title,
        description: formData.description,
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
      
      if (images.length > 0) {
        await api.post(`/api/listings/${response.data.listingId}/images`, images);
      }

      navigate(`/listing/${response.data.listingId}`);
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to create listing');
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <Navigation />
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
                <label>Price (₹)</label>
                <input
                  type="number"
                  name="price"
                  value={formData.price}
                  onChange={handleInputChange}
                  step="0.01"
                  min="0"
                />
              </div>

              <div className="form-group">
                <label>Category</label>
                <select
                  name="category"
                  value={formData.category}
                  onChange={handleInputChange}
                >
                  <option value="">Select Category</option>
                  <option value="Electronics">Electronics</option>
                  <option value="Books">Books</option>
                  <option value="Furniture">Furniture</option>
                  <option value="Clothing">Clothing</option>
                  <option value="Sports">Sports</option>
                  <option value="Stationery">Stationery</option>
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
                <h3>Bidding Details</h3>
                <div className="form-row">
                  <div className="form-group">
                    <label>Starting Price (₹)</label>
                    <input
                      type="number"
                      name="startingPrice"
                      value={formData.startingPrice}
                      onChange={handleInputChange}
                      step="0.01"
                      min="0"
                    />
                  </div>

                  <div className="form-group">
                    <label>Bid Increment (₹)</label>
                    <input
                      type="number"
                      name="bidIncrement"
                      value={formData.bidIncrement}
                      onChange={handleInputChange}
                      step="0.01"
                      min="0"
                    />
                  </div>
                </div>

                <div className="form-row">
                  <div className="form-group">
                    <label>Bid Start Time</label>
                    <input
                      type="datetime-local"
                      name="bidStartTime"
                      value={formData.bidStartTime}
                      onChange={handleInputChange}
                    />
                  </div>

                  <div className="form-group">
                    <label>Bid End Time</label>
                    <input
                      type="datetime-local"
                      name="bidEndTime"
                      value={formData.bidEndTime}
                      onChange={handleInputChange}
                    />
                  </div>
                </div>
              </div>
            )}

            <div className="form-group">
              <label>Tags (comma separated)</label>
              <input
                type="text"
                name="tags"
                value={formData.tags}
                onChange={handleInputChange}
                placeholder="e.g., laptop, electronics, dell"
              />
            </div>

            <div className="form-group">
              <label>Images</label>
              <input
                type="file"
                multiple
                accept="image/*"
                onChange={handleImageUpload}
                disabled={uploading}
              />
              {uploading && <p>Uploading images...</p>}
              {images.length > 0 && (
                <div className="uploaded-images">
                  {images.map((url, index) => (
                    <img key={index} src={url} alt={`Upload ${index + 1}`} />
                  ))}
                </div>
              )}
            </div>

            <button type="submit" disabled={loading} className="submit-btn">
              {loading ? 'Creating...' : 'Create Listing'}
            </button>
          </form>
        </div>
      </div>
    </>
  );
};

export default PostListing;
