package com.tradenbysell.service;

import com.tradenbysell.dto.ModerationRequestDTO;
import com.tradenbysell.dto.ModerationResponseDTO;
import com.tradenbysell.model.Listing;
import com.tradenbysell.model.ModerationLog;
import com.tradenbysell.model.User;
import com.tradenbysell.repository.ListingImageRepository;
import com.tradenbysell.repository.ListingRepository;
import com.tradenbysell.repository.ModerationLogRepository;
import com.tradenbysell.repository.UserRepository;
import com.tradenbysell.model.ListingImage;
import com.tradenbysell.util.AuthUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ModerationService {
    
    @Autowired
    private ModerationLogRepository moderationLogRepository;
    
    @Autowired
    private ListingRepository listingRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private ListingImageRepository listingImageRepository;
    
    @Autowired
    private AuthUtil authUtil;
    
    @Autowired(required = false)
    private NotificationService notificationService;
    
    @Value("${app.moderation.api.url:http://localhost:5000}")
    private String moderationApiUrl;
    
    @Value("${app.upload.dir:uploads}")
    private String uploadDir;
    
    private final RestTemplate restTemplate = new RestTemplate();
    
    /**
     * Moderate a listing using the ML moderation API
     */
    public ModerationResponseDTO moderateListing(String listingId, Authentication authentication) {
        Listing listing = listingRepository.findById(listingId)
                .orElseThrow(() -> new RuntimeException("Listing not found"));
        
        // Get listing image (first image)
        String imageBase64 = null;
        List<ListingImage> images = listingImageRepository.findByListingIdOrderByDisplayOrderAsc(listingId);
        if (images != null && !images.isEmpty()) {
            ListingImage firstImage = images.get(0);
            // Load image file and convert to base64
            try {
                // Extract filename from URL
                String imageUrl = firstImage.getImageUrl();
                String filename = imageUrl.substring(imageUrl.lastIndexOf('/') + 1);
                java.nio.file.Path imagePath = java.nio.file.Paths.get(uploadDir, filename);
                
                if (java.nio.file.Files.exists(imagePath)) {
                    byte[] imageBytes = java.nio.file.Files.readAllBytes(imagePath);
                    imageBase64 = Base64.getEncoder().encodeToString(imageBytes);
                }
            } catch (Exception e) {
                // If image loading fails, continue without image
                System.err.println("Error loading image for moderation: " + e.getMessage());
            }
        }
        
        ModerationRequestDTO request = new ModerationRequestDTO(
                listing.getTitle(),
                listing.getDescription(),
                imageBase64
        );
        
        return callModerationAPI(request, listingId, listing.getUserId());
    }
    
    /**
     * Moderate content from multipart form data (for new listing submission)
     */
    public ModerationResponseDTO moderateContent(MultipartFile image, String title, String description, String userId) {
        try {
            // Convert image to base64
            String imageBase64 = Base64.getEncoder().encodeToString(image.getBytes());
            
            ModerationRequestDTO request = new ModerationRequestDTO(title, description, imageBase64);
            return callModerationAPI(request, null, userId);
        } catch (IOException e) {
            throw new RuntimeException("Error processing image: " + e.getMessage());
        }
    }
    
    /**
     * Call the Flask moderation API
     */
    private ModerationResponseDTO callModerationAPI(ModerationRequestDTO request, String listingId, String userId) {
        try {
            // Prepare JSON request
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            
            // Create request body as JSON
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("title", request.getTitle());
            requestBody.put("description", request.getDescription());
            if (request.getImageBase64() != null && !request.getImageBase64().isEmpty()) {
                requestBody.put("imageBase64", request.getImageBase64());
            }
            
            HttpEntity<Map<String, Object>> requestEntity = new HttpEntity<>(requestBody, headers);
            
            // Call API
            ResponseEntity<ModerationResponseDTO> response = restTemplate.exchange(
                    moderationApiUrl + "/moderate",
                    HttpMethod.POST,
                    requestEntity,
                    ModerationResponseDTO.class
            );
            
            ModerationResponseDTO moderationResponse = response.getBody();
            
            // Save moderation log
            if (moderationResponse != null) {
                saveModerationLog(moderationResponse, listingId, userId);
            }
            
            return moderationResponse;
            
        } catch (Exception e) {
            throw new RuntimeException("Error calling moderation API: " + e.getMessage());
        }
    }
    
    /**
     * Save moderation log to database
     */
    private void saveModerationLog(ModerationResponseDTO response, String listingId, String userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        ModerationLog log = new ModerationLog();
        log.setListingId(listingId);
        log.setUser(user);
        log.setPredictedLabel(response.getLabel());
        log.setConfidence(BigDecimal.valueOf(response.getConfidence()));
        log.setShouldFlag(response.getShould_flag());
        log.setImageHeatmap(response.getImage_heatmap());
        
        // Convert text explanation
        if (response.getText_explanation() != null) {
            Map<String, Object> textExplanation = new HashMap<>();
            textExplanation.put("tokens", response.getText_explanation().getTokens());
            textExplanation.put("scores", response.getText_explanation().getScores());
            log.setTextExplanation(textExplanation);
        }
        
        moderationLogRepository.save(log);
        
        // Notify user if listing was flagged
        if (response.getShould_flag() && listingId != null) {
            Listing listing = listingRepository.findById(listingId).orElse(null);
            if (listing != null && notificationService != null) {
                notificationService.notifyListingFlagged(userId, listingId, listing.getTitle());
                
                // Notify all admins about new flagged listing
                List<User> admins = userRepository.findByRole(com.tradenbysell.model.User.Role.ADMIN);
                for (User admin : admins) {
                    notificationService.notifyAdminNewFlaggedListing(
                            admin.getUserId(),
                            listingId,
                            listing.getTitle(),
                            response.getLabel()
                    );
                }
            }
        }
    }
    
    /**
     * Update moderation log with admin action
     */
    public void updateModerationAction(String logId, ModerationLog.AdminAction action, 
                                      String reason, Authentication authentication) {
        ModerationLog log = moderationLogRepository.findById(logId)
                .orElseThrow(() -> new RuntimeException("Moderation log not found"));
        
        String adminId = authUtil.getUserId(authentication);
        User admin = userRepository.findById(adminId)
                .orElseThrow(() -> new RuntimeException("Admin not found"));
        
        log.setAdminAction(action);
        log.setAdmin(admin);
        log.setModerationReason(reason);
        
        moderationLogRepository.save(log);
        
        // Send notifications based on admin action
        if (log.getListingId() != null && log.getUser() != null && notificationService != null) {
            Listing listing = listingRepository.findById(log.getListingId()).orElse(null);
            if (listing != null) {
                String userId = log.getUser().getUserId();
                String listingTitle = listing.getTitle();
                
                if (action == ModerationLog.AdminAction.APPROVED) {
                    listing.setIsActive(true);
                    listingRepository.save(listing);
                    notificationService.notifyListingApproved(userId, log.getListingId(), listingTitle);
                } else if (action == ModerationLog.AdminAction.REJECTED) {
                    listing.setIsActive(false);
                    listingRepository.save(listing);
                    notificationService.notifyListingRejected(userId, log.getListingId(), listingTitle, reason);
                }
            }
        }
    }
}

