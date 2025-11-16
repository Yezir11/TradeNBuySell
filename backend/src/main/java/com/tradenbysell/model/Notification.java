package com.tradenbysell.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.Map;

@Entity
@Table(name = "notifications", indexes = {
    @Index(name = "idx_user_id", columnList = "user_id"),
    @Index(name = "idx_is_read", columnList = "is_read"),
    @Index(name = "idx_created_at", columnList = "created_at"),
    @Index(name = "idx_type", columnList = "type"),
    @Index(name = "idx_priority", columnList = "priority")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Notification {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "notification_id")
    private Long notificationId;

    @Column(name = "user_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String userId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 100)
    private NotificationType type;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String message;

    @Column(name = "related_entity_id", length = 255)
    private String relatedEntityId;

    @Enumerated(EnumType.STRING)
    @Column(name = "related_entity_type", length = 50)
    private RelatedEntityType relatedEntityType;

    @Column(name = "is_read", nullable = false)
    private Boolean isRead = false;

    @Column(name = "read_at")
    private LocalDateTime readAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Priority priority = Priority.MEDIUM;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "metadata", columnDefinition = "JSON")
    private Map<String, Object> metadata;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    public enum NotificationType {
        // Listing-related
        LISTING_FLAGGED, LISTING_APPROVED, LISTING_REJECTED, LISTING_DEACTIVATED,
        LISTING_FEATURED, LISTING_FEATURE_EXPIRED, LISTING_EDITED,
        LISTING_VIEWED, LISTING_ADDED_TO_WISHLIST,
        
        // Bidding-related
        NEW_BID_RECEIVED, BID_OUTBID, BID_WON, BID_LOST, BID_FINALIZED,
        BIDDING_ENDING_SOON, BIDDING_ENDED,
        
        // Trade-related
        TRADE_PROPOSED, TRADE_ACCEPTED, TRADE_REJECTED, TRADE_CANCELLED,
        TRADE_COMPLETED, TRADE_ASK_NEW_PROPOSAL,
        
        // Purchase offer-related
        PURCHASE_OFFER_RECEIVED, PURCHASE_OFFER_ACCEPTED, PURCHASE_OFFER_REJECTED,
        PURCHASE_OFFER_COUNTERED, COUNTER_OFFER_ACCEPTED, PURCHASE_COMPLETED,
        
        // Chat-related
        NEW_MESSAGE,
        
        // Wallet-related
        WALLET_CREDITED, WALLET_DEBITED, INSUFFICIENT_FUNDS, LARGE_TRANSACTION,
        
        // Trust score & rating
        TRUST_SCORE_UPDATED, RATING_RECEIVED, RATING_REMINDER,
        
        // Account management
        ACCOUNT_SUSPENDED, ACCOUNT_REACTIVATED, PASSWORD_CHANGED, LOGIN_FROM_NEW_DEVICE,
        
        // System updates
        FEATURE_ANNOUNCEMENT, MAINTENANCE_SCHEDULED, POLICY_UPDATE,
        
        // Admin notifications
        NEW_FLAGGED_LISTING, NEW_REPORT_SUBMITTED, REPORT_RESOLVED,
        NEW_USER_REGISTERED, SUSPICIOUS_ACTIVITY, MULTIPLE_REPORTS_ON_USER,
        ML_MODERATION_API_DOWN, DATABASE_ERROR, HIGH_ERROR_RATE,
        BACKUP_COMPLETED, BACKUP_FAILED, DAILY_SUMMARY, WEEKLY_REPORT, MONTHLY_REPORT
    }

    public enum RelatedEntityType {
        LISTING, TRADE, OFFER, BID, MESSAGE, USER, REPORT, MODERATION_LOG, WALLET_TRANSACTION
    }

    public enum Priority {
        HIGH, MEDIUM, LOW
    }
}

