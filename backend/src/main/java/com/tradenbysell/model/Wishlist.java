package com.tradenbysell.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "wishlists")
@IdClass(WishlistId.class)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Wishlist {
    @Id
    @Column(name = "user_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String userId;

    @Id
    @Column(name = "listing_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String listingId;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}

