package com.tradenbysell.controller;

import com.tradenbysell.dto.ListingCreateDTO;
import com.tradenbysell.dto.ListingDTO;
import com.tradenbysell.dto.PagedResponse;
import com.tradenbysell.service.ListingService;
import com.tradenbysell.util.AuthUtil;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/listings")
@CrossOrigin(origins = "*")
public class ListingController {
    @Autowired
    private ListingService listingService;

    @Autowired
    private AuthUtil authUtil;

    @GetMapping
    public ResponseEntity<PagedResponse<ListingDTO>> getAllListings(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) Boolean biddableOnly,
            @RequestParam(required = false) Boolean nonBiddableOnly,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size) {
        PagedResponse<ListingDTO> response;
        
        // If explicitly requesting biddable listings (for bidding center)
        if (biddableOnly != null && biddableOnly) {
            response = listingService.getBiddableListings(page, size);
        }
        // If explicitly requesting non-biddable listings (for marketplace)
        else if (nonBiddableOnly != null && nonBiddableOnly) {
            if (search != null && !search.isEmpty()) {
                response = listingService.searchNonBiddableListings(search, page, size);
            } else if (category != null && !category.isEmpty()) {
                response = listingService.getNonBiddableListingsByCategory(category, page, size);
            } else {
                response = listingService.getNonBiddableListings(page, size);
            }
        }
        // Default behavior - return all listings (for backward compatibility)
        else {
            if (search != null && !search.isEmpty()) {
                response = listingService.searchListings(search, page, size);
            } else if (category != null && !category.isEmpty()) {
                response = listingService.getListingsByCategory(category, page, size);
            } else {
                response = listingService.getAllActiveListings(page, size);
            }
        }
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{listingId}")
    public ResponseEntity<ListingDTO> getListingById(@PathVariable String listingId) {
        ListingDTO listing = listingService.getListingById(listingId);
        return ResponseEntity.ok(listing);
    }

    @PostMapping
    public ResponseEntity<ListingDTO> createListing(@Valid @RequestBody ListingCreateDTO createDTO,
                                                     Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        ListingDTO listing = listingService.createListing(userId, createDTO);
        return ResponseEntity.ok(listing);
    }

    @PutMapping("/{listingId}")
    public ResponseEntity<ListingDTO> updateListing(@PathVariable String listingId,
                                                      @Valid @RequestBody ListingCreateDTO updateDTO,
                                                      Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        ListingDTO listing = listingService.updateListing(userId, listingId, updateDTO);
        return ResponseEntity.ok(listing);
    }

    @PostMapping("/{listingId}/edit")
    public ResponseEntity<ListingDTO> editListingAsNew(@PathVariable String listingId,
                                                         @Valid @RequestBody ListingCreateDTO editDTO,
                                                         Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        ListingDTO newListing = listingService.editListingAsNew(userId, listingId, editDTO);
        return ResponseEntity.ok(newListing);
    }

    @DeleteMapping("/{listingId}")
    public ResponseEntity<Void> deactivateListing(@PathVariable String listingId,
                                                   @RequestParam(required = false, defaultValue = "false") Boolean permanent,
                                                   Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        if (permanent != null && permanent) {
            // Permanently delete the listing
            listingService.deleteListing(userId, listingId);
        } else {
            // Deactivate (set isActive = false)
            listingService.deactivateListing(userId, listingId);
        }
        return ResponseEntity.ok().build();
    }

    @GetMapping("/my-listings")
    public ResponseEntity<List<ListingDTO>> getMyListings(@RequestParam(required = false) Boolean activeOnly,
                                                           Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        List<ListingDTO> listings = listingService.getUserListings(userId, activeOnly);
        return ResponseEntity.ok(listings);
    }

    @PostMapping("/{listingId}/images")
    public ResponseEntity<Map<String, Object>> addImages(@PathVariable String listingId,
                                         @RequestBody List<String> imageUrls,
                                         Authentication authentication) {
        // Validate: At least one image is required
        if (imageUrls == null || imageUrls.isEmpty()) {
            throw new com.tradenbysell.exception.BadRequestException("At least one image is required");
        }
        
        listingService.addImages(listingId, imageUrls, authentication);
        
        // Get listing to check if it was flagged
        com.tradenbysell.dto.ListingDTO listing = listingService.getListingById(listingId);
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("message", "Images added successfully");
        response.put("listingActive", listing.getIsActive());
        
        if (!listing.getIsActive()) {
            response.put("warning", "Listing was flagged by ML moderation and is pending admin review");
        }
        
        return ResponseEntity.ok(response);
    }
}

