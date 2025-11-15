package com.tradenbysell.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_role", columnList = "role"),
    @Index(name = "idx_trust_score", columnList = "trust_score"),
    @Index(name = "idx_is_suspended", columnList = "is_suspended")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id
    @Column(name = "user_id", length = 36, columnDefinition = "CHAR(36)")
    private String userId;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(name = "password_hash")
    private String passwordHash;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;

    @Column(name = "full_name", nullable = false)
    private String fullName;

    @Column(name = "wallet_balance", nullable = false, precision = 15, scale = 2)
    private BigDecimal walletBalance = new BigDecimal("1000.00");

    @Column(name = "trust_score")
    private Float trustScore = 3.0f; // Default trust score (prior mean in Bayesian average calculation)

    @Column(name = "registered_at")
    private LocalDateTime registeredAt;

    @Column(name = "last_login_at")
    private LocalDateTime lastLoginAt;

    @Column(name = "is_suspended", nullable = false)
    private Boolean isSuspended = false;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        if (userId == null) {
            userId = java.util.UUID.randomUUID().toString();
        }
        if (registeredAt == null) {
            registeredAt = LocalDateTime.now();
        }
    }

    public enum Role {
        ADMIN, STUDENT
    }
}

