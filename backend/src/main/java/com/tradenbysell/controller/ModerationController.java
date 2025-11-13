package com.tradenbysell.controller;

import com.tradenbysell.dto.ModerationLogDTO;
import com.tradenbysell.dto.ModerationResponseDTO;
import com.tradenbysell.model.ModerationLog;
import com.tradenbysell.repository.ModerationLogRepository;
import com.tradenbysell.service.ModerationService;
import com.tradenbysell.util.AuthUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/moderation")
public class ModerationController {
    
    @Autowired
    private ModerationService moderationService;
    
    @Autowired
    private ModerationLogRepository moderationLogRepository;
    
    @Autowired
    private AuthUtil authUtil;
    
    /**
     * Moderate a listing
     */
    @PostMapping("/listing/{listingId}")
    public ResponseEntity<ModerationResponseDTO> moderateListing(
            @PathVariable String listingId,
            Authentication authentication) {
        ModerationResponseDTO response = moderationService.moderateListing(listingId, authentication);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Moderate content (for new listing submission)
     */
    @PostMapping("/content")
    public ResponseEntity<ModerationResponseDTO> moderateContent(
            @RequestParam("image") MultipartFile image,
            @RequestParam("title") String title,
            @RequestParam("description") String description,
            Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        ModerationResponseDTO response = moderationService.moderateContent(image, title, description, userId);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get flagged listings (Admin only)
     */
    @GetMapping("/admin/flagged-listings")
    public ResponseEntity<Map<String, Object>> getFlaggedListings(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            Authentication authentication) {
        
        Pageable pageable = PageRequest.of(page, size);
        Page<ModerationLog> logs = moderationLogRepository.findPendingFlaggedListings(pageable);
        
        Page<ModerationLogDTO> dtoPage = logs.map(log -> {
            ModerationLogDTO dto = new ModerationLogDTO();
            dto.setLogId(log.getLogId());
            dto.setListingId(log.getListingId());
            dto.setUserId(log.getUser().getUserId());
            dto.setUserName(log.getUser().getFullName());
            dto.setPredictedLabel(log.getPredictedLabel());
            dto.setConfidence(log.getConfidence());
            dto.setShouldFlag(log.getShouldFlag());
            dto.setAdminAction(log.getAdminAction());
            dto.setModerationReason(log.getModerationReason());
            dto.setImageHeatmap(log.getImageHeatmap());
            dto.setTextExplanation(log.getTextExplanation());
            dto.setCreatedAt(log.getCreatedAt());
            dto.setUpdatedAt(log.getUpdatedAt());
            return dto;
        });
        
        Map<String, Object> response = new HashMap<>();
        response.put("content", dtoPage.getContent());
        response.put("totalElements", dtoPage.getTotalElements());
        response.put("totalPages", dtoPage.getTotalPages());
        response.put("currentPage", dtoPage.getNumber());
        response.put("size", dtoPage.getSize());
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * Update moderation action (Admin only)
     */
    @PutMapping("/admin/log/{logId}/action")
    public ResponseEntity<Map<String, String>> updateModerationAction(
            @PathVariable String logId,
            @RequestBody Map<String, String> request,
            Authentication authentication) {
        
        String actionStr = request.get("action");
        String reason = request.get("reason");
        
        ModerationLog.AdminAction action;
        try {
            action = ModerationLog.AdminAction.valueOf(actionStr.toUpperCase());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", "Invalid action"));
        }
        
        moderationService.updateModerationAction(logId, action, reason, authentication);
        
        return ResponseEntity.ok(Map.of("message", "Moderation action updated successfully"));
    }
    
    /**
     * Get moderation statistics (Admin only)
     */
    @GetMapping("/admin/statistics")
    public ResponseEntity<Map<String, Object>> getModerationStatistics(Authentication authentication) {
        long totalFlagged = moderationLogRepository.countPendingFlaggedListings();
        long totalApproved = moderationLogRepository.countByAdminAction(ModerationLog.AdminAction.APPROVED);
        long totalRejected = moderationLogRepository.countByAdminAction(ModerationLog.AdminAction.REJECTED);
        long totalPending = moderationLogRepository.countByAdminAction(ModerationLog.AdminAction.PENDING);
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("pendingFlagged", totalFlagged);
        stats.put("approved", totalApproved);
        stats.put("rejected", totalRejected);
        stats.put("pending", totalPending);
        stats.put("total", totalApproved + totalRejected + totalPending);
        
        return ResponseEntity.ok(stats);
    }
}

