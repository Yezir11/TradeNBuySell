package com.tradenbysell.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ModerationResponseDTO {
    private String label;
    private Double confidence;
    private Boolean should_flag; // Snake case to match Flask API
    private Map<String, Double> all_probabilities; // Snake case to match Flask API
    private String image_heatmap; // Base64 encoded heatmap (snake case to match Flask API)
    private TextExplanation text_explanation; // Snake case to match Flask API
    
    // Getters for camelCase compatibility
    public Boolean getShouldFlag() {
        return should_flag;
    }
    
    public Map<String, Double> getAllProbabilities() {
        return all_probabilities;
    }
    
    public String getImageHeatmap() {
        return image_heatmap;
    }
    
    public TextExplanation getTextExplanation() {
        return text_explanation;
    }
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TextExplanation {
        private String[] tokens;
        private Double[] scores;
    }
}

