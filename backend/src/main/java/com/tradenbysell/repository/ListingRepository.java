package com.tradenbysell.repository;

import com.tradenbysell.model.Listing;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ListingRepository extends JpaRepository<Listing, String> {
    List<Listing> findByUserId(String userId);
    List<Listing> findByUserIdAndIsActive(String userId, Boolean isActive);
    Page<Listing> findByIsActiveOrderByCreatedAtDesc(Boolean isActive, Pageable pageable);
    Page<Listing> findByCategoryAndIsActiveOrderByCreatedAtDesc(String category, Boolean isActive, Pageable pageable);
    List<Listing> findByIsActiveOrderByCreatedAtDesc(Boolean isActive);
    List<Listing> findByCategoryAndIsActive(String category, Boolean isActive);
    List<Listing> findByIsBiddableAndIsActive(Boolean isBiddable, Boolean isActive);
    List<Listing> findByIsTradeableAndIsActive(Boolean isTradeable, Boolean isActive);
    
    @Query("SELECT l FROM Listing l WHERE l.isActive = true AND " +
           "(LOWER(l.title) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(l.description) LIKE LOWER(CONCAT('%', :query, '%')))")
    Page<Listing> searchListings(@Param("query") String query, Pageable pageable);
    
    @Query("SELECT l FROM Listing l WHERE l.isActive = true AND " +
           "(LOWER(l.title) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(l.description) LIKE LOWER(CONCAT('%', :query, '%')))")
    List<Listing> searchListings(@Param("query") String query);
}

