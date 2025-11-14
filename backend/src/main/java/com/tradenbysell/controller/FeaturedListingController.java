package com.tradenbysell.controller;

import com.tradenbysell.dto.FeaturedPackageDTO;
import com.tradenbysell.service.FeaturedListingService;
import com.tradenbysell.util.AuthUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/featured")
@CrossOrigin(origins = "*")
public class FeaturedListingController {
    @Autowired
    private FeaturedListingService featuredListingService;
    
    @Autowired
    private AuthUtil authUtil;
    
    @GetMapping("/packages")
    public ResponseEntity<List<FeaturedPackageDTO>> getAvailablePackages() {
        List<FeaturedPackageDTO> packages = featuredListingService.getAvailablePackages();
        return ResponseEntity.ok(packages);
    }
    
    @PostMapping("/feature")
    public ResponseEntity<Map<String, String>> featureListing(
            @RequestBody Map<String, String> request,
            Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        String listingId = request.get("listingId");
        String packageId = request.get("packageId");
        
        if (listingId == null || packageId == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "listingId and packageId are required"));
        }
        
        featuredListingService.featureListing(userId, listingId, packageId);
        return ResponseEntity.ok(Map.of("message", "Listing featured successfully"));
    }
}

