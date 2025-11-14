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
    
    // Featured listings queries
    @Query("SELECT l FROM Listing l WHERE l.isActive = true AND l.isFeatured = true AND " +
           "(l.featuredUntil IS NULL OR l.featuredUntil > CURRENT_TIMESTAMP) " +
           "ORDER BY l.featuredUntil DESC, l.createdAt DESC")
    List<Listing> findActiveFeaturedListings();
    
    @Query("SELECT l FROM Listing l WHERE l.isActive = true AND l.isFeatured = true AND " +
           "(l.featuredUntil IS NULL OR l.featuredUntil > CURRENT_TIMESTAMP) " +
           "ORDER BY l.featuredUntil DESC, l.createdAt DESC")
    Page<Listing> findActiveFeaturedListings(Pageable pageable);
    
    @Query("SELECT l FROM Listing l WHERE l.isActive = true AND (l.isFeatured = false OR l.featuredUntil IS NULL OR l.featuredUntil <= CURRENT_TIMESTAMP) " +
           "ORDER BY l.createdAt DESC")
    List<Listing> findActiveNonFeaturedListings();
    
    @Query("SELECT l FROM Listing l WHERE l.isActive = true AND (l.isFeatured = false OR l.featuredUntil IS NULL OR l.featuredUntil <= CURRENT_TIMESTAMP) " +
           "ORDER BY l.createdAt DESC")
    Page<Listing> findActiveNonFeaturedListings(Pageable pageable);
    
    @Query("SELECT COUNT(l) FROM Listing l WHERE l.isActive = true AND (l.isFeatured = false OR l.featuredUntil IS NULL OR l.featuredUntil <= CURRENT_TIMESTAMP)")
    long countActiveNonFeaturedListings();
    
    // Non-biddable listings (for marketplace)
    @Query("SELECT l FROM Listing l WHERE l.isActive = true AND (l.isBiddable = false OR l.isBiddable IS NULL) AND l.isFeatured = true AND " +
           "(l.featuredUntil IS NULL OR l.featuredUntil > CURRENT_TIMESTAMP) " +
           "ORDER BY l.featuredUntil DESC, l.createdAt DESC")
    List<Listing> findActiveNonBiddableFeaturedListings();
    
    @Query("SELECT l FROM Listing l WHERE l.isActive = true AND (l.isBiddable = false OR l.isBiddable IS NULL) AND " +
           "(l.isFeatured = false OR l.featuredUntil IS NULL OR l.featuredUntil <= CURRENT_TIMESTAMP) " +
           "ORDER BY l.createdAt DESC")
    List<Listing> findActiveNonBiddableNonFeaturedListings();
    
    @Query("SELECT COUNT(l) FROM Listing l WHERE l.isActive = true AND (l.isBiddable = false OR l.isBiddable IS NULL)")
    long countActiveNonBiddableListings();
    
    @Query("SELECT l FROM Listing l WHERE l.isActive = true AND " +
           "(LOWER(l.title) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(l.description) LIKE LOWER(CONCAT('%', :query, '%')))")
    Page<Listing> searchListings(@Param("query") String query, Pageable pageable);
    
    @Query("SELECT l FROM Listing l WHERE l.isActive = true AND " +
           "(LOWER(l.title) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(l.description) LIKE LOWER(CONCAT('%', :query, '%')))")
    List<Listing> searchListings(@Param("query") String query);
    
    // Search non-biddable listings only
    @Query("SELECT l FROM Listing l WHERE l.isActive = true AND (l.isBiddable = false OR l.isBiddable IS NULL) AND " +
           "(LOWER(l.title) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(l.description) LIKE LOWER(CONCAT('%', :query, '%')))")
    Page<Listing> searchNonBiddableListings(@Param("query") String query, Pageable pageable);
    
    @Query("SELECT l FROM Listing l WHERE l.isActive = true AND (l.isBiddable = false OR l.isBiddable IS NULL) AND " +
           "(LOWER(l.title) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(l.description) LIKE LOWER(CONCAT('%', :query, '%')))")
    List<Listing> searchNonBiddableListings(@Param("query") String query);
    
    // Category search for non-biddable listings only
    @Query("SELECT l FROM Listing l WHERE l.isActive = true AND (l.isBiddable = false OR l.isBiddable IS NULL) AND l.category = :category " +
           "ORDER BY l.createdAt DESC")
    List<Listing> findNonBiddableByCategoryAndIsActive(@Param("category") String category);
    
    @Query("SELECT l FROM Listing l WHERE l.isActive = true AND (l.isBiddable = false OR l.isBiddable IS NULL) AND l.category = :category " +
           "ORDER BY l.createdAt DESC")
    Page<Listing> findNonBiddableByCategoryAndIsActiveOrderByCreatedAtDesc(@Param("category") String category, Pageable pageable);
}

