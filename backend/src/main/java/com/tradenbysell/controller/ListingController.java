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
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size) {
        PagedResponse<ListingDTO> response;
        if (search != null && !search.isEmpty()) {
            response = listingService.searchListings(search, page, size);
        } else if (category != null && !category.isEmpty()) {
            response = listingService.getListingsByCategory(category, page, size);
        } else {
            response = listingService.getAllActiveListings(page, size);
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

    @DeleteMapping("/{listingId}")
    public ResponseEntity<Void> deactivateListing(@PathVariable String listingId,
                                                   Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        listingService.deactivateListing(userId, listingId);
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
    public ResponseEntity<Void> addImages(@PathVariable String listingId,
                                         @RequestBody List<String> imageUrls,
                                         Authentication authentication) {
        listingService.addImages(listingId, imageUrls);
        return ResponseEntity.ok().build();
    }
}

