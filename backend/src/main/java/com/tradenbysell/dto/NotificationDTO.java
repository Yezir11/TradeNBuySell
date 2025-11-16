package com.tradenbysell.dto;

import com.tradenbysell.model.Notification;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.Map;

@Data
public class NotificationDTO {
    private Long notificationId;
    private String userId;
    private Notification.NotificationType type;
    private String title;
    private String message;
    private String relatedEntityId;
    private Notification.RelatedEntityType relatedEntityType;
    private Boolean isRead;
    private LocalDateTime readAt;
    private Notification.Priority priority;
    private Map<String, Object> metadata;
    private LocalDateTime createdAt;
}

