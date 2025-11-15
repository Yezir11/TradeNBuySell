package com.tradenbysell.controller;

import com.tradenbysell.dto.PurchaseOfferDTO;
import com.tradenbysell.service.PurchaseOfferService;
import com.tradenbysell.util.AuthUtil;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/offers")
@CrossOrigin(origins = "*")
public class PurchaseOfferController {
    
    @Autowired
    private PurchaseOfferService purchaseOfferService;
    
    @Autowired
    private AuthUtil authUtil;
    
    @PostMapping
    public ResponseEntity<PurchaseOfferDTO> createOffer(
            @Valid @RequestBody CreateOfferRequest request,
            Authentication authentication) {
        String buyerId = authUtil.getUserId(authentication);
        PurchaseOfferDTO offer = purchaseOfferService.createOffer(
                buyerId,
                request.getListingId(),
                request.getOfferAmount(),
                request.getMessage()
        );
        return ResponseEntity.ok(offer);
    }
    
    @GetMapping("/listing/{listingId}")
    public ResponseEntity<List<PurchaseOfferDTO>> getOffersByListing(@PathVariable String listingId) {
        List<PurchaseOfferDTO> offers = purchaseOfferService.getOffersByListing(listingId);
        return ResponseEntity.ok(offers);
    }
    
    @GetMapping("/my-offers")
    public ResponseEntity<List<PurchaseOfferDTO>> getMyOffers(Authentication authentication) {
        String buyerId = authUtil.getUserId(authentication);
        List<PurchaseOfferDTO> offers = purchaseOfferService.getBuyerOffers(buyerId);
        return ResponseEntity.ok(offers);
    }
    
    @GetMapping("/my-listings-offers")
    public ResponseEntity<List<PurchaseOfferDTO>> getMyListingsOffers(Authentication authentication) {
        String sellerId = authUtil.getUserId(authentication);
        List<PurchaseOfferDTO> offers = purchaseOfferService.getSellerOffers(sellerId);
        return ResponseEntity.ok(offers);
    }
    
    @GetMapping("/{offerId}")
    public ResponseEntity<PurchaseOfferDTO> getOfferById(@PathVariable String offerId) {
        PurchaseOfferDTO offer = purchaseOfferService.getOfferById(offerId);
        return ResponseEntity.ok(offer);
    }
    
    @PostMapping("/{offerId}/accept")
    public ResponseEntity<PurchaseOfferDTO> acceptOffer(
            @PathVariable String offerId,
            Authentication authentication) {
        String sellerId = authUtil.getUserId(authentication);
        PurchaseOfferDTO offer = purchaseOfferService.acceptOffer(sellerId, offerId);
        return ResponseEntity.ok(offer);
    }
    
    @PostMapping("/{offerId}/counter")
    public ResponseEntity<PurchaseOfferDTO> counterOffer(
            @PathVariable String offerId,
            @Valid @RequestBody CounterOfferRequest request,
            Authentication authentication) {
        String sellerId = authUtil.getUserId(authentication);
        PurchaseOfferDTO offer = purchaseOfferService.counterOffer(
                sellerId,
                offerId,
                request.getCounterAmount(),
                request.getMessage()
        );
        return ResponseEntity.ok(offer);
    }
    
    @PostMapping("/{offerId}/reject")
    public ResponseEntity<PurchaseOfferDTO> rejectOffer(
            @PathVariable String offerId,
            Authentication authentication) {
        String sellerId = authUtil.getUserId(authentication);
        PurchaseOfferDTO offer = purchaseOfferService.rejectOffer(sellerId, offerId);
        return ResponseEntity.ok(offer);
    }
    
    @DeleteMapping("/{offerId}")
    public ResponseEntity<Void> cancelOffer(
            @PathVariable String offerId,
            Authentication authentication) {
        String buyerId = authUtil.getUserId(authentication);
        purchaseOfferService.cancelOffer(buyerId, offerId);
        return ResponseEntity.ok().build();
    }
    
    // Request DTOs
    @lombok.Data
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class CreateOfferRequest {
        private String listingId;
        private BigDecimal offerAmount;
        private String message;
    }
    
    @lombok.Data
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class CounterOfferRequest {
        private BigDecimal counterAmount;
        private String message;
    }
}

