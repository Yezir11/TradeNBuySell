package com.tradenbysell.controller;

import com.tradenbysell.dto.ReportDTO;
import com.tradenbysell.model.Report;
import com.tradenbysell.service.ReportService;
import com.tradenbysell.util.AuthUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reports")
@CrossOrigin(origins = "*")
public class ReportController {

    @Autowired
    private AuthUtil authUtil;
    @Autowired
    private ReportService reportService;

    @PostMapping
    public ResponseEntity<ReportDTO> createReport(@RequestBody CreateReportRequest request,
                                                 Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        ReportDTO report = reportService.createReport(userId, request.getReportedType(),
                request.getReportedId(), request.getReasonText());
        return ResponseEntity.ok(report);
    }

    @GetMapping("/my-reports")
    public ResponseEntity<List<ReportDTO>> getUserReports(Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        List<ReportDTO> reports = reportService.getUserReports(userId);
        return ResponseEntity.ok(reports);
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<List<ReportDTO>> getReportsByStatus(@PathVariable String status) {
        Report.ReportStatus reportStatus = Report.ReportStatus.valueOf(status);
        List<ReportDTO> reports = reportService.getReportsByStatus(reportStatus);
        return ResponseEntity.ok(reports);
    }

    @GetMapping("/{reportId}")
    public ResponseEntity<ReportDTO> getReportById(@PathVariable Long reportId) {
        ReportDTO report = reportService.getReportById(reportId);
        return ResponseEntity.ok(report);
    }

    public static class CreateReportRequest {
        private Report.ReportedType reportedType;
        private String reportedId;
        private String reasonText;

        public Report.ReportedType getReportedType() {
            return reportedType;
        }

        public void setReportedType(Report.ReportedType reportedType) {
            this.reportedType = reportedType;
        }

        public String getReportedId() {
            return reportedId;
        }

        public void setReportedId(String reportedId) {
            this.reportedId = reportedId;
        }

        public String getReasonText() {
            return reasonText;
        }

        public void setReasonText(String reasonText) {
            this.reasonText = reasonText;
        }
    }
}

