package com.tradenbysell.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "feedbacks", indexes = {
    @Index(name = "idx_user_id", columnList = "user_id"),
    @Index(name = "idx_listing_id", columnList = "listing_id"),
    @Index(name = "idx_trade_id", columnList = "trade_id"),
    @Index(name = "idx_type", columnList = "type"),
    @Index(name = "idx_timestamp", columnList = "timestamp")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Feedback {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "feedback_id")
    private Long feedbackId;

    @Column(name = "user_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String userId;

    @Column(name = "listing_id", length = 36, columnDefinition = "CHAR(36)")
    private String listingId;

    @Column(name = "trade_id", length = 36, columnDefinition = "CHAR(36)")
    private String tradeId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private FeedbackType type;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String comment;

    @CreationTimestamp
    @Column(name = "timestamp")
    private LocalDateTime timestamp;

    public enum FeedbackType {
        POST_PURCHASE, POST_TRADE, POST_BID, GENERAL
    }
}

