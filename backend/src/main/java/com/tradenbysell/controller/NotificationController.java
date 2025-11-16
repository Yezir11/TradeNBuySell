package com.tradenbysell.controller;

import com.tradenbysell.dto.NotificationDTO;
import com.tradenbysell.dto.PagedResponse;
import com.tradenbysell.service.NotificationService;
import com.tradenbysell.util.AuthUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = "*")
public class NotificationController {
    
    @Autowired
    private NotificationService notificationService;
    
    @Autowired
    private AuthUtil authUtil;
    
    /**
     * Get all notifications for the authenticated user
     */
    @GetMapping
    public ResponseEntity<PagedResponse<NotificationDTO>> getNotifications(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        Pageable pageable = PageRequest.of(page, size);
        Page<NotificationDTO> notifications = notificationService.getUserNotifications(userId, pageable);
        
        PagedResponse<NotificationDTO> response = new PagedResponse<NotificationDTO>(
                notifications.getContent(),
                notifications.getNumber(),
                notifications.getSize(),
                notifications.getTotalElements(),
                notifications.getTotalPages(),
                notifications.isFirst(),
                notifications.isLast()
        );
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get unread notifications for the authenticated user
     */
    @GetMapping("/unread")
    public ResponseEntity<PagedResponse<NotificationDTO>> getUnreadNotifications(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        Pageable pageable = PageRequest.of(page, size);
        Page<NotificationDTO> notifications = notificationService.getUnreadNotifications(userId, pageable);
        
        PagedResponse<NotificationDTO> response = new PagedResponse<NotificationDTO>(
                notifications.getContent(),
                notifications.getNumber(),
                notifications.getSize(),
                notifications.getTotalElements(),
                notifications.getTotalPages(),
                notifications.isFirst(),
                notifications.isLast()
        );
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get unread notification count
     */
    @GetMapping("/unread-count")
    public ResponseEntity<Map<String, Long>> getUnreadCount(Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        Long count = notificationService.getUnreadCount(userId);
        
        Map<String, Long> response = new HashMap<>();
        response.put("unreadCount", count);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Mark a notification as read
     */
    @PutMapping("/{notificationId}/read")
    public ResponseEntity<NotificationDTO> markAsRead(
            @PathVariable Long notificationId,
            Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        NotificationDTO notification = notificationService.markAsRead(notificationId, userId);
        return ResponseEntity.ok(notification);
    }
    
    /**
     * Mark all notifications as read for the authenticated user
     */
    @PutMapping("/read-all")
    public ResponseEntity<Map<String, Integer>> markAllAsRead(Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        int count = notificationService.markAllAsRead(userId);
        
        Map<String, Integer> response = new HashMap<>();
        response.put("markedAsRead", count);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Delete a notification
     */
    @DeleteMapping("/{notificationId}")
    public ResponseEntity<Map<String, String>> deleteNotification(
            @PathVariable Long notificationId,
            Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        notificationService.deleteNotification(notificationId, userId);
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "Notification deleted successfully");
        return ResponseEntity.ok(response);
    }
}

