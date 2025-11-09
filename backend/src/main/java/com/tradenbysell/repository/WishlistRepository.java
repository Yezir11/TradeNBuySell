package com.tradenbysell.repository;

import com.tradenbysell.model.Wishlist;
import com.tradenbysell.model.WishlistId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WishlistRepository extends JpaRepository<Wishlist, WishlistId> {
    List<Wishlist> findByUserIdOrderByCreatedAtDesc(String userId);
    boolean existsByUserIdAndListingId(String userId, String listingId);
    void deleteByUserIdAndListingId(String userId, String listingId);
}

