package com.tradenbysell.repository;

import com.tradenbysell.model.TradeOffering;
import com.tradenbysell.model.TradeOfferingId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TradeOfferingRepository extends JpaRepository<TradeOffering, TradeOfferingId> {
    List<TradeOffering> findByTradeId(String tradeId);
    void deleteByTradeId(String tradeId);
}

