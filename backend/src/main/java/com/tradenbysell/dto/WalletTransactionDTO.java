package com.tradenbysell.dto;

import com.tradenbysell.model.WalletTransaction;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class WalletTransactionDTO {
    private Long transactionId;
    private String userId;
    private BigDecimal amount;
    private WalletTransaction.TransactionType type;
    private WalletTransaction.TransactionReason reason;
    private String referenceId;
    private String description;
    private LocalDateTime timestamp;
}

