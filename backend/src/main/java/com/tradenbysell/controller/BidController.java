package com.tradenbysell.controller;

import com.tradenbysell.dto.BidDTO;
import com.tradenbysell.service.BidService;
import com.tradenbysell.util.AuthUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/bids")
@CrossOrigin(origins = "*")
public class BidController {

    @Autowired
    private AuthUtil authUtil;
    @Autowired
    private BidService bidService;

    @PostMapping
    public ResponseEntity<BidDTO> placeBid(@RequestBody PlaceBidRequest request,
                                           Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        BidDTO bid = bidService.placeBid(userId, request.getListingId(), request.getBidAmount());
        return ResponseEntity.ok(bid);
    }

    @GetMapping("/listing/{listingId}")
    public ResponseEntity<List<BidDTO>> getListingBids(@PathVariable String listingId) {
        List<BidDTO> bids = bidService.getListingBids(listingId);
        return ResponseEntity.ok(bids);
    }

    @GetMapping("/my-bids")
    public ResponseEntity<List<BidDTO>> getUserBids(Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        List<BidDTO> bids = bidService.getUserBids(userId);
        return ResponseEntity.ok(bids);
    }

    @PostMapping("/listing/{listingId}/finalize")
    public ResponseEntity<BidDTO> finalizeWinningBid(@PathVariable String listingId) {
        BidDTO bid = bidService.finalizeWinningBid(listingId);
        return ResponseEntity.ok(bid);
    }

    public static class PlaceBidRequest {
        private String listingId;
        private BigDecimal bidAmount;

        public String getListingId() {
            return listingId;
        }

        public void setListingId(String listingId) {
            this.listingId = listingId;
        }

        public BigDecimal getBidAmount() {
            return bidAmount;
        }

        public void setBidAmount(BigDecimal bidAmount) {
            this.bidAmount = bidAmount;
        }
    }
}

