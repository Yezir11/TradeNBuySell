package com.tradenbysell.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileDTO {
    private String userId;
    private String email;
    private String fullName;
    private String role;
    private BigDecimal walletBalance;
    private Float trustScore;
    private LocalDateTime registeredAt;
    private LocalDateTime lastLoginAt;
    private Boolean isSuspended;
}

