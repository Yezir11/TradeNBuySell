package com.tradenbysell.repository;

import com.tradenbysell.model.ModerationLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ModerationLogRepository extends JpaRepository<ModerationLog, String> {
    
    Optional<ModerationLog> findByListingId(String listingId);
    
    @Query("SELECT m FROM ModerationLog m WHERE m.user.userId = :userId")
    List<ModerationLog> findByUserId(@Param("userId") String userId);
    
    Page<ModerationLog> findByShouldFlagTrue(Pageable pageable);
    
    Page<ModerationLog> findByAdminAction(ModerationLog.AdminAction action, Pageable pageable);
    
    @Query("SELECT m FROM ModerationLog m " +
           "JOIN Listing l ON l.listingId = m.listingId " +
           "WHERE m.shouldFlag = true AND m.adminAction = 'PENDING' " +
           "AND l.isActive = false")
    Page<ModerationLog> findPendingFlaggedListings(Pageable pageable);
    
    @Query("SELECT COUNT(m) FROM ModerationLog m " +
           "JOIN Listing l ON l.listingId = m.listingId " +
           "WHERE m.shouldFlag = true AND m.adminAction = 'PENDING' " +
           "AND l.isActive = false")
    long countPendingFlaggedListings();
    
    long countByAdminAction(ModerationLog.AdminAction action);
}

