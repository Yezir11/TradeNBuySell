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
    
    // Check if two users have completed a trade together
    @org.springframework.data.jpa.repository.Query(
        "SELECT COUNT(t) > 0 FROM Trade t WHERE " +
        "t.status = 'COMPLETED' AND " +
        "((t.initiatorId = :userId1 AND t.recipientId = :userId2) OR " +
        "(t.initiatorId = :userId2 AND t.recipientId = :userId1))"
    )
    boolean haveCompletedTrade(String userId1, String userId2);
    
    // Check if two users have completed a trade for a specific listing
    @org.springframework.data.jpa.repository.Query(
        "SELECT COUNT(t) > 0 FROM Trade t WHERE " +
        "t.status = 'COMPLETED' AND t.requestedListingId = :listingId AND " +
        "((t.initiatorId = :userId1 AND t.recipientId = :userId2) OR " +
        "(t.initiatorId = :userId2 AND t.recipientId = :userId1))"
    )
    boolean haveCompletedTradeForListing(String userId1, String userId2, String listingId);
}

