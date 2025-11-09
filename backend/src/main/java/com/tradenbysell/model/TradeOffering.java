package com.tradenbysell.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "trade_offerings")
@IdClass(TradeOfferingId.class)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TradeOffering {
    @Id
    @Column(name = "trade_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String tradeId;

    @Id
    @Column(name = "listing_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String listingId;
}

