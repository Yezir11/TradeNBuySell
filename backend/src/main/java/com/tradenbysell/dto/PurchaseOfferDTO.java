package com.tradenbysell.dto;

import com.tradenbysell.model.PurchaseOffer;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PurchaseOfferDTO {
    private String offerId;
    private String listingId;
    private String buyerId;
    private String buyerName;
    private String sellerId;
    private String sellerName;
    private BigDecimal offerAmount;
    private BigDecimal originalListingPrice;
    private BigDecimal counterOfferAmount;
    private String message;
    private PurchaseOffer.OfferStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime acceptedAt;
    
    // Listing details for context
    private String listingTitle;
    private String listingImageUrl;
}

