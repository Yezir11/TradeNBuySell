import React, { useState, useEffect } from 'react';
import api from '../services/api';

const RatingButton = ({ toUserId, toUserName, listingId, listingTitle, onRated }) => {
  const [canRate, setCanRate] = useState(null);
  const [checking, setChecking] = useState(true);

  useEffect(() => {
    const checkRatingEligibility = async () => {
      // If toUserId is not provided but listingId is, fetch listing first
      let finalToUserId = toUserId;
      
      if (!finalToUserId && listingId) {
        try {
          const listingResponse = await api.get(`/api/listings/${listingId}`);
          finalToUserId = listingResponse.data.userId;
        } catch (err) {
          console.error('Failed to fetch listing:', err);
          setCanRate(false);
          setChecking(false);
          return;
        }
      }

      if (!finalToUserId) {
        setCanRate(false);
        setChecking(false);
        return;
      }

      try {
        const response = await api.get(
          `/api/ratings/can-rate?toUserId=${finalToUserId}${listingId ? `&listingId=${listingId}` : ''}`
        );
        setCanRate(response.data.canRate);
      } catch (err) {
        console.error('Failed to check rating eligibility:', err);
        setCanRate(false);
      } finally {
        setChecking(false);
      }
    };

    checkRatingEligibility();
  }, [toUserId, listingId]);

  if (checking) {
    return null; // Don't show button while checking
  }

  if (!canRate) {
    return null; // Don't show button if user can't rate
  }

  const handleClick = async () => {
    if (!onRated) return;

    // If toUserId is null but we have listingId, fetch listing first
    let finalToUserId = toUserId;
    let finalToUserName = toUserName;

    if (!finalToUserId && listingId) {
      try {
        const listingResponse = await api.get(`/api/listings/${listingId}`);
        finalToUserId = listingResponse.data.userId;
        finalToUserName = listingResponse.data.sellerName || finalToUserName;
      } catch (err) {
        console.error('Failed to fetch listing:', err);
        return;
      }
    }

    onRated(finalToUserId, finalToUserName, listingId, listingTitle);
  };

  return (
    <button
      onClick={handleClick}
      style={{
        backgroundColor: 'var(--tbs-gold)',
        color: 'var(--tbs-bg)',
        border: 'none',
        padding: '8px 16px',
        borderRadius: '4px',
        cursor: 'pointer',
        fontWeight: 'bold',
        marginTop: '8px',
        fontSize: '14px',
        width: '100%'
      }}
    >
      ⭐ Rate {toUserName || 'User'}
    </button>
  );
};

export default RatingButton;

