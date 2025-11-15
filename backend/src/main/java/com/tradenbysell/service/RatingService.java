package com.tradenbysell.service;

import com.tradenbysell.dto.RatingDTO;
import com.tradenbysell.exception.BadRequestException;
import com.tradenbysell.exception.ResourceNotFoundException;
import com.tradenbysell.model.Listing;
import com.tradenbysell.model.Rating;
import com.tradenbysell.model.User;
import com.tradenbysell.repository.BidRepository;
import com.tradenbysell.repository.ListingRepository;
import com.tradenbysell.repository.RatingRepository;
import com.tradenbysell.repository.TradeRepository;
import com.tradenbysell.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class RatingService {
    @Autowired
    private RatingRepository ratingRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ListingRepository listingRepository;

    @Autowired
    private TradeRepository tradeRepository;

    @Autowired
    private BidRepository bidRepository;
    
    @Autowired
    private com.tradenbysell.repository.PurchaseOfferRepository purchaseOfferRepository;

    @Transactional
    public RatingDTO createRating(String fromUserId, String toUserId, Integer ratingValue,
                                   String reviewComment, String listingId) {
        if (fromUserId.equals(toUserId)) {
            throw new BadRequestException("Cannot rate yourself");
        }

        // Validate that both users exist
        if (!userRepository.existsById(fromUserId)) {
            throw new ResourceNotFoundException("From user not found");
        }
        if (!userRepository.existsById(toUserId)) {
            throw new ResourceNotFoundException("To user not found");
        }

        Listing listing = null;
        if (listingId != null) {
            listing = listingRepository.findById(listingId)
                    .orElseThrow(() -> new ResourceNotFoundException("Listing not found"));
        }

        if (ratingValue < 1 || ratingValue > 5) {
            throw new BadRequestException("Rating value must be between 1 and 5");
        }

        // Validate that users have completed a legitimate transaction
        boolean hasValidTransaction = false;
        
        if (listingId != null && listing != null) {
            // Check for completed trade for this specific listing
            if (tradeRepository.haveCompletedTradeForListing(fromUserId, toUserId, listingId)) {
                hasValidTransaction = true;
            }
            // Check if fromUserId has winning bid (purchased via bidding) and toUserId is the seller
            else if (listing.getUserId().equals(toUserId) && 
                     bidRepository.hasWinningBidForListing(fromUserId, listingId)) {
                hasValidTransaction = true;
            }
            // Check if they have completed a purchase transaction for this listing
            else if (purchaseOfferRepository.haveCompletedPurchaseForListing(fromUserId, toUserId, listingId)) {
                hasValidTransaction = true;
            }
        } else {
            // If no listing specified, check if they have any completed trade
            if (tradeRepository.haveCompletedTrade(fromUserId, toUserId)) {
                hasValidTransaction = true;
            }
            // Check if they have any completed purchase transaction
            else if (purchaseOfferRepository.haveCompletedPurchase(fromUserId, toUserId)) {
                hasValidTransaction = true;
            }
        }

        if (!hasValidTransaction) {
            throw new BadRequestException("You can only rate users you have completed a transaction with (trade, purchase, or sale)");
        }

        Rating existingRating = ratingRepository.findByFromUserIdAndToUserIdAndListingId(fromUserId, toUserId, listingId).orElse(null);
        if (existingRating != null) {
            throw new BadRequestException("You have already rated this user for this listing");
        }

        Rating rating = new Rating();
        rating.setFromUserId(fromUserId);
        rating.setToUserId(toUserId);
        rating.setListingId(listingId);
        rating.setRatingValue(ratingValue);
        rating.setReviewComment(reviewComment);
        rating = ratingRepository.save(rating);

        updateTrustScore(toUserId);

        return toDTO(rating);
    }

    public List<RatingDTO> getUserRatings(String userId) {
        return ratingRepository.findByToUserIdOrderByTimestampDesc(userId).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    /**
     * Check if a user can rate another user (has completed transaction and hasn't rated yet)
     */
    public boolean canRateUser(String fromUserId, String toUserId, String listingId) {
        if (fromUserId.equals(toUserId)) {
            return false;
        }

        // Check if already rated
        if (listingId != null) {
            if (ratingRepository.findByFromUserIdAndToUserIdAndListingId(fromUserId, toUserId, listingId).isPresent()) {
                return false; // Already rated for this listing
            }
        }

        // Check if they have a completed transaction
        boolean hasValidTransaction = false;
        
        if (listingId != null) {
            Listing listing = listingRepository.findById(listingId).orElse(null);
            if (listing != null) {
                // Check for completed trade
                if (tradeRepository.haveCompletedTradeForListing(fromUserId, toUserId, listingId)) {
                    hasValidTransaction = true;
                }
                // Check for winning bid
                else if (listing.getUserId().equals(toUserId) && 
                         bidRepository.hasWinningBidForListing(fromUserId, listingId)) {
                    hasValidTransaction = true;
                }
                // Check for completed purchase
                else if (purchaseOfferRepository.haveCompletedPurchaseForListing(fromUserId, toUserId, listingId)) {
                    hasValidTransaction = true;
                }
            }
        } else {
            // Check for any completed transaction
            if (tradeRepository.haveCompletedTrade(fromUserId, toUserId)) {
                hasValidTransaction = true;
            } else if (purchaseOfferRepository.haveCompletedPurchase(fromUserId, toUserId)) {
                hasValidTransaction = true;
            }
        }

        return hasValidTransaction;
    }

    @Transactional
    protected void updateTrustScore(String userId) {
        Double averageRating = ratingRepository.getAverageRatingByUserId(userId);
        Long ratingCount = ratingRepository.getRatingCountByUserId(userId);

        if (averageRating != null && ratingCount != null) {
            double bayesianAverage;
            if (ratingCount == 0) {
                bayesianAverage = 0.0;
            } else {
                double priorMean = 3.0;
                long priorCount = 5;
                bayesianAverage = (priorMean * priorCount + averageRating * ratingCount) / (priorCount + ratingCount);
            }

            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new ResourceNotFoundException("User not found"));
            user.setTrustScore((float) bayesianAverage);
            userRepository.save(user);
        }
    }

    private RatingDTO toDTO(Rating rating) {
        RatingDTO dto = new RatingDTO();
        dto.setRatingId(rating.getRatingId());
        // Do not expose fromUserId or fromUserName to keep ratings anonymous
        // dto.setFromUserId(rating.getFromUserId());
        dto.setToUserId(rating.getToUserId());
        dto.setListingId(rating.getListingId());
        dto.setRatingValue(rating.getRatingValue());
        dto.setReviewComment(rating.getReviewComment());
        dto.setTimestamp(rating.getTimestamp());

        // Keep rater anonymous - do not set fromUserName
        // User fromUser = userRepository.findById(rating.getFromUserId()).orElse(null);
        // if (fromUser != null) {
        //     dto.setFromUserName(fromUser.getFullName());
        // }

        User toUser = userRepository.findById(rating.getToUserId()).orElse(null);
        if (toUser != null) {
            dto.setToUserName(toUser.getFullName());
        }

        if (rating.getListingId() != null) {
            Listing listing = listingRepository.findById(rating.getListingId()).orElse(null);
            if (listing != null) {
                dto.setListingTitle(listing.getTitle());
            }
        }

        return dto;
    }
}

