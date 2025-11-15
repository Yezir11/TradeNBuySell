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
    void deleteByListingId(String listingId);
    
    // Check if a user has a winning bid (completed purchase) for a listing
    @org.springframework.data.jpa.repository.Query(
        "SELECT COUNT(b) > 0 FROM Bid b WHERE " +
        "b.listingId = :listingId AND b.userId = :userId AND b.isWinning = true"
    )
    boolean hasWinningBidForListing(String userId, String listingId);
}

