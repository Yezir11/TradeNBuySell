package com.tradenbysell.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ChatMessageDTO {
    private Long messageId;
    private String senderId;
    private String senderName;
    private String receiverId;
    private String receiverName;
    private String listingId;
    private String listingTitle;
    private String messageText;
    private String messageType; // TEXT, PURCHASE_OFFER, OFFER_ACCEPTED, OFFER_REJECTED, OFFER_COUNTERED, TRADE_PROPOSAL
    private String offerId; // Reference to purchase offer if message type is offer-related
    private String tradeId; // Reference to trade if message type is trade-related
    private LocalDateTime timestamp;
    private Boolean isReported;
    private Boolean isRead;
    private LocalDateTime readAt;
}

