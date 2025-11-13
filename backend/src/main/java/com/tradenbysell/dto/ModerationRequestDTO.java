package com.tradenbysell.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ModerationRequestDTO {
    private String title;
    private String description;
    private String imageBase64; // Base64 encoded image
}

