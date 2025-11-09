package com.tradenbysell.controller;

import com.tradenbysell.dto.RatingDTO;
import com.tradenbysell.service.RatingService;
import com.tradenbysell.util.AuthUtil;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/ratings")
@CrossOrigin(origins = "*")
public class RatingController {

    @Autowired
    private AuthUtil authUtil;
    @Autowired
    private RatingService ratingService;

    @PostMapping
    public ResponseEntity<RatingDTO> createRating(@Valid @RequestBody CreateRatingRequest request,
                                                 Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        RatingDTO rating = ratingService.createRating(userId, request.getToUserId(),
                request.getRatingValue(), request.getReviewComment(), request.getListingId());
        return ResponseEntity.ok(rating);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<RatingDTO>> getUserRatings(@PathVariable String userId) {
        List<RatingDTO> ratings = ratingService.getUserRatings(userId);
        return ResponseEntity.ok(ratings);
    }

    public static class CreateRatingRequest {
        private String toUserId;
        private Integer ratingValue;
        private String reviewComment;
        private String listingId;

        public String getToUserId() {
            return toUserId;
        }

        public void setToUserId(String toUserId) {
            this.toUserId = toUserId;
        }

        public Integer getRatingValue() {
            return ratingValue;
        }

        public void setRatingValue(Integer ratingValue) {
            this.ratingValue = ratingValue;
        }

        public String getReviewComment() {
            return reviewComment;
        }

        public void setReviewComment(String reviewComment) {
            this.reviewComment = reviewComment;
        }

        public String getListingId() {
            return listingId;
        }

        public void setListingId(String listingId) {
            this.listingId = listingId;
        }
    }
}

