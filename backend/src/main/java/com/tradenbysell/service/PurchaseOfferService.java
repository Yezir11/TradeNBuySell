package com.tradenbysell.service;

import com.tradenbysell.dto.PurchaseOfferDTO;
import com.tradenbysell.exception.BadRequestException;
import com.tradenbysell.exception.InsufficientFundsException;
import com.tradenbysell.exception.ResourceNotFoundException;
import com.tradenbysell.model.Listing;
import com.tradenbysell.model.ListingImage;
import com.tradenbysell.model.PurchaseOffer;
import com.tradenbysell.model.User;
import com.tradenbysell.repository.ListingImageRepository;
import com.tradenbysell.repository.ListingRepository;
import com.tradenbysell.repository.PurchaseOfferRepository;
import com.tradenbysell.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class PurchaseOfferService {
    
    @Autowired
    private PurchaseOfferRepository purchaseOfferRepository;
    
    @Autowired
    private ListingRepository listingRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private ListingImageRepository listingImageRepository;
    
    @Autowired
    private ChatService chatService;
    
    @Autowired
    private WalletService walletService;
    
    @Transactional
    public PurchaseOfferDTO createOffer(String buyerId, String listingId, BigDecimal offerAmount, String message) {
        // Validate listing
        Listing listing = listingRepository.findById(listingId)
                .orElseThrow(() -> new ResourceNotFoundException("Listing not found"));
        
        if (!listing.getIsActive()) {
            throw new BadRequestException("Listing is not active");
        }
        
        if (listing.getIsBiddable()) {
            throw new BadRequestException("Cannot make purchase offer on biddable listing. Please place a bid instead.");
        }
        
        if (listing.getPrice() == null || listing.getPrice().compareTo(BigDecimal.ZERO) <= 0) {
            throw new BadRequestException("Listing does not have a price. This listing is trade-only.");
        }
        
        if (listing.getUserId().equals(buyerId)) {
            throw new BadRequestException("Cannot make offer on your own listing");
        }
        
        // Validate buyer
        User buyer = userRepository.findById(buyerId)
                .orElseThrow(() -> new ResourceNotFoundException("Buyer not found"));
        
        // Validate seller
        User seller = userRepository.findById(listing.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Seller not found"));
        
        // Validate offer amount
        if (offerAmount == null || offerAmount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new BadRequestException("Offer amount must be greater than zero");
        }
        
        // Check for existing pending offer from same buyer
        purchaseOfferRepository.findPendingOfferByListingAndBuyer(listingId, buyerId)
                .ifPresent(existing -> {
                    throw new BadRequestException("You already have a pending offer on this listing");
                });
        
        // Create offer
        PurchaseOffer offer = new PurchaseOffer();
        offer.setListingId(listingId);
        offer.setBuyerId(buyerId);
        offer.setSellerId(listing.getUserId());
        offer.setOfferAmount(offerAmount);
        offer.setOriginalListingPrice(listing.getPrice());
        offer.setMessage(message);
        offer.setStatus(PurchaseOffer.OfferStatus.PENDING);
        
        offer = purchaseOfferRepository.save(offer);
        
        // Send message in chat
        String offerMessage = String.format("💰 Purchase Offer: ₹%s for \"%s\"\n\nOriginal Price: ₹%s\n\n%s", 
                offerAmount.toPlainString(), 
                listing.getTitle(),
                listing.getPrice().toPlainString(),
                message != null && !message.trim().isEmpty() ? "Message: " + message : "");
        
        chatService.sendOfferMessage(buyerId, listing.getUserId(), listingId, offer.getOfferId(), offerMessage);
        
        return toDTO(offer, listing, buyer, seller);
    }
    
    @Transactional
    public PurchaseOfferDTO acceptOffer(String sellerId, String offerId) {
        PurchaseOffer offer = purchaseOfferRepository.findById(offerId)
                .orElseThrow(() -> new ResourceNotFoundException("Offer not found"));
        
        if (!offer.getSellerId().equals(sellerId)) {
            throw new BadRequestException("Only the seller can accept this offer");
        }
        
        if (offer.getStatus() != PurchaseOffer.OfferStatus.PENDING && 
            offer.getStatus() != PurchaseOffer.OfferStatus.COUNTERED) {
            throw new BadRequestException("Offer is not in a valid state to be accepted");
        }
        
        // Check listing is still active
        Listing listing = listingRepository.findById(offer.getListingId())
                .orElseThrow(() -> new ResourceNotFoundException("Listing not found"));
        
        if (!listing.getIsActive()) {
            throw new BadRequestException("Listing is no longer active");
        }
        
        // Check buyer has sufficient funds
        BigDecimal finalAmount = offer.getCounterOfferAmount() != null ? 
                offer.getCounterOfferAmount() : offer.getOfferAmount();
        
        BigDecimal buyerBalance = walletService.getBalance(offer.getBuyerId());
        if (buyerBalance.compareTo(finalAmount) < 0) {
            throw new InsufficientFundsException("Buyer has insufficient funds");
        }
        
        // Transfer funds immediately on acceptance (no escrow)
        walletService.debitFunds(offer.getBuyerId(), finalAmount,
                com.tradenbysell.model.WalletTransaction.TransactionReason.PURCHASE, 
                offerId, String.format("Purchase of listing: %s", listing.getTitle()));
        walletService.creditFunds(offer.getSellerId(), finalAmount,
                com.tradenbysell.model.WalletTransaction.TransactionReason.SALE, 
                offerId, String.format("Sale of listing: %s", listing.getTitle()));
        
        // Update offer
        offer.setStatus(PurchaseOffer.OfferStatus.ACCEPTED);
        offer.setAcceptedAt(LocalDateTime.now());
        offer = purchaseOfferRepository.save(offer);
        
        // Mark listing as reserved/sold
        listing.setIsActive(false);
        listingRepository.save(listing);
        
        // Notify both users about purchase completion
        User buyer = userRepository.findById(offer.getBuyerId()).orElse(null);
        User seller = userRepository.findById(offer.getSellerId()).orElse(null);
        
        String acceptMessage = String.format("✅ Purchase Completed!\n\nYour offer of ₹%s has been accepted. Payment of ₹%s has been transferred. You can now rate each other to update trust scores.", 
                finalAmount.toPlainString(), finalAmount.toPlainString());
        chatService.sendOfferStatusMessage(offer.getSellerId(), offer.getBuyerId(), offer.getListingId(), 
                offer.getOfferId(), "OFFER_ACCEPTED", acceptMessage);
        
        // Also send notification to seller
        String sellerMessage = String.format("✅ Sale Completed!\n\nYou accepted the offer of ₹%s. Payment of ₹%s has been received. You can now rate the buyer to update trust scores.", 
                finalAmount.toPlainString(), finalAmount.toPlainString());
        chatService.sendOfferStatusMessage(offer.getBuyerId(), offer.getSellerId(), offer.getListingId(), 
                offer.getOfferId(), "OFFER_ACCEPTED", sellerMessage);
        
        return toDTO(offer, listing, buyer, seller);
    }
    
    @Transactional
    public PurchaseOfferDTO acceptCounterOfferByBuyer(String buyerId, String offerId) {
        PurchaseOffer offer = purchaseOfferRepository.findById(offerId)
                .orElseThrow(() -> new ResourceNotFoundException("Offer not found"));
        
        if (!offer.getBuyerId().equals(buyerId)) {
            throw new BadRequestException("Only the buyer can accept their own counter offer");
        }
        
        if (offer.getStatus() != PurchaseOffer.OfferStatus.COUNTERED) {
            throw new BadRequestException("Offer is not in countered status");
        }
        
        if (offer.getCounterOfferAmount() == null) {
            throw new BadRequestException("No counter offer amount available");
        }
        
        // Check listing is still active
        Listing listing = listingRepository.findById(offer.getListingId())
                .orElseThrow(() -> new ResourceNotFoundException("Listing not found"));
        
        if (!listing.getIsActive()) {
            throw new BadRequestException("Listing is no longer active");
        }
        
        // Check buyer has sufficient funds for the counter offer amount
        BigDecimal finalAmount = offer.getCounterOfferAmount();
        
        BigDecimal buyerBalance = walletService.getBalance(buyerId);
        if (buyerBalance.compareTo(finalAmount) < 0) {
            throw new InsufficientFundsException("You have insufficient funds for this counter offer");
        }
        
        // Transfer funds immediately on acceptance (no escrow) - direct transfer
        walletService.debitFunds(buyerId, finalAmount,
                com.tradenbysell.model.WalletTransaction.TransactionReason.PURCHASE, 
                offerId, String.format("Purchase of listing: %s (counter offer accepted)", listing.getTitle()));
        walletService.creditFunds(offer.getSellerId(), finalAmount,
                com.tradenbysell.model.WalletTransaction.TransactionReason.SALE, 
                offerId, String.format("Sale of listing: %s (counter offer accepted)", listing.getTitle()));
        
        // Update offer
        offer.setStatus(PurchaseOffer.OfferStatus.ACCEPTED);
        offer.setAcceptedAt(LocalDateTime.now());
        offer = purchaseOfferRepository.save(offer);
        
        // Mark listing as reserved/sold
        listing.setIsActive(false);
        listingRepository.save(listing);
        
        // Notify both users about purchase completion
        User buyer = userRepository.findById(buyerId).orElse(null);
        User seller = userRepository.findById(offer.getSellerId()).orElse(null);
        
        String acceptMessage = String.format("✅ Purchase Completed!\n\nYou accepted the counter offer of ₹%s. Payment of ₹%s has been transferred directly. You can now rate each other to update trust scores.", 
                finalAmount.toPlainString(), finalAmount.toPlainString());
        chatService.sendOfferStatusMessage(offer.getSellerId(), buyerId, offer.getListingId(), 
                offer.getOfferId(), "OFFER_ACCEPTED", acceptMessage);
        
        // Also send notification to seller
        String sellerMessage = String.format("✅ Sale Completed!\n\nThe buyer accepted your counter offer of ₹%s. Payment of ₹%s has been received directly. You can now rate the buyer to update trust scores.", 
                finalAmount.toPlainString(), finalAmount.toPlainString());
        chatService.sendOfferStatusMessage(buyerId, offer.getSellerId(), offer.getListingId(), 
                offer.getOfferId(), "OFFER_ACCEPTED", sellerMessage);
        
        return toDTO(offer, listing, buyer, seller);
    }
    
    @Transactional
    public PurchaseOfferDTO counterOffer(String sellerId, String offerId, BigDecimal counterAmount, String message) {
        PurchaseOffer offer = purchaseOfferRepository.findById(offerId)
                .orElseThrow(() -> new ResourceNotFoundException("Offer not found"));
        
        if (!offer.getSellerId().equals(sellerId)) {
            throw new BadRequestException("Only the seller can counter this offer");
        }
        
        if (offer.getStatus() != PurchaseOffer.OfferStatus.PENDING && 
            offer.getStatus() != PurchaseOffer.OfferStatus.COUNTERED) {
            throw new BadRequestException("Offer is not in a valid state to be countered");
        }
        
        if (counterAmount == null || counterAmount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new BadRequestException("Counter offer amount must be greater than zero");
        }
        
        // Update offer
        offer.setCounterOfferAmount(counterAmount);
        offer.setStatus(PurchaseOffer.OfferStatus.COUNTERED);
        offer = purchaseOfferRepository.save(offer);
        
        // Send counter offer message
        String counterMessage = String.format("💬 Counter Offer: ₹%s\n\nOriginal Offer: ₹%s\nOriginal Listing Price: ₹%s\n\n%s", 
                counterAmount.toPlainString(),
                offer.getOfferAmount().toPlainString(),
                offer.getOriginalListingPrice().toPlainString(),
                message != null && !message.trim().isEmpty() ? "Message: " + message : "");
        chatService.sendOfferStatusMessage(offer.getSellerId(), offer.getBuyerId(), offer.getListingId(), 
                offer.getOfferId(), "OFFER_COUNTERED", counterMessage);
        
        Listing listing = listingRepository.findById(offer.getListingId()).orElse(null);
        User buyer = userRepository.findById(offer.getBuyerId()).orElse(null);
        User seller = userRepository.findById(offer.getSellerId()).orElse(null);
        
        return toDTO(offer, listing, buyer, seller);
    }
    
    @Transactional
    public PurchaseOfferDTO rejectOffer(String sellerId, String offerId) {
        PurchaseOffer offer = purchaseOfferRepository.findById(offerId)
                .orElseThrow(() -> new ResourceNotFoundException("Offer not found"));
        
        if (!offer.getSellerId().equals(sellerId)) {
            throw new BadRequestException("Only the seller can reject this offer");
        }
        
        if (offer.getStatus() != PurchaseOffer.OfferStatus.PENDING && 
            offer.getStatus() != PurchaseOffer.OfferStatus.COUNTERED) {
            throw new BadRequestException("Offer is not in a valid state to be rejected");
        }
        
        // Update offer
        offer.setStatus(PurchaseOffer.OfferStatus.REJECTED);
        offer = purchaseOfferRepository.save(offer);
        
        // Send rejection message
        String rejectMessage = "❌ Offer Rejected\n\nThe seller has declined your offer.";
        chatService.sendOfferStatusMessage(offer.getSellerId(), offer.getBuyerId(), offer.getListingId(), 
                offer.getOfferId(), "OFFER_REJECTED", rejectMessage);
        
        Listing listing = listingRepository.findById(offer.getListingId()).orElse(null);
        User buyer = userRepository.findById(offer.getBuyerId()).orElse(null);
        User seller = userRepository.findById(offer.getSellerId()).orElse(null);
        
        return toDTO(offer, listing, buyer, seller);
    }
    
    @Transactional
    public void cancelOffer(String buyerId, String offerId) {
        PurchaseOffer offer = purchaseOfferRepository.findById(offerId)
                .orElseThrow(() -> new ResourceNotFoundException("Offer not found"));
        
        if (!offer.getBuyerId().equals(buyerId)) {
            throw new BadRequestException("Only the buyer can cancel this offer");
        }
        
        if (offer.getStatus() != PurchaseOffer.OfferStatus.PENDING && 
            offer.getStatus() != PurchaseOffer.OfferStatus.COUNTERED) {
            throw new BadRequestException("Offer cannot be cancelled in its current state");
        }
        
        offer.setStatus(PurchaseOffer.OfferStatus.CANCELLED);
        purchaseOfferRepository.save(offer);
    }
    
    public List<PurchaseOfferDTO> getOffersByListing(String listingId) {
        List<PurchaseOffer> offers = purchaseOfferRepository.findByListingIdOrderByCreatedAtDesc(listingId);
        return offers.stream()
                .map(offer -> {
                    Listing listing = listingRepository.findById(offer.getListingId()).orElse(null);
                    User buyer = userRepository.findById(offer.getBuyerId()).orElse(null);
                    User seller = userRepository.findById(offer.getSellerId()).orElse(null);
                    return toDTO(offer, listing, buyer, seller);
                })
                .collect(Collectors.toList());
    }
    
    public List<PurchaseOfferDTO> getBuyerOffers(String buyerId) {
        List<PurchaseOffer> offers = purchaseOfferRepository.findByBuyerIdOrderByCreatedAtDesc(buyerId);
        return offers.stream()
                .map(offer -> {
                    Listing listing = listingRepository.findById(offer.getListingId()).orElse(null);
                    User buyer = userRepository.findById(offer.getBuyerId()).orElse(null);
                    User seller = userRepository.findById(offer.getSellerId()).orElse(null);
                    return toDTO(offer, listing, buyer, seller);
                })
                .collect(Collectors.toList());
    }
    
    public List<PurchaseOfferDTO> getSellerOffers(String sellerId) {
        List<PurchaseOffer> offers = purchaseOfferRepository.findBySellerIdOrderByCreatedAtDesc(sellerId);
        return offers.stream()
                .map(offer -> {
                    Listing listing = listingRepository.findById(offer.getListingId()).orElse(null);
                    User buyer = userRepository.findById(offer.getBuyerId()).orElse(null);
                    User seller = userRepository.findById(offer.getSellerId()).orElse(null);
                    return toDTO(offer, listing, buyer, seller);
                })
                .collect(Collectors.toList());
    }
    
    public PurchaseOfferDTO getOfferById(String offerId) {
        PurchaseOffer offer = purchaseOfferRepository.findById(offerId)
                .orElseThrow(() -> new ResourceNotFoundException("Offer not found"));
        
        Listing listing = listingRepository.findById(offer.getListingId()).orElse(null);
        User buyer = userRepository.findById(offer.getBuyerId()).orElse(null);
        User seller = userRepository.findById(offer.getSellerId()).orElse(null);
        
        return toDTO(offer, listing, buyer, seller);
    }
    
    private PurchaseOfferDTO toDTO(PurchaseOffer offer, Listing listing, User buyer, User seller) {
        PurchaseOfferDTO dto = new PurchaseOfferDTO();
        dto.setOfferId(offer.getOfferId());
        dto.setListingId(offer.getListingId());
        dto.setBuyerId(offer.getBuyerId());
        dto.setBuyerName(buyer != null ? buyer.getFullName() : null);
        dto.setSellerId(offer.getSellerId());
        dto.setSellerName(seller != null ? seller.getFullName() : null);
        dto.setOfferAmount(offer.getOfferAmount());
        dto.setOriginalListingPrice(offer.getOriginalListingPrice());
        dto.setCounterOfferAmount(offer.getCounterOfferAmount());
        dto.setMessage(offer.getMessage());
        dto.setStatus(offer.getStatus());
        dto.setCreatedAt(offer.getCreatedAt());
        dto.setUpdatedAt(offer.getUpdatedAt());
        dto.setAcceptedAt(offer.getAcceptedAt());
        
        if (listing != null) {
            dto.setListingTitle(listing.getTitle());
            List<ListingImage> images = listingImageRepository.findByListingIdOrderByDisplayOrderAsc(listing.getListingId());
            if (!images.isEmpty()) {
                dto.setListingImageUrl(images.get(0).getImageUrl());
            }
        }
        
        return dto;
    }
}

