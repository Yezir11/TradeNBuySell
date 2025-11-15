package com.tradenbysell.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class ListingCreateDTO {
    @NotBlank(message = "Title is required")
    @Size(max = 255, message = "Title must be less than 255 characters")
    private String title;

    @NotBlank(message = "Description is required")
    private String description;

    private BigDecimal price;

    @NotNull(message = "isTradeable is required")
    private Boolean isTradeable;

    @NotNull(message = "isBiddable is required")
    private Boolean isBiddable;

    private BigDecimal startingPrice;
    private BigDecimal bidIncrement;
    private LocalDateTime bidStartTime;
    private LocalDateTime bidEndTime;
    
    @NotBlank(message = "Category is required")
    private String category;
    
    @NotNull(message = "Tags are required")
    @Size(min = 1, message = "At least one tag is required")
    private List<String> tags;
}

