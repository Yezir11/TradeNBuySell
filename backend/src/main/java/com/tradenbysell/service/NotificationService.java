package com.tradenbysell.service;

import com.tradenbysell.dto.NotificationDTO;
import com.tradenbysell.exception.ResourceNotFoundException;
import com.tradenbysell.model.Notification;
import com.tradenbysell.repository.NotificationRepository;
import com.tradenbysell.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class NotificationService {
    
    @Autowired
    private NotificationRepository notificationRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    /**
     * Create a notification
     */
    @Transactional
    public NotificationDTO createNotification(String userId, Notification.NotificationType type,
                                             String title, String message, 
                                             String relatedEntityId, Notification.RelatedEntityType relatedEntityType,
                                             Notification.Priority priority, Map<String, Object> metadata) {
        if (!userRepository.existsById(userId)) {
            throw new ResourceNotFoundException("User not found");
        }
        
        Notification notification = new Notification();
        notification.setUserId(userId);
        notification.setType(type);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setRelatedEntityId(relatedEntityId);
        notification.setRelatedEntityType(relatedEntityType);
        notification.setPriority(priority);
        notification.setMetadata(metadata);
        notification.setIsRead(false);
        
        notification = notificationRepository.save(notification);
        return toDTO(notification);
    }
    
    /**
     * Get all notifications for a user
     */
    public Page<NotificationDTO> getUserNotifications(String userId, Pageable pageable) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable)
                .map(this::toDTO);
    }
    
    /**
     * Get unread notifications for a user
     */
    public Page<NotificationDTO> getUnreadNotifications(String userId, Pageable pageable) {
        return notificationRepository.findByUserIdAndIsReadOrderByCreatedAtDesc(userId, false, pageable)
                .map(this::toDTO);
    }
    
    /**
     * Get unread count for a user
     */
    public Long getUnreadCount(String userId) {
        return notificationRepository.countUnreadByUserId(userId);
    }
    
    /**
     * Mark notification as read
     */
    @Transactional
    public NotificationDTO markAsRead(Long notificationId, String userId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Notification not found"));
        
        if (!notification.getUserId().equals(userId)) {
            throw new ResourceNotFoundException("Notification not found");
        }
        
        notification.setIsRead(true);
        notification.setReadAt(LocalDateTime.now());
        notification = notificationRepository.save(notification);
        return toDTO(notification);
    }
    
    /**
     * Mark all notifications as read for a user
     */
    @Transactional
    public int markAllAsRead(String userId) {
        return notificationRepository.markAllAsReadByUserId(userId, LocalDateTime.now());
    }
    
    /**
     * Delete a notification
     */
    @Transactional
    public void deleteNotification(Long notificationId, String userId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Notification not found"));
        
        if (!notification.getUserId().equals(userId)) {
            throw new ResourceNotFoundException("Notification not found");
        }
        
        notificationRepository.delete(notification);
    }
    
    /**
     * Delete old notifications (cleanup)
     */
    @Transactional
    public int deleteOldNotifications(String userId, LocalDateTime beforeDate) {
        return notificationRepository.deleteOldNotifications(userId, beforeDate);
    }
    
    // Helper method to convert entity to DTO
    private NotificationDTO toDTO(Notification notification) {
        NotificationDTO dto = new NotificationDTO();
        dto.setNotificationId(notification.getNotificationId());
        dto.setUserId(notification.getUserId());
        dto.setType(notification.getType());
        dto.setTitle(notification.getTitle());
        dto.setMessage(notification.getMessage());
        dto.setRelatedEntityId(notification.getRelatedEntityId());
        dto.setRelatedEntityType(notification.getRelatedEntityType());
        dto.setIsRead(notification.getIsRead());
        dto.setReadAt(notification.getReadAt());
        dto.setPriority(notification.getPriority());
        dto.setMetadata(notification.getMetadata());
        dto.setCreatedAt(notification.getCreatedAt());
        return dto;
    }
    
    // ========== Notification Creation Methods for Different Events ==========
    
    // Listing-related notifications
    public void notifyListingFlagged(String userId, String listingId, String listingTitle) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("listingId", listingId);
        metadata.put("listingTitle", listingTitle);
        
        createNotification(userId, Notification.NotificationType.LISTING_FLAGGED,
                "Listing Flagged", 
                String.format("Your listing '%s' was flagged by ML moderation and is pending admin review.", listingTitle),
                listingId, Notification.RelatedEntityType.LISTING,
                Notification.Priority.MEDIUM, metadata);
    }
    
    public void notifyListingApproved(String userId, String listingId, String listingTitle) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("listingId", listingId);
        metadata.put("listingTitle", listingTitle);
        
        createNotification(userId, Notification.NotificationType.LISTING_APPROVED,
                "Listing Approved",
                String.format("Your listing '%s' has been approved by admin and is now active.", listingTitle),
                listingId, Notification.RelatedEntityType.LISTING,
                Notification.Priority.MEDIUM, metadata);
    }
    
    public void notifyListingRejected(String userId, String listingId, String listingTitle, String reason) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("listingId", listingId);
        metadata.put("listingTitle", listingTitle);
        metadata.put("reason", reason);
        
        createNotification(userId, Notification.NotificationType.LISTING_REJECTED,
                "Listing Rejected",
                String.format("Your listing '%s' has been rejected by admin. Reason: %s", listingTitle, reason),
                listingId, Notification.RelatedEntityType.LISTING,
                Notification.Priority.MEDIUM, metadata);
    }
    
    public void notifyListingFeatured(String userId, String listingId, String listingTitle, int days) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("listingId", listingId);
        metadata.put("listingTitle", listingTitle);
        metadata.put("days", days);
        
        createNotification(userId, Notification.NotificationType.LISTING_FEATURED,
                "Listing Featured",
                String.format("Your listing '%s' has been featured and will appear at the top for %d days.", listingTitle, days),
                listingId, Notification.RelatedEntityType.LISTING,
                Notification.Priority.MEDIUM, metadata);
    }
    
    // Bidding-related notifications
    public void notifyNewBidReceived(String userId, String listingId, String listingTitle, BigDecimal bidAmount, String bidderName) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("listingId", listingId);
        metadata.put("listingTitle", listingTitle);
        metadata.put("bidAmount", bidAmount);
        metadata.put("bidderName", bidderName);
        
        createNotification(userId, Notification.NotificationType.NEW_BID_RECEIVED,
                "New Bid Received",
                String.format("%s placed a bid of ₹%s on your listing '%s'.", bidderName, bidAmount.toPlainString(), listingTitle),
                listingId, Notification.RelatedEntityType.LISTING,
                Notification.Priority.MEDIUM, metadata);
    }
    
    public void notifyBidOutbid(String userId, String listingId, String listingTitle, BigDecimal newBidAmount) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("listingId", listingId);
        metadata.put("listingTitle", listingTitle);
        metadata.put("newBidAmount", newBidAmount);
        
        createNotification(userId, Notification.NotificationType.BID_OUTBID,
                "You Were Outbid",
                String.format("Your bid on '%s' was outbid. New highest bid: ₹%s", listingTitle, newBidAmount.toPlainString()),
                listingId, Notification.RelatedEntityType.BID,
                Notification.Priority.HIGH, metadata);
    }
    
    public void notifyBidWon(String userId, String listingId, String listingTitle, BigDecimal winningBid) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("listingId", listingId);
        metadata.put("listingTitle", listingTitle);
        metadata.put("winningBid", winningBid);
        
        createNotification(userId, Notification.NotificationType.BID_WON,
                "Bid Won! 🎉",
                String.format("Congratulations! You won the bid on '%s' with ₹%s.", listingTitle, winningBid.toPlainString()),
                listingId, Notification.RelatedEntityType.BID,
                Notification.Priority.HIGH, metadata);
    }
    
    public void notifyBidLost(String userId, String listingId, String listingTitle) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("listingId", listingId);
        metadata.put("listingTitle", listingTitle);
        
        createNotification(userId, Notification.NotificationType.BID_LOST,
                "Bid Lost",
                String.format("You lost the bid on '%s'. Someone else won the auction.", listingTitle),
                listingId, Notification.RelatedEntityType.BID,
                Notification.Priority.HIGH, metadata);
    }
    
    // Trade-related notifications
    public void notifyTradeProposed(String userId, String tradeId, String listingTitle, String initiatorName) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("tradeId", tradeId);
        metadata.put("listingTitle", listingTitle);
        metadata.put("initiatorName", initiatorName);
        
        createNotification(userId, Notification.NotificationType.TRADE_PROPOSED,
                "New Trade Proposal",
                String.format("%s proposed a trade involving your listing '%s'.", initiatorName, listingTitle),
                tradeId, Notification.RelatedEntityType.TRADE,
                Notification.Priority.MEDIUM, metadata);
    }
    
    public void notifyTradeAccepted(String userId, String tradeId, String listingTitle) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("tradeId", tradeId);
        metadata.put("listingTitle", listingTitle);
        
        createNotification(userId, Notification.NotificationType.TRADE_ACCEPTED,
                "Trade Accepted! ✅",
                String.format("Your trade proposal for '%s' was accepted. Funds have been transferred.", listingTitle),
                tradeId, Notification.RelatedEntityType.TRADE,
                Notification.Priority.HIGH, metadata);
    }
    
    public void notifyTradeRejected(String userId, String tradeId, String listingTitle) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("tradeId", tradeId);
        metadata.put("listingTitle", listingTitle);
        
        createNotification(userId, Notification.NotificationType.TRADE_REJECTED,
                "Trade Rejected",
                String.format("Your trade proposal for '%s' was rejected.", listingTitle),
                tradeId, Notification.RelatedEntityType.TRADE,
                Notification.Priority.MEDIUM, metadata);
    }
    
    public void notifyTradeCompleted(String userId, String tradeId, String listingTitle) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("tradeId", tradeId);
        metadata.put("listingTitle", listingTitle);
        
        createNotification(userId, Notification.NotificationType.TRADE_COMPLETED,
                "Trade Completed",
                String.format("Trade for '%s' has been completed successfully. You can now rate each other.", listingTitle),
                tradeId, Notification.RelatedEntityType.TRADE,
                Notification.Priority.HIGH, metadata);
    }
    
    // Purchase offer-related notifications
    public void notifyPurchaseOfferReceived(String userId, String offerId, String listingTitle, BigDecimal offerAmount, String buyerName) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("offerId", offerId);
        metadata.put("listingTitle", listingTitle);
        metadata.put("offerAmount", offerAmount);
        metadata.put("buyerName", buyerName);
        
        createNotification(userId, Notification.NotificationType.PURCHASE_OFFER_RECEIVED,
                "New Purchase Offer",
                String.format("%s made a purchase offer of ₹%s on your listing '%s'.", buyerName, offerAmount.toPlainString(), listingTitle),
                offerId, Notification.RelatedEntityType.OFFER,
                Notification.Priority.MEDIUM, metadata);
    }
    
    public void notifyPurchaseOfferAccepted(String userId, String offerId, String listingTitle, BigDecimal amount) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("offerId", offerId);
        metadata.put("listingTitle", listingTitle);
        metadata.put("amount", amount);
        
        createNotification(userId, Notification.NotificationType.PURCHASE_OFFER_ACCEPTED,
                "Purchase Offer Accepted! ✅",
                String.format("Your purchase offer of ₹%s for '%s' was accepted. Payment has been transferred.", amount.toPlainString(), listingTitle),
                offerId, Notification.RelatedEntityType.OFFER,
                Notification.Priority.HIGH, metadata);
    }
    
    public void notifyPurchaseOfferRejected(String userId, String offerId, String listingTitle) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("offerId", offerId);
        metadata.put("listingTitle", listingTitle);
        
        createNotification(userId, Notification.NotificationType.PURCHASE_OFFER_REJECTED,
                "Purchase Offer Rejected",
                String.format("Your purchase offer for '%s' was rejected.", listingTitle),
                offerId, Notification.RelatedEntityType.OFFER,
                Notification.Priority.MEDIUM, metadata);
    }
    
    public void notifyPurchaseOfferCountered(String userId, String offerId, String listingTitle, BigDecimal counterAmount) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("offerId", offerId);
        metadata.put("listingTitle", listingTitle);
        metadata.put("counterAmount", counterAmount);
        
        createNotification(userId, Notification.NotificationType.PURCHASE_OFFER_COUNTERED,
                "Counter Offer Received",
                String.format("Seller countered your offer for '%s' with ₹%s.", listingTitle, counterAmount.toPlainString()),
                offerId, Notification.RelatedEntityType.OFFER,
                Notification.Priority.MEDIUM, metadata);
    }
    
    public void notifyCounterOfferAccepted(String userId, String offerId, String listingTitle, BigDecimal amount) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("offerId", offerId);
        metadata.put("listingTitle", listingTitle);
        metadata.put("amount", amount);
        
        createNotification(userId, Notification.NotificationType.COUNTER_OFFER_ACCEPTED,
                "Counter Offer Accepted! ✅",
                String.format("Buyer accepted your counter offer of ₹%s for '%s'. Payment has been received.", amount.toPlainString(), listingTitle),
                offerId, Notification.RelatedEntityType.OFFER,
                Notification.Priority.HIGH, metadata);
    }
    
    public void notifyPurchaseCompleted(String userId, String offerId, String listingTitle, BigDecimal amount) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("offerId", offerId);
        metadata.put("listingTitle", listingTitle);
        metadata.put("amount", amount);
        
        createNotification(userId, Notification.NotificationType.PURCHASE_COMPLETED,
                "Purchase Completed",
                String.format("Purchase of '%s' for ₹%s has been completed successfully.", listingTitle, amount.toPlainString()),
                offerId, Notification.RelatedEntityType.OFFER,
                Notification.Priority.HIGH, metadata);
    }
    
    // Wallet-related notifications
    public void notifyWalletCredited(String userId, BigDecimal amount, String reason, String description) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("amount", amount);
        metadata.put("reason", reason);
        
        Notification.Priority priority = amount.compareTo(new BigDecimal("10000")) > 0 
                ? Notification.Priority.HIGH : Notification.Priority.MEDIUM;
        
        createNotification(userId, Notification.NotificationType.WALLET_CREDITED,
                "Funds Credited",
                String.format("₹%s has been credited to your wallet. %s", amount.toPlainString(), description),
                null, Notification.RelatedEntityType.WALLET_TRANSACTION,
                priority, metadata);
    }
    
    public void notifyWalletDebited(String userId, BigDecimal amount, String reason, String description) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("amount", amount);
        metadata.put("reason", reason);
        
        Notification.Priority priority = amount.compareTo(new BigDecimal("10000")) > 0 
                ? Notification.Priority.HIGH : Notification.Priority.MEDIUM;
        
        createNotification(userId, Notification.NotificationType.WALLET_DEBITED,
                "Funds Debited",
                String.format("₹%s has been debited from your wallet. %s", amount.toPlainString(), description),
                null, Notification.RelatedEntityType.WALLET_TRANSACTION,
                priority, metadata);
    }
    
    public void notifyInsufficientFunds(String userId, BigDecimal required, BigDecimal available) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("required", required);
        metadata.put("available", available);
        
        createNotification(userId, Notification.NotificationType.INSUFFICIENT_FUNDS,
                "Insufficient Funds",
                String.format("Transaction failed. Required: ₹%s, Available: ₹%s", required.toPlainString(), available.toPlainString()),
                null, null,
                Notification.Priority.HIGH, metadata);
    }
    
    // Trust score & rating notifications
    public void notifyTrustScoreUpdated(String userId, Float newTrustScore) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("trustScore", newTrustScore);
        
        createNotification(userId, Notification.NotificationType.TRUST_SCORE_UPDATED,
                "Trust Score Updated",
                String.format("Your trust score has been updated to %.2f.", newTrustScore),
                null, null,
                Notification.Priority.LOW, metadata);
    }
    
    public void notifyRatingReceived(String userId) {
        createNotification(userId, Notification.NotificationType.RATING_RECEIVED,
                "New Rating Received",
                "You received a new rating from a completed transaction.",
                null, null,
                Notification.Priority.LOW, null);
    }
    
    public void notifyRatingReminder(String userId, String listingTitle, String otherUserName) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("listingTitle", listingTitle);
        metadata.put("otherUserName", otherUserName);
        
        createNotification(userId, Notification.NotificationType.RATING_REMINDER,
                "Rate Your Transaction",
                String.format("Don't forget to rate %s for your transaction involving '%s'.", otherUserName, listingTitle),
                null, null,
                Notification.Priority.LOW, metadata);
    }
    
    // Account management notifications
    public void notifyAccountSuspended(String userId, String reason) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("reason", reason);
        
        createNotification(userId, Notification.NotificationType.ACCOUNT_SUSPENDED,
                "Account Suspended",
                String.format("Your account has been suspended. Reason: %s", reason),
                null, null,
                Notification.Priority.HIGH, metadata);
    }
    
    public void notifyAccountReactivated(String userId) {
        createNotification(userId, Notification.NotificationType.ACCOUNT_REACTIVATED,
                "Account Reactivated",
                "Your account has been reactivated. You can now use all features.",
                null, null,
                Notification.Priority.HIGH, null);
    }
    
    // Chat notifications
    public void notifyNewMessage(String userId, String senderName, String listingTitle) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("senderName", senderName);
        if (listingTitle != null) {
            metadata.put("listingTitle", listingTitle);
        }
        
        String message = listingTitle != null 
                ? String.format("New message from %s about '%s'.", senderName, listingTitle)
                : String.format("New message from %s.", senderName);
        
        createNotification(userId, Notification.NotificationType.NEW_MESSAGE,
                "New Message",
                message,
                null, Notification.RelatedEntityType.MESSAGE,
                Notification.Priority.MEDIUM, metadata);
    }
    
    // Admin notifications
    public void notifyAdminNewFlaggedListing(String adminId, String listingId, String listingTitle, String predictedLabel) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("listingId", listingId);
        metadata.put("listingTitle", listingTitle);
        metadata.put("predictedLabel", predictedLabel);
        
        createNotification(adminId, Notification.NotificationType.NEW_FLAGGED_LISTING,
                "New Flagged Listing",
                String.format("New listing '%s' flagged by ML moderation (predicted: %s). Requires review.", listingTitle, predictedLabel),
                listingId, Notification.RelatedEntityType.MODERATION_LOG,
                Notification.Priority.MEDIUM, metadata);
    }
    
    public void notifyAdminNewReport(String adminId, String reportId, String reportType) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("reportId", reportId);
        metadata.put("reportType", reportType);
        
        createNotification(adminId, Notification.NotificationType.NEW_REPORT_SUBMITTED,
                "New Report Submitted",
                String.format("New %s report submitted. Requires review.", reportType),
                reportId, Notification.RelatedEntityType.REPORT,
                Notification.Priority.MEDIUM, metadata);
    }
}

