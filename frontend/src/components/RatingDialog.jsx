import React, { useState } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  Rating,
  Typography,
  Box,
  Alert
} from '@mui/material';
import api from '../services/api';

const RatingDialog = ({ open, onClose, onSuccess, toUserId, toUserName, listingId, listingTitle }) => {
  const [ratingValue, setRatingValue] = useState(0);
  const [reviewComment, setReviewComment] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [hover, setHover] = useState(-1);

  const handleSubmit = async () => {
    if (ratingValue === 0) {
      setError('Please select a rating');
      return;
    }

    if (ratingValue < 1 || ratingValue > 5) {
      setError('Rating must be between 1 and 5 stars');
      return;
    }

    setError('');
    setSubmitting(true);

    try {
      await api.post('/api/ratings', {
        toUserId,
        ratingValue,
        reviewComment: reviewComment.trim() || null,
        listingId
      });

      // Reset form
      setRatingValue(0);
      setReviewComment('');
      setError('');

      if (onSuccess) {
        onSuccess();
      }
      onClose();
    } catch (err) {
      console.error('Failed to submit rating:', err);
      setError(err.response?.data?.message || 'Failed to submit rating. Please try again.');
    } finally {
      setSubmitting(false);
    }
  };

  const handleClose = () => {
    if (!submitting) {
      setRatingValue(0);
      setReviewComment('');
      setError('');
      onClose();
    }
  };

  const labels = {
    1: 'Poor',
    2: 'Fair',
    3: 'Good',
    4: 'Very Good',
    5: 'Excellent'
  };

  return (
    <Dialog 
      open={open} 
      onClose={handleClose}
      maxWidth="sm"
      fullWidth
      PaperProps={{
        sx: {
          bgcolor: 'var(--tbs-bg-card)',
          color: 'var(--tbs-text)',
          border: '1px solid var(--tbs-border)'
        }
      }}
    >
      <DialogTitle sx={{ color: 'var(--tbs-text)' }}>
        Rate {toUserName || 'User'}
      </DialogTitle>
      
      <DialogContent>
        {listingTitle && (
          <Typography variant="body2" sx={{ mb: 2, color: 'var(--tbs-text-muted)' }}>
            Transaction: {listingTitle}
          </Typography>
        )}

        {error && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {error}
          </Alert>
        )}

        <Box sx={{ mb: 3 }}>
          <Typography component="legend" sx={{ mb: 1, color: 'var(--tbs-text)' }}>
            Your Rating *
          </Typography>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <Rating
              name="rating"
              value={ratingValue}
              onChange={(event, newValue) => {
                setRatingValue(newValue || 0);
                setError('');
              }}
              onChangeActive={(event, newHover) => {
                setHover(newHover);
              }}
              size="large"
              sx={{
                '& .MuiRating-iconFilled': {
                  color: 'var(--tbs-gold)'
                },
                '& .MuiRating-iconHover': {
                  color: 'var(--tbs-gold)'
                }
              }}
            />
            {ratingValue !== null && (
              <Typography sx={{ color: 'var(--tbs-text-muted)', minWidth: '100px' }}>
                {labels[hover !== -1 ? hover : ratingValue]}
              </Typography>
            )}
          </Box>
        </Box>

        <TextField
          fullWidth
          multiline
          rows={4}
          label="Review Comment (Optional)"
          value={reviewComment}
          onChange={(e) => setReviewComment(e.target.value)}
          placeholder="Share your experience with this user..."
          sx={{
            '& .MuiOutlinedInput-root': {
              color: 'var(--tbs-text)',
              '& fieldset': {
                borderColor: 'var(--tbs-border)'
              },
              '&:hover fieldset': {
                borderColor: 'var(--tbs-gold)'
              },
              '&.Mui-focused fieldset': {
                borderColor: 'var(--tbs-gold)'
              }
            },
            '& .MuiInputLabel-root': {
              color: 'var(--tbs-text-muted)'
            },
            '& .MuiInputLabel-root.Mui-focused': {
              color: 'var(--tbs-gold)'
            }
          }}
          disabled={submitting}
        />
      </DialogContent>

      <DialogActions sx={{ p: 2, gap: 1 }}>
        <Button
          onClick={handleClose}
          disabled={submitting}
          sx={{
            color: 'var(--tbs-text-muted)',
            '&:hover': {
              bgcolor: 'var(--tbs-bg-hover)'
            }
          }}
        >
          Cancel
        </Button>
        <Button
          onClick={handleSubmit}
          variant="contained"
          disabled={submitting || ratingValue === 0}
          sx={{
            bgcolor: 'var(--tbs-gold)',
            color: 'var(--tbs-bg)',
            '&:hover': {
              bgcolor: 'var(--tbs-gold-dark)'
            },
            '&:disabled': {
              bgcolor: 'var(--tbs-bg-disabled)',
              color: 'var(--tbs-text-muted)'
            }
          }}
        >
          {submitting ? 'Submitting...' : 'Submit Rating'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default RatingDialog;

