package com.tradenbysell.service;

import com.tradenbysell.dto.ReportDTO;
import com.tradenbysell.exception.BadRequestException;
import com.tradenbysell.exception.ResourceNotFoundException;
import com.tradenbysell.model.Report;
import com.tradenbysell.model.User;
import com.tradenbysell.repository.ReportRepository;
import com.tradenbysell.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ReportService {
    @Autowired
    private ReportRepository reportRepository;

    @Autowired
    private UserRepository userRepository;

    @Transactional
    public ReportDTO createReport(String reporterId, Report.ReportedType reportedType,
                                   String reportedId, String reasonText) {
        User reporter = userRepository.findById(reporterId)
                .orElseThrow(() -> new ResourceNotFoundException("Reporter not found"));

        Report report = new Report();
        report.setReporterId(reporterId);
        report.setReportedType(reportedType);
        report.setReportedId(reportedId);
        report.setReasonText(reasonText);
        report.setStatus(Report.ReportStatus.NEW);
        report = reportRepository.save(report);

        return toDTO(report);
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

        report.setStatus(status);
        report.setAdminAction(adminAction);
        if (status == Report.ReportStatus.RESOLVED || status == Report.ReportStatus.DISMISSED) {
            report.setResolvedAt(LocalDateTime.now());
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

