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
    private LocalDateTime timestamp;
    private Boolean isReported;
}

