package com.tradenbysell.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "ratings", indexes = {
    @Index(name = "idx_from_user_id", columnList = "from_user_id"),
    @Index(name = "idx_to_user_id", columnList = "to_user_id"),
    @Index(name = "idx_listing_id", columnList = "listing_id")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Rating {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "rating_id")
    private Long ratingId;

    @Column(name = "from_user_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String fromUserId;

    @Column(name = "to_user_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String toUserId;

    @Column(name = "listing_id", length = 36, columnDefinition = "CHAR(36)")
    private String listingId;

    @Column(name = "rating_value", nullable = false)
    private Integer ratingValue;

    @Column(name = "review_comment", columnDefinition = "TEXT")
    private String reviewComment;

    @CreationTimestamp
    @Column(name = "timestamp")
    private LocalDateTime timestamp;
}

