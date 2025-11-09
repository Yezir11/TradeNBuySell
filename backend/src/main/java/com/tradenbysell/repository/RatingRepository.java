package com.tradenbysell.repository;

import com.tradenbysell.model.Rating;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RatingRepository extends JpaRepository<Rating, Long> {
    List<Rating> findByToUserIdOrderByTimestampDesc(String toUserId);
    Optional<Rating> findByFromUserIdAndToUserIdAndListingId(String fromUserId, String toUserId, String listingId);
    
    @Query("SELECT AVG(r.ratingValue) FROM Rating r WHERE r.toUserId = :userId")
    Double getAverageRatingByUserId(@Param("userId") String userId);
    
    @Query("SELECT COUNT(r) FROM Rating r WHERE r.toUserId = :userId")
    Long getRatingCountByUserId(@Param("userId") String userId);
}

