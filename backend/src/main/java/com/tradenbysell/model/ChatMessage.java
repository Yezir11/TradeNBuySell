package com.tradenbysell.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "chat_messages", indexes = {
    @Index(name = "idx_sender_id", columnList = "sender_id"),
    @Index(name = "idx_receiver_id", columnList = "receiver_id"),
    @Index(name = "idx_listing_id", columnList = "listing_id"),
    @Index(name = "idx_timestamp", columnList = "timestamp")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "message_id")
    private Long messageId;

    @Column(name = "sender_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String senderId;

    @Column(name = "receiver_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String receiverId;

    @Column(name = "listing_id", length = 36, columnDefinition = "CHAR(36)")
    private String listingId;

    @Column(name = "message_text", nullable = false, columnDefinition = "TEXT")
    private String messageText;

    @Column(name = "message_type", length = 50)
    private String messageType; // TEXT, PURCHASE_OFFER, OFFER_ACCEPTED, OFFER_REJECTED, OFFER_COUNTERED

    @Column(name = "offer_id", length = 36, columnDefinition = "CHAR(36)")
    private String offerId; // Reference to purchase offer if message type is offer-related

    @CreationTimestamp
    @Column(name = "timestamp")
    private LocalDateTime timestamp;

    @Column(name = "is_reported")
    private Boolean isReported = false;
}

