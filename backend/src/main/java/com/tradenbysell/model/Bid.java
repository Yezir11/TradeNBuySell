package com.tradenbysell.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "bids", indexes = {
    @Index(name = "idx_listing_id", columnList = "listing_id"),
    @Index(name = "idx_user_id", columnList = "user_id"),
    @Index(name = "idx_bid_time", columnList = "bid_time"),
    @Index(name = "idx_is_winning", columnList = "is_winning")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Bid {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "bid_id")
    private Long bidId;

    @Column(name = "listing_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String listingId;

    @Column(name = "user_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String userId;

    @Column(name = "bid_amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal bidAmount;

    @CreationTimestamp
    @Column(name = "bid_time")
    private LocalDateTime bidTime;

    @Column(name = "is_winning")
    private Boolean isWinning = false;
}

