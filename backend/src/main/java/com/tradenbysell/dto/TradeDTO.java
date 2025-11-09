package com.tradenbysell.dto;

import com.tradenbysell.model.Trade;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class TradeDTO {
    private String tradeId;
    private String initiatorId;
    private String initiatorName;
    private String recipientId;
    private String recipientName;
    private String requestedListingId;
    private String requestedListingTitle;
    private List<String> offeringListingIds;
    private List<String> offeringListingTitles;
    private BigDecimal cashAdjustmentAmount;
    private Trade.TradeStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime resolvedAt;
}

