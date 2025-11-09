package com.tradenbysell.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "reports", indexes = {
    @Index(name = "idx_reporter_id", columnList = "reporter_id"),
    @Index(name = "idx_reported_type", columnList = "reported_type"),
    @Index(name = "idx_status", columnList = "status"),
    @Index(name = "idx_created_at", columnList = "created_at")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Report {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "report_id")
    private Long reportId;

    @Column(name = "reporter_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String reporterId;

    @Enumerated(EnumType.STRING)
    @Column(name = "reported_type", nullable = false)
    private ReportedType reportedType;

    @Column(name = "reported_id", nullable = false, length = 255)
    private String reportedId;

    @Column(name = "reason_text", nullable = false, columnDefinition = "TEXT")
    private String reasonText;

    @Enumerated(EnumType.STRING)
    @Column
    private ReportStatus status = ReportStatus.NEW;

    @Column(name = "admin_action", columnDefinition = "TEXT")
    private String adminAction;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "resolved_at")
    private LocalDateTime resolvedAt;

    public enum ReportedType {
        LISTING, USER, MESSAGE
    }

    public enum ReportStatus {
        NEW, UNDER_REVIEW, RESOLVED, ESCALATED, DISMISSED
    }
}

