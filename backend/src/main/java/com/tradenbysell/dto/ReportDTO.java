package com.tradenbysell.dto;

import com.tradenbysell.model.Report;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ReportDTO {
    private Long reportId;
    private String reporterId;
    private String reporterName;
    
    @NotNull(message = "Reported type is required")
    private Report.ReportedType reportedType;
    
    @NotBlank(message = "Reported ID is required")
    private String reportedId;
    
    @NotBlank(message = "Reason is required")
    private String reasonText;
    
    private Report.ReportStatus status;
    private String adminAction;
    private LocalDateTime createdAt;
    private LocalDateTime resolvedAt;
}

