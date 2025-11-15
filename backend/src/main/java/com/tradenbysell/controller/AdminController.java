package com.tradenbysell.controller;

import com.tradenbysell.dto.ReportDTO;
import com.tradenbysell.model.Report;
import com.tradenbysell.model.User;
import com.tradenbysell.service.ReportService;
import com.tradenbysell.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {
    @Autowired
    private ReportService reportService;

    @Autowired
    private UserService userService;

    @Autowired
    private com.tradenbysell.service.AppSettingService appSettingService;

    @Autowired
    private com.tradenbysell.util.AuthUtil authUtil;

    @GetMapping("/reports")
    public ResponseEntity<List<ReportDTO>> getAllReports() {
        List<ReportDTO> reports = reportService.getAllReports();
        return ResponseEntity.ok(reports);
    }

    @PutMapping("/reports/{reportId}")
    public ResponseEntity<ReportDTO> updateReportStatus(@PathVariable Long reportId,
                                                        @RequestBody UpdateReportStatusRequest request) {
        ReportDTO report = reportService.updateReportStatus(reportId, request.getStatus(), request.getAdminAction());
        return ResponseEntity.ok(report);
    }

    @GetMapping("/users")
    public ResponseEntity<List<User>> getAllUsers() {
        List<User> users = userService.getAllUsers();
        return ResponseEntity.ok(users);
    }

    @PostMapping("/users/{userId}/suspend")
    public ResponseEntity<Void> suspendUser(@PathVariable String userId) {
        userService.suspendUser(userId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/users/{userId}/unsuspend")
    public ResponseEntity<Void> unsuspendUser(@PathVariable String userId) {
        userService.unsuspendUser(userId);
        return ResponseEntity.ok().build();
    }

    /**
     * Get mandatory moderation enabled setting
     */
    @GetMapping("/settings/mandatory-moderation")
    public ResponseEntity<Map<String, Object>> getMandatoryModerationSetting() {
        boolean enabled = appSettingService.isMandatoryModerationEnabled();
        Map<String, Object> response = new HashMap<>();
        response.put("enabled", enabled);
        return ResponseEntity.ok(response);
    }

    /**
     * Toggle mandatory moderation enabled setting
     */
    @PostMapping("/settings/mandatory-moderation/toggle")
    public ResponseEntity<Map<String, Object>> toggleMandatoryModerationSetting(
            Authentication authentication) {
        try {
            String userId = authUtil.getUserId(authentication);
            boolean currentValue = appSettingService.isMandatoryModerationEnabled();
            boolean newValue = !currentValue;
            
            appSettingService.updateMandatoryModerationSetting(newValue, userId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("enabled", newValue);
            response.put("message", "Mandatory moderation " + (newValue ? "enabled" : "disabled"));
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Failed to toggle setting: " + e.getMessage());
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    public static class UpdateReportStatusRequest {
        private Report.ReportStatus status;
        private String adminAction;

        public Report.ReportStatus getStatus() {
            return status;
        }

        public void setStatus(Report.ReportStatus status) {
            this.status = status;
        }

        public String getAdminAction() {
            return adminAction;
        }

        public void setAdminAction(String adminAction) {
            this.adminAction = adminAction;
        }
    }
}

