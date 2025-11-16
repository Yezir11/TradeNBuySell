package com.tradenbysell.service;

import com.tradenbysell.dto.ReportDTO;
import com.tradenbysell.exception.BadRequestException;
import com.tradenbysell.exception.ResourceNotFoundException;
import com.tradenbysell.model.Report;
import com.tradenbysell.model.User;
import com.tradenbysell.repository.ChatMessageRepository;
import com.tradenbysell.repository.ListingRepository;
import com.tradenbysell.repository.ReportRepository;
import com.tradenbysell.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class ReportService {
    @Autowired
    private ReportRepository reportRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ListingRepository listingRepository;

    @Autowired
    private ChatMessageRepository chatMessageRepository;

    @Autowired(required = false)
    private NotificationService notificationService;

    @Transactional
    public ReportDTO createReport(String reporterId, Report.ReportedType reportedType,
                                   String reportedId, String reasonText) {
        // Validate reporter exists
        if (!userRepository.existsById(reporterId)) {
            throw new ResourceNotFoundException("Reporter not found");
        }

        // Validate reason text
        if (reasonText == null || reasonText.trim().isEmpty()) {
            throw new BadRequestException("Reason text is required");
        }
        if (reasonText.trim().length() < 10) {
            throw new BadRequestException("Reason text must be at least 10 characters");
        }
        if (reasonText.length() > 1000) {
            throw new BadRequestException("Reason text must not exceed 1000 characters");
        }

        // Prevent self-reporting for USER type
        if (reportedType == Report.ReportedType.USER && reportedId.equals(reporterId)) {
            throw new BadRequestException("You cannot report yourself");
        }

        // Check for duplicate reports
        if (reportRepository.existsByReporterIdAndReportedTypeAndReportedId(reporterId, reportedType, reportedId)) {
            throw new BadRequestException("You have already reported this item");
        }

        // Validate reported entity exists
        validateReportedEntityExists(reportedType, reportedId);

        // Create report
        Report report = new Report();
        report.setReporterId(reporterId);
        report.setReportedType(reportedType);
        report.setReportedId(reportedId);
        report.setReasonText(reasonText.trim());
        report.setStatus(Report.ReportStatus.NEW);
        report = reportRepository.save(report);

        // Notify all admins
        if (notificationService != null) {
            List<User> admins = userRepository.findByRole(User.Role.ADMIN);
            for (User admin : admins) {
                notificationService.notifyAdminNewReport(
                    admin.getUserId(),
                    report.getReportId().toString(),
                    reportedType.toString()
                );
            }
        }

        return toDTO(report);
    }

    private void validateReportedEntityExists(Report.ReportedType reportedType, String reportedId) {
        switch (reportedType) {
            case LISTING:
                if (!listingRepository.existsById(reportedId)) {
                    throw new BadRequestException("Listing not found");
                }
                break;
            case USER:
                if (!userRepository.existsById(reportedId)) {
                    throw new BadRequestException("User not found");
                }
                break;
            case MESSAGE:
                try {
                    Long messageId = Long.parseLong(reportedId);
                    if (!chatMessageRepository.existsById(messageId)) {
                        throw new BadRequestException("Message not found");
                    }
                } catch (NumberFormatException e) {
                    throw new BadRequestException("Invalid message ID format");
                }
                break;
            default:
                throw new BadRequestException("Invalid reported type");
        }
    }

    public List<ReportDTO> getUserReports(String userId) {
        return reportRepository.findByReporterIdOrderByCreatedAtDesc(userId).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public List<ReportDTO> getReportsByStatus(Report.ReportStatus status) {
        return reportRepository.findByStatusOrderByCreatedAtDesc(status).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public List<ReportDTO> getAllReports() {
        return reportRepository.findAll().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public ReportDTO updateReportStatus(Long reportId, Report.ReportStatus status, String adminAction) {
        Report report = reportRepository.findById(reportId)
                .orElseThrow(() -> new ResourceNotFoundException("Report not found"));

        Report.ReportStatus oldStatus = report.getStatus();
        report.setStatus(status);
        report.setAdminAction(adminAction);
        
        if (status == Report.ReportStatus.RESOLVED || status == Report.ReportStatus.DISMISSED) {
            report.setResolvedAt(LocalDateTime.now());
            
            // Notify reporter when report is resolved
            if (notificationService != null && oldStatus != status) {
                Map<String, Object> metadata = new HashMap<>();
                metadata.put("reportId", reportId.toString());
                metadata.put("status", status.toString());
                metadata.put("adminAction", adminAction);
                
                notificationService.createNotification(
                    report.getReporterId(),
                    com.tradenbysell.model.Notification.NotificationType.REPORT_RESOLVED,
                    "Report Resolved",
                    String.format("Your report has been %s by an administrator.", status.toString().toLowerCase()),
                    reportId.toString(),
                    com.tradenbysell.model.Notification.RelatedEntityType.REPORT,
                    com.tradenbysell.model.Notification.Priority.MEDIUM,
                    metadata
                );
            }
        }
        
        report = reportRepository.save(report);

        return toDTO(report);
    }

    public ReportDTO getReportById(Long reportId) {
        Report report = reportRepository.findById(reportId)
                .orElseThrow(() -> new ResourceNotFoundException("Report not found"));
        return toDTO(report);
    }

    private ReportDTO toDTO(Report report) {
        ReportDTO dto = new ReportDTO();
        dto.setReportId(report.getReportId());
        dto.setReporterId(report.getReporterId());
        dto.setReportedType(report.getReportedType());
        dto.setReportedId(report.getReportedId());
        dto.setReasonText(report.getReasonText());
        dto.setStatus(report.getStatus());
        dto.setAdminAction(report.getAdminAction());
        dto.setCreatedAt(report.getCreatedAt());
        dto.setResolvedAt(report.getResolvedAt());

        User reporter = userRepository.findById(report.getReporterId()).orElse(null);
        if (reporter != null) {
            dto.setReporterName(reporter.getFullName());
        }

        return dto;
    }
}

