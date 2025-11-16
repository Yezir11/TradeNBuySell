package com.tradenbysell.service;

import com.tradenbysell.dto.FeaturedPackageDTO;
import com.tradenbysell.exception.BadRequestException;
import com.tradenbysell.exception.InsufficientFundsException;
import com.tradenbysell.exception.ResourceNotFoundException;
import com.tradenbysell.model.FeaturedPackage;
import com.tradenbysell.model.Listing;
import com.tradenbysell.model.User;
import com.tradenbysell.model.WalletTransaction;
import com.tradenbysell.repository.FeaturedPackageRepository;
import com.tradenbysell.repository.ListingRepository;
import com.tradenbysell.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class FeaturedListingService {
    @Autowired
    private FeaturedPackageRepository featuredPackageRepository;
    
    @Autowired
    private ListingRepository listingRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private WalletService walletService;
    
    @Autowired(required = false)
    private NotificationService notificationService;
    
    public List<FeaturedPackageDTO> getAvailablePackages() {
        return featuredPackageRepository.findByIsActiveOrderByDisplayOrderAsc(true).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }
    
    @Transactional
    public void featureListing(String userId, String listingId, String packageId) {
        // Verify listing exists and belongs to user
        Listing listing = listingRepository.findById(listingId)
                .orElseThrow(() -> new ResourceNotFoundException("Listing not found"));
        
        if (!listing.getUserId().equals(userId)) {
            throw new BadRequestException("You can only feature your own listings");
        }
        
        if (!listing.getIsActive()) {
            throw new BadRequestException("Cannot feature an inactive listing");
        }
        
        // Get package
        FeaturedPackage featuredPackage = featuredPackageRepository.findByPackageIdAndIsActive(packageId, true)
                .orElseThrow(() -> new ResourceNotFoundException("Featured package not found"));
        
        // Check wallet balance
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        
        if (user.getWalletBalance().compareTo(featuredPackage.getPrice()) < 0) {
            throw new InsufficientFundsException("Insufficient wallet balance. Required: ₹" + 
                    featuredPackage.getPrice() + ", Available: ₹" + user.getWalletBalance());
        }
        
        // Calculate featured until date
        LocalDateTime featuredUntil = LocalDateTime.now().plusDays(featuredPackage.getDurationDays());
        
        // If listing is already featured and not expired, extend the duration
        if (listing.getIsFeatured() != null && listing.getIsFeatured() && 
            listing.getFeaturedUntil() != null && listing.getFeaturedUntil().isAfter(LocalDateTime.now())) {
            // Extend from current featuredUntil date
            featuredUntil = listing.getFeaturedUntil().plusDays(featuredPackage.getDurationDays());
        }
        
        // Deduct from wallet
        walletService.debitFunds(
            userId,
            featuredPackage.getPrice(),
            WalletTransaction.TransactionReason.FEATURED_LISTING,
            listingId,
            "Featured listing - " + featuredPackage.getPackageName() + " (" + featuredPackage.getDurationDays() + " days)"
        );
        
        // Update listing
        listing.setIsFeatured(true);
        listing.setFeaturedUntil(featuredUntil);
        listing.setFeaturedType(featuredPackage.getPackageId());
        listingRepository.save(listing);
        
        // Notify user about featured listing
        if (notificationService != null) {
            notificationService.notifyListingFeatured(userId, listingId, listing.getTitle(), featuredPackage.getDurationDays());
        }
    }
    
    @Transactional
    public void updateFeaturedStatus() {
        // This method should be called periodically (e.g., via scheduled task)
        // to deactivate expired featured listings
        List<Listing> expiredFeaturedListings = listingRepository.findAll().stream()
                .filter(l -> l.getIsFeatured() != null && l.getIsFeatured() &&
                           l.getFeaturedUntil() != null && l.getFeaturedUntil().isBefore(LocalDateTime.now()))
                .collect(Collectors.toList());
        
        for (Listing listing : expiredFeaturedListings) {
            listing.setIsFeatured(false);
            listing.setFeaturedUntil(null);
            listing.setFeaturedType(null);
            listingRepository.save(listing);
        }
    }
    
    private FeaturedPackageDTO toDTO(FeaturedPackage pkg) {
        FeaturedPackageDTO dto = new FeaturedPackageDTO();
        dto.setPackageId(pkg.getPackageId());
        dto.setPackageName(pkg.getPackageName());
        dto.setDurationDays(pkg.getDurationDays());
        dto.setPrice(pkg.getPrice());
        dto.setDescription(pkg.getDescription());
        return dto;
    }
}

