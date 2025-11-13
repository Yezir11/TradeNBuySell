package com.tradenbysell.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "moderation_logs")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ModerationLog {
    
    @Id
    @Column(name = "log_id", columnDefinition = "CHAR(36)")
    private String logId;
    
    @Column(name = "listing_id", columnDefinition = "CHAR(36)")
    private String listingId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Column(name = "predicted_label", nullable = false, length = 50)
    private String predictedLabel;
    
    @Column(name = "confidence", nullable = false, precision = 5, scale = 4)
    private BigDecimal confidence;
    
    @Column(name = "should_flag")
    private Boolean shouldFlag;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "admin_action", columnDefinition = "ENUM('APPROVED','REJECTED','PENDING','BLACKLISTED')")
    private AdminAction adminAction;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "admin_id")
    private User admin;
    
    @Column(name = "moderation_reason", columnDefinition = "TEXT")
    private String moderationReason;
    
    @Column(name = "image_heatmap", columnDefinition = "LONGTEXT")
    private String imageHeatmap;
    
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "text_explanation", columnDefinition = "JSON")
    private Map<String, Object> textExplanation;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        if (logId == null) {
            logId = UUID.randomUUID().toString();
        }
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (updatedAt == null) {
            updatedAt = LocalDateTime.now();
        }
        if (adminAction == null) {
            adminAction = AdminAction.PENDING;
        }
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    public enum AdminAction {
        APPROVED, REJECTED, PENDING, BLACKLISTED
    }
}

