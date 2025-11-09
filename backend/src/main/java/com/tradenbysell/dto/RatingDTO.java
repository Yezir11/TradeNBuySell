package com.tradenbysell.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class RatingDTO {
    private Long ratingId;
    private String fromUserId;
    private String fromUserName;
    private String toUserId;
    private String toUserName;
    private String listingId;
    private String listingTitle;
    
    @NotNull(message = "Rating value is required")
    @Min(value = 1, message = "Rating must be at least 1")
    @Max(value = 5, message = "Rating must be at most 5")
    private Integer ratingValue;
    
    private String reviewComment;
    private LocalDateTime timestamp;
}

