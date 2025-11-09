package com.tradenbysell.repository;

import com.tradenbysell.model.Bid;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BidRepository extends JpaRepository<Bid, Long> {
    List<Bid> findByListingIdOrderByBidAmountDescBidTimeAsc(String listingId);
    Optional<Bid> findTopByListingIdOrderByBidAmountDescBidTimeAsc(String listingId);
    List<Bid> findByUserIdOrderByBidTimeDesc(String userId);
    List<Bid> findByListingIdAndIsWinning(String listingId, Boolean isWinning);
}

