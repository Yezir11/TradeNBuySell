package com.tradenbysell.controller;

import com.tradenbysell.dto.ListingDTO;
import com.tradenbysell.service.WishlistService;
import com.tradenbysell.util.AuthUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/wishlist")
@CrossOrigin(origins = "*")
public class WishlistController {

    @Autowired
    private AuthUtil authUtil;
    @Autowired
    private WishlistService wishlistService;

    @PostMapping("/{listingId}")
    public ResponseEntity<Void> addToWishlist(@PathVariable String listingId,
                                              Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        wishlistService.addToWishlist(userId, listingId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{listingId}")
    public ResponseEntity<Void> removeFromWishlist(@PathVariable String listingId,
                                                    Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        wishlistService.removeFromWishlist(userId, listingId);
        return ResponseEntity.ok().build();
    }

    @GetMapping
    public ResponseEntity<List<ListingDTO>> getUserWishlist(Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        List<ListingDTO> wishlist = wishlistService.getUserWishlist(userId);
        return ResponseEntity.ok(wishlist);
    }

    @GetMapping("/{listingId}/check")
    public ResponseEntity<Boolean> isInWishlist(@PathVariable String listingId,
                                                Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        boolean isInWishlist = wishlistService.isInWishlist(userId, listingId);
        return ResponseEntity.ok(isInWishlist);
    }
}

