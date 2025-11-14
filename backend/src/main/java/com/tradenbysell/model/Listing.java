package com.tradenbysell.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "listings", indexes = {
    @Index(name = "idx_user_id", columnList = "user_id"),
    @Index(name = "idx_is_active", columnList = "is_active"),
    @Index(name = "idx_category", columnList = "category"),
    @Index(name = "idx_is_tradeable", columnList = "is_tradeable"),
    @Index(name = "idx_is_biddable", columnList = "is_biddable"),
    @Index(name = "idx_created_at", columnList = "created_at"),
    @Index(name = "idx_is_featured", columnList = "is_featured"),
    @Index(name = "idx_featured_until", columnList = "featured_until")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Listing {
    @Id
    @Column(name = "listing_id", length = 36, columnDefinition = "CHAR(36)")
    private String listingId;

    @Column(name = "user_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String userId;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;

    @Column(precision = 15, scale = 2)
    private BigDecimal price;

    @Column(name = "is_tradeable")
    private Boolean isTradeable = false;

    @Column(name = "is_biddable")
    private Boolean isBiddable = false;

    @Column(name = "starting_price", precision = 15, scale = 2)
    private BigDecimal startingPrice;

    @Column(name = "bid_increment", precision = 15, scale = 2)
    private BigDecimal bidIncrement;

    @Column(name = "bid_start_time")
    private LocalDateTime bidStartTime;

    @Column(name = "bid_end_time")
    private LocalDateTime bidEndTime;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "is_featured")
    private Boolean isFeatured = false;

    @Column(name = "featured_until")
    private LocalDateTime featuredUntil;

    @Column(name = "featured_type", length = 50)
    private String featuredType;

    @Column(length = 100)
    private String category;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        if (listingId == null) {
            listingId = java.util.UUID.randomUUID().toString();
        }
    }
}

