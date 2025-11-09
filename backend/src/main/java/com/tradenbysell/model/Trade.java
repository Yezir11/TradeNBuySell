package com.tradenbysell.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "trades", indexes = {
    @Index(name = "idx_initiator_id", columnList = "initiator_id"),
    @Index(name = "idx_recipient_id", columnList = "recipient_id"),
    @Index(name = "idx_requested_listing_id", columnList = "requested_listing_id"),
    @Index(name = "idx_status", columnList = "status"),
    @Index(name = "idx_created_at", columnList = "created_at")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Trade {
    @Id
    @Column(name = "trade_id", length = 36, columnDefinition = "CHAR(36)")
    private String tradeId;

    @Column(name = "initiator_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String initiatorId;

    @Column(name = "recipient_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String recipientId;

    @Column(name = "requested_listing_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String requestedListingId;

    @Column(name = "cash_adjustment_amount", precision = 15, scale = 2)
    private BigDecimal cashAdjustmentAmount = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @Column
    private TradeStatus status = TradeStatus.PENDING;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "resolved_at")
    private LocalDateTime resolvedAt;

    @PrePersist
    protected void onCreate() {
        if (tradeId == null) {
            tradeId = java.util.UUID.randomUUID().toString();
        }
    }

    public enum TradeStatus {
        PENDING, ACCEPTED, REJECTED, COMPLETED, CANCELLED
    }
}

