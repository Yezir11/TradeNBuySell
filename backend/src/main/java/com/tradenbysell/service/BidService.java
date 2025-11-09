package com.tradenbysell.service;

import com.tradenbysell.dto.BidDTO;
import com.tradenbysell.exception.BadRequestException;
import com.tradenbysell.exception.InsufficientFundsException;
import com.tradenbysell.exception.ResourceNotFoundException;
import com.tradenbysell.model.Bid;
import com.tradenbysell.model.Listing;
import com.tradenbysell.model.User;
import com.tradenbysell.repository.BidRepository;
import com.tradenbysell.repository.ListingRepository;
import com.tradenbysell.repository.UserRepository;
import com.tradenbysell.service.WalletService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class BidService {
    @Autowired
    private BidRepository bidRepository;

    @Autowired
    private ListingRepository listingRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private WalletService walletService;

    @Transactional
    public BidDTO placeBid(String userId, String listingId, BigDecimal bidAmount) {
        Listing listing = listingRepository.findById(listingId)
                .orElseThrow(() -> new ResourceNotFoundException("Listing not found"));

        if (!listing.getIsBiddable()) {
            throw new BadRequestException("Listing is not biddable");
        }

        if (!listing.getIsActive()) {
            throw new BadRequestException("Listing is not active");
        }

        if (listing.getUserId().equals(userId)) {
            throw new BadRequestException("Cannot bid on your own listing");
        }

        LocalDateTime now = LocalDateTime.now();
        if (listing.getBidStartTime() != null && now.isBefore(listing.getBidStartTime())) {
            throw new BadRequestException("Bidding has not started yet");
        }

        if (listing.getBidEndTime() != null && now.isAfter(listing.getBidEndTime())) {
            throw new BadRequestException("Bidding has ended");
        }

        Bid highestBid = bidRepository.findTopByListingIdOrderByBidAmountDescBidTimeAsc(listingId).orElse(null);
        BigDecimal minBid;

        if (highestBid != null) {
            if (bidAmount.compareTo(highestBid.getBidAmount()) <= 0) {
                throw new BadRequestException("Bid amount must be higher than current highest bid");
            }
            minBid = highestBid.getBidAmount();
        } else {
            if (listing.getStartingPrice() == null) {
                throw new BadRequestException("Listing has no starting price");
            }
            minBid = listing.getStartingPrice();
            if (bidAmount.compareTo(minBid) < 0) {
                throw new BadRequestException("Bid amount must be at least the starting price");
            }
        }

        if (listing.getBidIncrement() != null && highestBid != null) {
            BigDecimal requiredMinBid = highestBid.getBidAmount().add(listing.getBidIncrement());
            if (bidAmount.compareTo(requiredMinBid) < 0) {
                throw new BadRequestException("Bid amount must be at least " + requiredMinBid + " (current highest + increment)");
            }
        }

        BigDecimal balance = walletService.getBalance(userId);
        if (balance.compareTo(bidAmount) < 0) {
            throw new InsufficientFundsException("Insufficient wallet balance");
        }

        walletService.holdFunds(userId, bidAmount, listingId);

        if (highestBid != null) {
            highestBid.setIsWinning(false);
            bidRepository.save(highestBid);
            walletService.releaseFunds(highestBid.getUserId(), highestBid.getBidAmount(), listingId);
        }

        Bid bid = new Bid();
        bid.setListingId(listingId);
        bid.setUserId(userId);
        bid.setBidAmount(bidAmount);
        bid.setIsWinning(true);
        bid = bidRepository.save(bid);

        return toDTO(bid);
    }

    public List<BidDTO> getListingBids(String listingId) {
        return bidRepository.findByListingIdOrderByBidAmountDescBidTimeAsc(listingId).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public List<BidDTO> getUserBids(String userId) {
        return bidRepository.findByUserIdOrderByBidTimeDesc(userId).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public BidDTO finalizeWinningBid(String listingId) {
        Listing listing = listingRepository.findById(listingId)
                .orElseThrow(() -> new ResourceNotFoundException("Listing not found"));

        Bid winningBid = bidRepository.findTopByListingIdOrderByBidAmountDescBidTimeAsc(listingId)
                .orElseThrow(() -> new BadRequestException("No bids found for this listing"));

        winningBid.setIsWinning(true);
        winningBid = bidRepository.save(winningBid);

        listing.setIsActive(false);
        listingRepository.save(listing);

        walletService.debitFunds(winningBid.getUserId(), winningBid.getBidAmount(),
                com.tradenbysell.model.WalletTransaction.TransactionReason.BID, listingId, "Winning bid payment");

        walletService.creditFunds(listing.getUserId(), winningBid.getBidAmount(),
                com.tradenbysell.model.WalletTransaction.TransactionReason.BID, listingId, "Bid payment received");

        return toDTO(winningBid);
    }

    private BidDTO toDTO(Bid bid) {
        BidDTO dto = new BidDTO();
        dto.setBidId(bid.getBidId());
        dto.setListingId(bid.getListingId());
        dto.setUserId(bid.getUserId());
        dto.setBidAmount(bid.getBidAmount());
        dto.setBidTime(bid.getBidTime());
        dto.setIsWinning(bid.getIsWinning());

        User user = userRepository.findById(bid.getUserId()).orElse(null);
        if (user != null) {
            dto.setUserName(user.getFullName());
        }

        Listing listing = listingRepository.findById(bid.getListingId()).orElse(null);
        if (listing != null) {
            dto.setListingTitle(listing.getTitle());
        }

        return dto;
    }
}

