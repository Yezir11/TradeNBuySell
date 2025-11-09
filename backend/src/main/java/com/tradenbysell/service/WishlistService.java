package com.tradenbysell.service;

import com.tradenbysell.dto.ListingDTO;
import com.tradenbysell.exception.BadRequestException;
import com.tradenbysell.exception.ResourceNotFoundException;
import com.tradenbysell.model.Listing;
import com.tradenbysell.model.Wishlist;
import com.tradenbysell.repository.ListingRepository;
import com.tradenbysell.repository.WishlistRepository;
import com.tradenbysell.service.ListingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class WishlistService {
    @Autowired
    private WishlistRepository wishlistRepository;

    @Autowired
    private ListingRepository listingRepository;

    @Autowired
    private ListingService listingService;

    @Transactional
    public void addToWishlist(String userId, String listingId) {
        Listing listing = listingRepository.findById(listingId)
                .orElseThrow(() -> new ResourceNotFoundException("Listing not found"));

        if (listing.getUserId().equals(userId)) {
            throw new BadRequestException("Cannot add your own listing to wishlist");
        }

        if (wishlistRepository.existsByUserIdAndListingId(userId, listingId)) {
            throw new BadRequestException("Listing already in wishlist");
        }

        Wishlist wishlist = new Wishlist();
        wishlist.setUserId(userId);
        wishlist.setListingId(listingId);
        wishlistRepository.save(wishlist);
    }

    @Transactional
    public void removeFromWishlist(String userId, String listingId) {
        if (!wishlistRepository.existsByUserIdAndListingId(userId, listingId)) {
            throw new ResourceNotFoundException("Listing not found in wishlist");
        }

        wishlistRepository.deleteByUserIdAndListingId(userId, listingId);
    }

    public List<ListingDTO> getUserWishlist(String userId) {
        return wishlistRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(wishlist -> listingService.getListingById(wishlist.getListingId()))
                .collect(Collectors.toList());
    }

    public boolean isInWishlist(String userId, String listingId) {
        return wishlistRepository.existsByUserIdAndListingId(userId, listingId);
    }
}

