package com.tradenbysell.service;

import com.tradenbysell.dto.RatingDTO;
import com.tradenbysell.exception.BadRequestException;
import com.tradenbysell.exception.ResourceNotFoundException;
import com.tradenbysell.model.Listing;
import com.tradenbysell.model.Rating;
import com.tradenbysell.model.User;
import com.tradenbysell.repository.ListingRepository;
import com.tradenbysell.repository.RatingRepository;
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

    @Transactional
    public RatingDTO createRating(String fromUserId, String toUserId, Integer ratingValue,
                                   String reviewComment, String listingId) {
        if (fromUserId.equals(toUserId)) {
            throw new BadRequestException("Cannot rate yourself");
        }

        User fromUser = userRepository.findById(fromUserId)
                .orElseThrow(() -> new ResourceNotFoundException("From user not found"));

        User toUser = userRepository.findById(toUserId)
                .orElseThrow(() -> new ResourceNotFoundException("To user not found"));

        if (listingId != null) {
            Listing listing = listingRepository.findById(listingId)
                    .orElseThrow(() -> new ResourceNotFoundException("Listing not found"));
        }

        if (ratingValue < 1 || ratingValue > 5) {
            throw new BadRequestException("Rating value must be between 1 and 5");
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
        dto.setFromUserId(rating.getFromUserId());
        dto.setToUserId(rating.getToUserId());
        dto.setListingId(rating.getListingId());
        dto.setRatingValue(rating.getRatingValue());
        dto.setReviewComment(rating.getReviewComment());
        dto.setTimestamp(rating.getTimestamp());

        User fromUser = userRepository.findById(rating.getFromUserId()).orElse(null);
        if (fromUser != null) {
            dto.setFromUserName(fromUser.getFullName());
        }

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

