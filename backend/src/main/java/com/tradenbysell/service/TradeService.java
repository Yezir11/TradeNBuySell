package com.tradenbysell.service;

import com.tradenbysell.dto.TradeDTO;
import com.tradenbysell.exception.BadRequestException;
import com.tradenbysell.exception.InsufficientFundsException;
import com.tradenbysell.exception.ResourceNotFoundException;
import com.tradenbysell.model.Listing;
import com.tradenbysell.model.Trade;
import com.tradenbysell.model.TradeOffering;
import com.tradenbysell.model.User;
import com.tradenbysell.model.WalletTransaction;
import com.tradenbysell.repository.ListingRepository;
import com.tradenbysell.repository.TradeOfferingRepository;
import com.tradenbysell.repository.TradeRepository;
import com.tradenbysell.repository.UserRepository;
import com.tradenbysell.service.WalletService;
import com.tradenbysell.service.ChatService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class TradeService {
    @Autowired
    private TradeRepository tradeRepository;

    @Autowired
    private TradeOfferingRepository tradeOfferingRepository;

    @Autowired
    private ListingRepository listingRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private WalletService walletService;
    
    @Autowired
    private ChatService chatService;
    
    @Autowired
    private NotificationService notificationService;
    
    @Autowired
    private com.tradenbysell.repository.ListingImageRepository listingImageRepository;

    @Transactional
    public TradeDTO createTrade(String initiatorId, String requestedListingId, 
                                 List<String> offeringListingIds, 
                                 BigDecimal cashAdjustmentAmount) {
        Listing requestedListing = listingRepository.findById(requestedListingId)
                .orElseThrow(() -> new ResourceNotFoundException("Requested listing not found"));

        if (!requestedListing.getIsTradeable()) {
            throw new BadRequestException("Requested listing is not tradeable");
        }

        if (!requestedListing.getIsActive()) {
            throw new BadRequestException("Requested listing is not active");
        }

        if (requestedListing.getUserId().equals(initiatorId)) {
            throw new BadRequestException("Cannot trade with your own listing");
        }

        // Validate cash adjustment and check funds
        if (cashAdjustmentAmount != null && cashAdjustmentAmount.compareTo(BigDecimal.ZERO) != 0) {
            BigDecimal absAmount = cashAdjustmentAmount.abs();
            if (cashAdjustmentAmount.compareTo(BigDecimal.ZERO) > 0) {
                // Initiator pays extra - check initiator's balance
                BigDecimal balance = walletService.getBalance(initiatorId);
                if (balance.compareTo(absAmount) < 0) {
                    throw new InsufficientFundsException("Insufficient funds for cash adjustment");
                }
            } else {
                // Recipient pays extra (negative adjustment) - check recipient's balance
                BigDecimal recipientBalance = walletService.getBalance(requestedListing.getUserId());
                if (recipientBalance.compareTo(absAmount) < 0) {
                    throw new BadRequestException("Recipient does not have sufficient funds for cash adjustment");
                }
            }
        }

        Trade trade = new Trade();
        trade.setTradeId(UUID.randomUUID().toString());
        trade.setInitiatorId(initiatorId);
        trade.setRecipientId(requestedListing.getUserId());
        trade.setRequestedListingId(requestedListingId);
        trade.setCashAdjustmentAmount(cashAdjustmentAmount != null ? cashAdjustmentAmount : BigDecimal.ZERO);
        trade.setStatus(Trade.TradeStatus.PENDING);
        trade = tradeRepository.save(trade);

        if (offeringListingIds != null && !offeringListingIds.isEmpty()) {
            for (String offeringListingId : offeringListingIds) {
                Listing offeringListing = listingRepository.findById(offeringListingId)
                        .orElseThrow(() -> new ResourceNotFoundException("Offering listing not found: " + offeringListingId));

                if (!offeringListing.getUserId().equals(initiatorId)) {
                    throw new BadRequestException("You can only offer your own listings");
                }

                TradeOffering tradeOffering = new TradeOffering();
                tradeOffering.setTradeId(trade.getTradeId());
                tradeOffering.setListingId(offeringListingId);
                tradeOfferingRepository.save(tradeOffering);
            }
        }

        // Notify recipient about trade proposal
        User initiator = userRepository.findById(initiatorId).orElse(null);
        if (initiator != null) {
            notificationService.notifyTradeProposed(
                    requestedListing.getUserId(),
                    trade.getTradeId(),
                    requestedListing.getTitle(),
                    initiator.getFullName()
            );
        }
        
        // No longer holding funds - funds will be transferred immediately on acceptance
        return toDTO(trade);
    }

    @Transactional
    public TradeDTO acceptTrade(String userId, String tradeId) {
        Trade trade = tradeRepository.findById(tradeId)
                .orElseThrow(() -> new ResourceNotFoundException("Trade not found"));

        if (!trade.getRecipientId().equals(userId)) {
            throw new BadRequestException("Only the recipient can accept a trade");
        }

        if (trade.getStatus() != Trade.TradeStatus.PENDING) {
            throw new BadRequestException("Trade is not in pending status");
        }

        Listing requestedListing = listingRepository.findById(trade.getRequestedListingId())
                .orElseThrow(() -> new ResourceNotFoundException("Requested listing not found"));

        if (!requestedListing.getIsActive()) {
            throw new BadRequestException("Requested listing is no longer active");
        }

        // Transfer funds immediately on acceptance
        if (trade.getCashAdjustmentAmount() != null && trade.getCashAdjustmentAmount().compareTo(BigDecimal.ZERO) != 0) {
            BigDecimal absAmount = trade.getCashAdjustmentAmount().abs();
            if (trade.getCashAdjustmentAmount().compareTo(BigDecimal.ZERO) > 0) {
                // Initiator pays extra - debit from initiator and credit to recipient
                walletService.debitFunds(trade.getInitiatorId(), absAmount,
                        WalletTransaction.TransactionReason.TRADE, tradeId, "Trade cash adjustment - payment to recipient");
                walletService.creditFunds(trade.getRecipientId(), absAmount,
                        WalletTransaction.TransactionReason.TRADE, tradeId, "Trade cash adjustment - received from initiator");
            } else {
                // Recipient pays extra - debit from recipient and credit to initiator
                walletService.debitFunds(trade.getRecipientId(), absAmount,
                        WalletTransaction.TransactionReason.TRADE, tradeId, "Trade cash adjustment - payment to initiator");
                walletService.creditFunds(trade.getInitiatorId(), absAmount,
                        WalletTransaction.TransactionReason.TRADE, tradeId, "Trade cash adjustment - received from recipient");
            }
        }

        // Mark listings as inactive
        requestedListing.setIsActive(false);
        listingRepository.save(requestedListing);

        List<TradeOffering> offerings = tradeOfferingRepository.findByTradeId(tradeId);
        for (TradeOffering offering : offerings) {
            Listing offeringListing = listingRepository.findById(offering.getListingId())
                    .orElseThrow(() -> new ResourceNotFoundException("Offering listing not found"));
            offeringListing.setIsActive(false);
            listingRepository.save(offeringListing);
        }

        // Set status to COMPLETED for rating validation
        trade.setStatus(Trade.TradeStatus.COMPLETED);
        trade.setResolvedAt(LocalDateTime.now());
        trade = tradeRepository.save(trade);

        // Notify both users about trade completion
        User initiator = userRepository.findById(trade.getInitiatorId()).orElse(null);
        User recipient = userRepository.findById(trade.getRecipientId()).orElse(null);
        
        Listing requestedListingForNotification = listingRepository.findById(trade.getRequestedListingId()).orElse(null);
        String listingTitle = requestedListingForNotification != null ? requestedListingForNotification.getTitle() : "listing";
        
        // Send notifications
        if (initiator != null) {
            notificationService.notifyTradeAccepted(initiator.getUserId(), trade.getTradeId(), listingTitle);
            notificationService.notifyTradeCompleted(initiator.getUserId(), trade.getTradeId(), listingTitle);
        }
        if (recipient != null) {
            notificationService.notifyTradeCompleted(recipient.getUserId(), trade.getTradeId(), listingTitle);
        }
        
        String tradeMessage = String.format("✅ Trade Completed!\n\nYour trade has been completed. You can now rate each other to update trust scores.");
        if (trade.getCashAdjustmentAmount() != null && trade.getCashAdjustmentAmount().compareTo(BigDecimal.ZERO) != 0) {
            BigDecimal absAmount = trade.getCashAdjustmentAmount().abs();
            if (trade.getCashAdjustmentAmount().compareTo(BigDecimal.ZERO) > 0) {
                tradeMessage += String.format("\n\nCash adjustment: ₹%s transferred from %s to %s", 
                        absAmount.toPlainString(), 
                        initiator != null ? initiator.getFullName() : "initiator",
                        recipient != null ? recipient.getFullName() : "recipient");
            } else {
                tradeMessage += String.format("\n\nCash adjustment: ₹%s transferred from %s to %s", 
                        absAmount.toPlainString(), 
                        recipient != null ? recipient.getFullName() : "recipient",
                        initiator != null ? initiator.getFullName() : "initiator");
            }
        }
        
        // Notify initiator
        if (initiator != null && recipient != null) {
            chatService.sendMessage(recipient.getUserId(), initiator.getUserId(), tradeMessage, trade.getRequestedListingId());
            // Notify recipient
            chatService.sendMessage(initiator.getUserId(), recipient.getUserId(), tradeMessage, trade.getRequestedListingId());
        }

        return toDTO(trade);
    }

    @Transactional
    public TradeDTO rejectTrade(String userId, String tradeId) {
        Trade trade = tradeRepository.findById(tradeId)
                .orElseThrow(() -> new ResourceNotFoundException("Trade not found"));

        if (!trade.getRecipientId().equals(userId)) {
            throw new BadRequestException("Only the recipient can reject a trade");
        }

        if (trade.getStatus() != Trade.TradeStatus.PENDING) {
            throw new BadRequestException("Trade is not in pending status");
        }

        trade.setStatus(Trade.TradeStatus.REJECTED);
        trade.setResolvedAt(LocalDateTime.now());
        trade = tradeRepository.save(trade);

        // Notify initiator about rejection
        Listing requestedListing = listingRepository.findById(trade.getRequestedListingId()).orElse(null);
        if (requestedListing != null) {
            notificationService.notifyTradeRejected(trade.getInitiatorId(), trade.getTradeId(), requestedListing.getTitle());
        }

        // No funds to release - funds are only transferred on acceptance
        return toDTO(trade);
    }

    @Transactional
    public TradeDTO cancelTrade(String userId, String tradeId) {
        Trade trade = tradeRepository.findById(tradeId)
                .orElseThrow(() -> new ResourceNotFoundException("Trade not found"));

        if (!trade.getInitiatorId().equals(userId)) {
            throw new BadRequestException("Only the initiator can cancel a trade");
        }

        if (trade.getStatus() != Trade.TradeStatus.PENDING) {
            throw new BadRequestException("Only pending trades can be cancelled");
        }

        trade.setStatus(Trade.TradeStatus.CANCELLED);
        trade.setResolvedAt(LocalDateTime.now());
        trade = tradeRepository.save(trade);

        // Notify recipient about cancellation
        Listing requestedListing = listingRepository.findById(trade.getRequestedListingId()).orElse(null);
        if (requestedListing != null) {
            Map<String, Object> metadata = new HashMap<>();
            metadata.put("tradeId", trade.getTradeId());
            metadata.put("listingTitle", requestedListing.getTitle());
            notificationService.createNotification(
                    trade.getRecipientId(),
                    com.tradenbysell.model.Notification.NotificationType.TRADE_CANCELLED,
                    "Trade Cancelled",
                    String.format("The trade proposal for '%s' was cancelled by the initiator.", requestedListing.getTitle()),
                    trade.getTradeId(),
                    com.tradenbysell.model.Notification.RelatedEntityType.TRADE,
                    com.tradenbysell.model.Notification.Priority.MEDIUM,
                    metadata
            );
        }

        // No funds to release - funds are only transferred on acceptance
        return toDTO(trade);
    }

    public List<TradeDTO> getUserTrades(String userId, String status) {
        List<Trade> trades = tradeRepository.findByInitiatorIdOrRecipientIdOrderByCreatedAtDesc(userId, userId);
        
        // Filter by status if provided
        if (status != null && !status.isEmpty()) {
            try {
                Trade.TradeStatus tradeStatus = Trade.TradeStatus.valueOf(status.toUpperCase());
                trades = trades.stream()
                        .filter(t -> t.getStatus() == tradeStatus)
                        .collect(Collectors.toList());
            } catch (IllegalArgumentException e) {
                // Invalid status, return empty list
                return new java.util.ArrayList<>();
            }
        }
        
        return trades.stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public TradeDTO getTradeById(String tradeId) {
        Trade trade = tradeRepository.findById(tradeId)
                .orElseThrow(() -> new ResourceNotFoundException("Trade not found"));
        return toDTO(trade);
    }

    private TradeDTO toDTO(Trade trade) {
        TradeDTO dto = new TradeDTO();
        dto.setTradeId(trade.getTradeId());
        dto.setInitiatorId(trade.getInitiatorId());
        dto.setRecipientId(trade.getRecipientId());
        dto.setRequestedListingId(trade.getRequestedListingId());
        dto.setCashAdjustmentAmount(trade.getCashAdjustmentAmount());
        dto.setStatus(trade.getStatus());
        dto.setCreatedAt(trade.getCreatedAt());
        dto.setResolvedAt(trade.getResolvedAt());

        User initiator = userRepository.findById(trade.getInitiatorId()).orElse(null);
        if (initiator != null) {
            dto.setInitiatorName(initiator.getFullName());
        }

        User recipient = userRepository.findById(trade.getRecipientId()).orElse(null);
        if (recipient != null) {
            dto.setRecipientName(recipient.getFullName());
        }

        Listing requestedListing = listingRepository.findById(trade.getRequestedListingId()).orElse(null);
        if (requestedListing != null) {
            dto.setRequestedListingTitle(requestedListing.getTitle());
            // Get first image URL for requested listing
            List<com.tradenbysell.model.ListingImage> requestedImages = listingImageRepository.findByListingIdOrderByDisplayOrderAsc(requestedListing.getListingId());
            if (requestedImages != null && !requestedImages.isEmpty()) {
                dto.setRequestedListingImageUrl(requestedImages.get(0).getImageUrl());
            }
        }

        List<TradeOffering> offerings = tradeOfferingRepository.findByTradeId(trade.getTradeId());
        dto.setOfferingListingIds(offerings.stream().map(TradeOffering::getListingId).collect(Collectors.toList()));
        dto.setOfferingListingTitles(offerings.stream()
                .map(offering -> listingRepository.findById(offering.getListingId()).orElse(null))
                .filter(listing -> listing != null)
                .map(Listing::getTitle)
                .collect(Collectors.toList()));
        // Get image URLs for offering listings
        dto.setOfferingListingImageUrls(offerings.stream()
                .map(offering -> {
                    List<com.tradenbysell.model.ListingImage> images = listingImageRepository.findByListingIdOrderByDisplayOrderAsc(offering.getListingId());
                    if (images != null && !images.isEmpty()) {
                        return images.get(0).getImageUrl();
                    }
                    return null;
                })
                .collect(Collectors.toList()));

        return dto;
    }
}

