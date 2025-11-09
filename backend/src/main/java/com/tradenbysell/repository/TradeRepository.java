package com.tradenbysell.repository;

import com.tradenbysell.model.Trade;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TradeRepository extends JpaRepository<Trade, String> {
    List<Trade> findByInitiatorIdOrRecipientIdOrderByCreatedAtDesc(String initiatorId, String recipientId);
    List<Trade> findByInitiatorIdOrderByCreatedAtDesc(String initiatorId);
    List<Trade> findByRecipientIdOrderByCreatedAtDesc(String recipientId);
}

