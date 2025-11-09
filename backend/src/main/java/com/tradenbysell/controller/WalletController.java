package com.tradenbysell.controller;

import com.tradenbysell.dto.WalletTransactionDTO;
import com.tradenbysell.service.WalletService;
import com.tradenbysell.util.AuthUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/wallet")
@CrossOrigin(origins = "*")
public class WalletController {
    @Autowired
    private WalletService walletService;

    @Autowired
    private AuthUtil authUtil;

    @GetMapping("/balance")
    public ResponseEntity<BigDecimal> getBalance(Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        BigDecimal balance = walletService.getBalance(userId);
        return ResponseEntity.ok(balance);
    }

    @GetMapping("/transactions")
    public ResponseEntity<List<WalletTransactionDTO>> getTransactionHistory(Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        List<WalletTransactionDTO> transactions = walletService.getTransactionHistory(userId);
        return ResponseEntity.ok(transactions);
    }

    @PostMapping("/add-funds")
    public ResponseEntity<WalletTransactionDTO> addFunds(@RequestBody AddFundsRequest request,
                                                          Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        WalletTransactionDTO transaction = walletService.addFunds(userId, request.getAmount(), request.getDescription());
        return ResponseEntity.ok(transaction);
    }

    public static class AddFundsRequest {
        private BigDecimal amount;
        private String description;

        public BigDecimal getAmount() {
            return amount;
        }

        public void setAmount(BigDecimal amount) {
            this.amount = amount;
        }

        public String getDescription() {
            return description;
        }

        public void setDescription(String description) {
            this.description = description;
        }
    }
}

