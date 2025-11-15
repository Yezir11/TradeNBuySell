package com.tradenbysell.controller;

import com.tradenbysell.dto.TradeDTO;
import com.tradenbysell.service.TradeService;
import com.tradenbysell.util.AuthUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/trades")
@CrossOrigin(origins = "*")
public class TradeController {

    @Autowired
    private AuthUtil authUtil;
    @Autowired
    private TradeService tradeService;

    @PostMapping
    public ResponseEntity<TradeDTO> createTrade(@RequestBody CreateTradeRequest request,
                                                Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        TradeDTO trade = tradeService.createTrade(userId, request.getRequestedListingId(),
                request.getOfferingListingIds(), request.getCashAdjustmentAmount());
        return ResponseEntity.ok(trade);
    }

    @GetMapping
    public ResponseEntity<List<TradeDTO>> getUserTrades(@RequestParam(required = false) String status,
                                                        Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        List<TradeDTO> trades = tradeService.getUserTrades(userId, status);
        return ResponseEntity.ok(trades);
    }

    @GetMapping("/{tradeId}")
    public ResponseEntity<TradeDTO> getTradeById(@PathVariable String tradeId) {
        TradeDTO trade = tradeService.getTradeById(tradeId);
        return ResponseEntity.ok(trade);
    }

    @PostMapping("/{tradeId}/accept")
    public ResponseEntity<TradeDTO> acceptTrade(@PathVariable String tradeId,
                                                 Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        TradeDTO trade = tradeService.acceptTrade(userId, tradeId);
        return ResponseEntity.ok(trade);
    }

    @PostMapping("/{tradeId}/reject")
    public ResponseEntity<TradeDTO> rejectTrade(@PathVariable String tradeId,
                                                Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        TradeDTO trade = tradeService.rejectTrade(userId, tradeId);
        return ResponseEntity.ok(trade);
    }

    @PostMapping("/{tradeId}/cancel")
    public ResponseEntity<TradeDTO> cancelTrade(@PathVariable String tradeId,
                                                Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        TradeDTO trade = tradeService.cancelTrade(userId, tradeId);
        return ResponseEntity.ok(trade);
    }

    public static class CreateTradeRequest {
        private String requestedListingId;
        private List<String> offeringListingIds;
        private BigDecimal cashAdjustmentAmount;

        public String getRequestedListingId() {
            return requestedListingId;
        }

        public void setRequestedListingId(String requestedListingId) {
            this.requestedListingId = requestedListingId;
        }

        public List<String> getOfferingListingIds() {
            return offeringListingIds;
        }

        public void setOfferingListingIds(List<String> offeringListingIds) {
            this.offeringListingIds = offeringListingIds;
        }

        public BigDecimal getCashAdjustmentAmount() {
            return cashAdjustmentAmount;
        }

        public void setCashAdjustmentAmount(BigDecimal cashAdjustmentAmount) {
            this.cashAdjustmentAmount = cashAdjustmentAmount;
        }
    }
}

