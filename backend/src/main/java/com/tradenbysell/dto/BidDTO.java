package com.tradenbysell.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class BidDTO {
    private Long bidId;
    private String listingId;
    private String listingTitle;
    private String listingImageUrl;
    private String userId;
    private String userName;
    private BigDecimal bidAmount;
    private LocalDateTime bidTime;
    private Boolean isWinning;
}
