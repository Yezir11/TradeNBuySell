package com.tradenbysell.dto;

import com.tradenbysell.model.ModerationLog;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ModerationLogDTO {
    private String logId;
    private String listingId;
    private String userId;
    private String userName;
    private String predictedLabel;
    private BigDecimal confidence;
    private Boolean shouldFlag;
    private ModerationLog.AdminAction adminAction;
    private String adminId;
    private String moderationReason;
    private String imageHeatmap;
    private Map<String, Object> textExplanation;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

