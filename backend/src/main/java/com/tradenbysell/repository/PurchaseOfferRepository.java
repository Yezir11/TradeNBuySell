package com.tradenbysell.repository;

import com.tradenbysell.model.PurchaseOffer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PurchaseOfferRepository extends JpaRepository<PurchaseOffer, String> {
    
    List<PurchaseOffer> findByListingIdOrderByCreatedAtDesc(String listingId);
    
    List<PurchaseOffer> findByBuyerIdOrderByCreatedAtDesc(String buyerId);
    
    List<PurchaseOffer> findBySellerIdOrderByCreatedAtDesc(String sellerId);
    
    List<PurchaseOffer> findByListingIdAndStatus(String listingId, PurchaseOffer.OfferStatus status);
    
    List<PurchaseOffer> findByBuyerIdAndStatus(String buyerId, PurchaseOffer.OfferStatus status);
    
    List<PurchaseOffer> findBySellerIdAndStatus(String sellerId, PurchaseOffer.OfferStatus status);
    
    @Query("SELECT p FROM PurchaseOffer p WHERE p.listingId = :listingId AND p.buyerId = :buyerId AND p.status = 'PENDING'")
    Optional<PurchaseOffer> findPendingOfferByListingAndBuyer(@Param("listingId") String listingId, @Param("buyerId") String buyerId);
    
    @Query("SELECT COUNT(p) FROM PurchaseOffer p WHERE p.listingId = :listingId AND p.status = 'PENDING'")
    long countPendingOffersByListing(@Param("listingId") String listingId);
    
    // Check if two users have completed a purchase transaction
    @Query("SELECT COUNT(p) > 0 FROM PurchaseOffer p WHERE " +
           "p.status = 'ACCEPTED' AND p.listingId = :listingId AND " +
           "((p.buyerId = :userId1 AND p.sellerId = :userId2) OR " +
           "(p.buyerId = :userId2 AND p.sellerId = :userId1))")
    boolean haveCompletedPurchaseForListing(@Param("userId1") String userId1, @Param("userId2") String userId2, @Param("listingId") String listingId);
    
    // Check if two users have any completed purchase transaction
    @Query("SELECT COUNT(p) > 0 FROM PurchaseOffer p WHERE " +
           "p.status = 'ACCEPTED' AND " +
           "((p.buyerId = :userId1 AND p.sellerId = :userId2) OR " +
           "(p.buyerId = :userId2 AND p.sellerId = :userId1))")
    boolean haveCompletedPurchase(@Param("userId1") String userId1, @Param("userId2") String userId2);
}

