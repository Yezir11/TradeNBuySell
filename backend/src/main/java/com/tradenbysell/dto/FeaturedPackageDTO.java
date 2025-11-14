package com.tradenbysell.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class FeaturedPackageDTO {
    private String packageId;
    private String packageName;
    private Integer durationDays;
    private BigDecimal price;
    private String description;
}

