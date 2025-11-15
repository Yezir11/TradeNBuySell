package com.tradenbysell.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "purchase_offers", indexes = {
    @Index(name = "idx_listing_id", columnList = "listing_id"),
    @Index(name = "idx_buyer_id", columnList = "buyer_id"),
    @Index(name = "idx_seller_id", columnList = "seller_id"),
    @Index(name = "idx_status", columnList = "status"),
    @Index(name = "idx_created_at", columnList = "created_at")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PurchaseOffer {
    
    @Id
    @Column(name = "offer_id", length = 36, columnDefinition = "CHAR(36)")
    private String offerId;
    
    @Column(name = "listing_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String listingId;
    
    @Column(name = "buyer_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String buyerId;
    
    @Column(name = "seller_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String sellerId;
    
    @Column(name = "offer_amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal offerAmount;
    
    @Column(name = "original_listing_price", nullable = false, precision = 15, scale = 2)
    private BigDecimal originalListingPrice;
    
    @Column(name = "counter_offer_amount", precision = 15, scale = 2)
    private BigDecimal counterOfferAmount;
    
    @Column(name = "message", columnDefinition = "TEXT")
    private String message;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, columnDefinition = "ENUM('PENDING','ACCEPTED','REJECTED','COUNTERED','EXPIRED','CANCELLED')")
    private OfferStatus status = OfferStatus.PENDING;
    
    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @Column(name = "accepted_at")
    private LocalDateTime acceptedAt;
    
    @PrePersist
    protected void onCreate() {
        if (offerId == null) {
            offerId = UUID.randomUUID().toString();
        }
    }
    
    public enum OfferStatus {
        PENDING, ACCEPTED, REJECTED, COUNTERED, EXPIRED, CANCELLED
    }
}

