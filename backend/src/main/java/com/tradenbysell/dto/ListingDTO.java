package com.tradenbysell.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class ListingDTO {
    private String listingId;
    private String userId;
    private String sellerName;
    private Float sellerTrustScore;
    private String title;
    private String description;
    private BigDecimal price;
    private Boolean isTradeable;
    private Boolean isBiddable;
    private BigDecimal startingPrice;
    private BigDecimal bidIncrement;
    private LocalDateTime bidStartTime;
    private LocalDateTime bidEndTime;
    private Boolean isActive;
    private String category;
    private List<String> imageUrls;
    private List<String> tags;
    private BigDecimal highestBid;
    private Long bidCount;
    private Boolean isFeatured;
    private LocalDateTime featuredUntil;
    private String featuredType;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

