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
}

