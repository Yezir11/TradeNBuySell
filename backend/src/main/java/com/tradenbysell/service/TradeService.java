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
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
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

        User recipient = userRepository.findById(requestedListing.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Recipient not found"));

        if (recipient.getTrustScore() == null || recipient.getTrustScore() < 3.0f) {
            throw new BadRequestException("Recipient does not meet trust score requirements (minimum 3.0)");
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

        // Hold funds based on cash adjustment direction
        if (cashAdjustmentAmount != null && cashAdjustmentAmount.compareTo(BigDecimal.ZERO) != 0) {
            BigDecimal absAmount = cashAdjustmentAmount.abs();
            if (cashAdjustmentAmount.compareTo(BigDecimal.ZERO) > 0) {
                // Initiator pays extra - hold from initiator
                walletService.holdFunds(initiatorId, absAmount, trade.getTradeId());
            } else {
                // Recipient pays extra - hold from recipient
                walletService.holdFunds(requestedListing.getUserId(), absAmount, trade.getTradeId());
            }
        }

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

        trade.setStatus(Trade.TradeStatus.ACCEPTED);
        trade.setResolvedAt(LocalDateTime.now());
        trade = tradeRepository.save(trade);

        requestedListing.setIsActive(false);
        listingRepository.save(requestedListing);

        List<TradeOffering> offerings = tradeOfferingRepository.findByTradeId(tradeId);
        for (TradeOffering offering : offerings) {
            Listing offeringListing = listingRepository.findById(offering.getListingId())
                    .orElseThrow(() -> new ResourceNotFoundException("Offering listing not found"));
            offeringListing.setIsActive(false);
            listingRepository.save(offeringListing);
        }

        // Handle cash adjustment transfer on trade acceptance
        if (trade.getCashAdjustmentAmount() != null && trade.getCashAdjustmentAmount().compareTo(BigDecimal.ZERO) != 0) {
            BigDecimal absAmount = trade.getCashAdjustmentAmount().abs();
            if (trade.getCashAdjustmentAmount().compareTo(BigDecimal.ZERO) > 0) {
                // Initiator pays extra - release from initiator and credit to recipient
                walletService.releaseFunds(trade.getInitiatorId(), absAmount, tradeId);
                walletService.creditFunds(trade.getRecipientId(), absAmount,
                        WalletTransaction.TransactionReason.TRADE, tradeId, "Trade cash adjustment - received from initiator");
            } else {
                // Recipient pays extra - release from recipient and credit to initiator
                walletService.releaseFunds(trade.getRecipientId(), absAmount, tradeId);
                walletService.creditFunds(trade.getInitiatorId(), absAmount,
                        WalletTransaction.TransactionReason.TRADE, tradeId, "Trade cash adjustment - received from recipient");
            }
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

        // Release held funds on trade rejection
        if (trade.getCashAdjustmentAmount() != null && trade.getCashAdjustmentAmount().compareTo(BigDecimal.ZERO) != 0) {
            BigDecimal absAmount = trade.getCashAdjustmentAmount().abs();
            if (trade.getCashAdjustmentAmount().compareTo(BigDecimal.ZERO) > 0) {
                // Release from initiator
                walletService.releaseFunds(trade.getInitiatorId(), absAmount, tradeId);
            } else {
                // Release from recipient
                walletService.releaseFunds(trade.getRecipientId(), absAmount, tradeId);
            }
        }

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

        // Release held funds on trade rejection
        if (trade.getCashAdjustmentAmount() != null && trade.getCashAdjustmentAmount().compareTo(BigDecimal.ZERO) != 0) {
            BigDecimal absAmount = trade.getCashAdjustmentAmount().abs();
            if (trade.getCashAdjustmentAmount().compareTo(BigDecimal.ZERO) > 0) {
                // Release from initiator
                walletService.releaseFunds(trade.getInitiatorId(), absAmount, tradeId);
            } else {
                // Release from recipient
                walletService.releaseFunds(trade.getRecipientId(), absAmount, tradeId);
            }
        }

        return toDTO(trade);
    }

    public List<TradeDTO> getUserTrades(String userId) {
        return tradeRepository.findByInitiatorIdOrRecipientIdOrderByCreatedAtDesc(userId, userId).stream()
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
        }

        List<TradeOffering> offerings = tradeOfferingRepository.findByTradeId(trade.getTradeId());
        dto.setOfferingListingIds(offerings.stream().map(TradeOffering::getListingId).collect(Collectors.toList()));
        dto.setOfferingListingTitles(offerings.stream()
                .map(offering -> listingRepository.findById(offering.getListingId()).orElse(null))
                .filter(listing -> listing != null)
                .map(Listing::getTitle)
                .collect(Collectors.toList()));

        return dto;
    }
}

