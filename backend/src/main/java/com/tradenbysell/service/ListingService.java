package com.tradenbysell.service;

import com.tradenbysell.dto.ListingCreateDTO;
import com.tradenbysell.dto.ListingDTO;
import com.tradenbysell.dto.PagedResponse;
import com.tradenbysell.exception.BadRequestException;
import com.tradenbysell.exception.ResourceNotFoundException;
import com.tradenbysell.model.Bid;
import com.tradenbysell.model.Listing;
import com.tradenbysell.model.ListingImage;
import com.tradenbysell.model.ListingTag;
import com.tradenbysell.model.User;
import com.tradenbysell.repository.BidRepository;
import com.tradenbysell.repository.ListingImageRepository;
import com.tradenbysell.repository.ListingRepository;
import com.tradenbysell.repository.ListingTagRepository;
import com.tradenbysell.repository.ModerationLogRepository;
import com.tradenbysell.repository.UserRepository;
import com.tradenbysell.model.ModerationLog;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.security.core.Authentication;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ListingService {
    @Autowired
    private ListingRepository listingRepository;

    @Autowired
    private ListingImageRepository listingImageRepository;

    @Autowired
    private ListingTagRepository listingTagRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BidRepository bidRepository;
    
    @Autowired(required = false)
    private com.tradenbysell.service.ModerationService moderationService;

    @Autowired
    private com.tradenbysell.service.AppSettingService appSettingService;
    
    @Autowired
    private ModerationLogRepository moderationLogRepository;

    @Transactional
    public ListingDTO createListing(String userId, ListingCreateDTO createDTO) {
        if (!userRepository.existsById(userId)) {
            throw new ResourceNotFoundException("User not found");
        }

        // Validate: Price required if not tradeable and not biddable
        if (!createDTO.getIsTradeable() && !createDTO.getIsBiddable()) {
            if (createDTO.getPrice() == null || createDTO.getPrice().compareTo(BigDecimal.ZERO) <= 0) {
                throw new BadRequestException("Price is required if listing is neither tradeable nor biddable");
            }
        }

        // Validate: Bidding fields required if biddable
        if (createDTO.getIsBiddable()) {
            if (createDTO.getStartingPrice() == null || createDTO.getStartingPrice().compareTo(BigDecimal.ZERO) <= 0) {
                throw new BadRequestException("Starting price is required for biddable listings");
            }
            if (createDTO.getBidIncrement() == null || createDTO.getBidIncrement().compareTo(BigDecimal.ZERO) <= 0) {
                throw new BadRequestException("Bid increment is required for biddable listings");
            }
            if (createDTO.getBidStartTime() == null) {
                throw new BadRequestException("Bid start time is required for biddable listings");
            }
            if (createDTO.getBidEndTime() == null) {
                throw new BadRequestException("Bid end time is required for biddable listings");
            }
        }

        // Validate: Tags required
        if (createDTO.getTags() == null || createDTO.getTags().isEmpty()) {
            throw new BadRequestException("At least one tag is required");
        }

        Listing listing = new Listing();
        listing.setUserId(userId);
        listing.setTitle(createDTO.getTitle());
        listing.setDescription(createDTO.getDescription());
        listing.setPrice(createDTO.getPrice());
        listing.setIsTradeable(createDTO.getIsTradeable());
        listing.setIsBiddable(createDTO.getIsBiddable());
        listing.setStartingPrice(createDTO.getStartingPrice());
        listing.setBidIncrement(createDTO.getBidIncrement());
        listing.setBidStartTime(createDTO.getBidStartTime());
        listing.setBidEndTime(createDTO.getBidEndTime());
        listing.setCategory(createDTO.getCategory());
        listing.setIsActive(true);

        listing = listingRepository.save(listing);

        // Tags are now mandatory, so this should always execute
        for (String tag : createDTO.getTags()) {
            ListingTag listingTag = new ListingTag();
            listingTag.setListingId(listing.getListingId());
            listingTag.setTag(tag);
            listingTagRepository.save(listingTag);
        }

        return toDTO(listing);
    }

    public ListingDTO getListingById(String listingId) {
        Listing listing = listingRepository.findById(listingId)
                .orElseThrow(() -> new ResourceNotFoundException("Listing not found"));
        return toDTO(listing);
    }

    public List<ListingDTO> getAllActiveListings() {
        return listingRepository.findByIsActiveOrderByCreatedAtDesc(true).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public PagedResponse<ListingDTO> getAllActiveListings(int page, int size) {
        // Get all featured listings first
        List<Listing> featuredListings = listingRepository.findActiveFeaturedListings();
        List<ListingDTO> featuredDTOs = featuredListings.stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        
        int featuredCount = featuredDTOs.size();
        long totalNonFeatured = listingRepository.countActiveNonFeaturedListings();
        int totalElements = featuredCount + (int) totalNonFeatured;
        
        // Combine featured and non-featured for pagination
        List<ListingDTO> allListings = new ArrayList<>(featuredDTOs);
        
        // Get non-featured listings (we'll get all and paginate in memory for simplicity)
        // For better performance with large datasets, you might want to use a cursor-based approach
        List<Listing> nonFeaturedListings = listingRepository.findActiveNonFeaturedListings();
        List<ListingDTO> nonFeaturedDTOs = nonFeaturedListings.stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        allListings.addAll(nonFeaturedDTOs);
        
        // Apply pagination
        int start = page * size;
        int end = Math.min(start + size, allListings.size());
        
        List<ListingDTO> content;
        if (start >= allListings.size()) {
            content = new ArrayList<>();
        } else {
            content = new ArrayList<>(allListings.subList(start, end));
        }
        
        int totalPages = (int) Math.ceil((double) totalElements / size);
        
        return new PagedResponse<>(
                content,
                page,
                size,
                totalElements,
                totalPages,
                page == 0,
                page >= totalPages - 1
        );
    }

    // Get only non-biddable listings (for marketplace - buy/sell/trade only)
    public PagedResponse<ListingDTO> getNonBiddableListings(int page, int size) {
        // Get featured non-biddable listings first
        List<Listing> featuredNonBiddable = listingRepository.findActiveNonBiddableFeaturedListings();
        List<ListingDTO> featuredDTOs = featuredNonBiddable.stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        
        // Combine featured and non-featured non-biddable listings
        List<ListingDTO> allListings = new ArrayList<>(featuredDTOs);
        
        // Get non-featured non-biddable listings
        List<Listing> nonFeaturedNonBiddable = listingRepository.findActiveNonBiddableNonFeaturedListings();
        List<ListingDTO> nonFeaturedDTOs = nonFeaturedNonBiddable.stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        allListings.addAll(nonFeaturedDTOs);
        
        // Apply pagination
        int totalElements = allListings.size();
        int start = page * size;
        int end = Math.min(start + size, allListings.size());
        
        List<ListingDTO> content;
        if (start >= allListings.size()) {
            content = new ArrayList<>();
        } else {
            content = new ArrayList<>(allListings.subList(start, end));
        }
        
        int totalPages = (int) Math.ceil((double) totalElements / size);
        
        return new PagedResponse<>(
                content,
                page,
                size,
                totalElements,
                totalPages,
                page == 0,
                page >= totalPages - 1
        );
    }

    // Get only biddable listings (for bidding center)
    public PagedResponse<ListingDTO> getBiddableListings(int page, int size) {
        // Get all biddable listings (no pagination at DB level, we'll filter by bidEndTime)
        List<Listing> allBiddable = listingRepository.findByIsBiddableAndIsActive(true, true);
        List<ListingDTO> allBiddableDTOs = allBiddable.stream()
                .filter(l -> l.getBidEndTime() == null || l.getBidEndTime().isAfter(java.time.LocalDateTime.now()))
                .map(this::toDTO)
                .collect(Collectors.toList());
        
        // Apply pagination
        int totalElements = allBiddableDTOs.size();
        int start = page * size;
        int end = Math.min(start + size, allBiddableDTOs.size());
        
        List<ListingDTO> content;
        if (start >= allBiddableDTOs.size()) {
            content = new ArrayList<>();
        } else {
            content = new ArrayList<>(allBiddableDTOs.subList(start, end));
        }
        
        int totalPages = (int) Math.ceil((double) totalElements / size);
        
        return new PagedResponse<>(
                content,
                page,
                size,
                totalElements,
                totalPages,
                page == 0,
                page >= totalPages - 1
        );
    }

    public List<ListingDTO> getUserListings(String userId, Boolean activeOnly) {
        List<Listing> listings;
        if (activeOnly != null && activeOnly) {
            listings = listingRepository.findByUserIdAndIsActive(userId, true);
        } else {
            // When activeOnly is false or null, return ALL listings (both active and inactive)
            listings = listingRepository.findByUserId(userId);
        }
        // Fetch moderation logs for all listings to populate moderation status
        List<String> listingIds = listings.stream().map(Listing::getListingId).collect(Collectors.toList());
        List<ModerationLog> moderationLogs = new ArrayList<>();
        if (!listingIds.isEmpty()) {
            // Fetch moderation logs in batches to avoid loading too many at once
            for (String listingId : listingIds) {
                moderationLogRepository.findByListingId(listingId).ifPresent(moderationLogs::add);
            }
        }
        
        // Create a map of listingId -> ModerationLog for quick lookup
        java.util.Map<String, ModerationLog> moderationMap = moderationLogs.stream()
                .collect(Collectors.toMap(ModerationLog::getListingId, log -> log, (existing, replacement) -> existing));
        
        return listings.stream().map(listing -> {
            ListingDTO dto = toDTO(listing);
            ModerationLog log = moderationMap.get(listing.getListingId());
            if (log != null && log.getShouldFlag() != null && log.getShouldFlag()) {
                // Only mark as moderated if it was actually flagged (shouldFlag = true)
                dto.setHasModerationLog(true);
                dto.setIsModeratedPending(log.getAdminAction() == ModerationLog.AdminAction.PENDING);
            } else {
                // No moderation log or not flagged
                dto.setHasModerationLog(false);
                dto.setIsModeratedPending(false);
            }
            return dto;
        }).collect(Collectors.toList());
    }

    public List<ListingDTO> searchListings(String query) {
        return listingRepository.searchListings(query).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public PagedResponse<ListingDTO> searchListings(String query, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Listing> listingPage = listingRepository.searchListings(query, pageable);
        List<ListingDTO> content = listingPage.getContent().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        return new PagedResponse<>(
                content,
                listingPage.getNumber(),
                listingPage.getSize(),
                (int) listingPage.getTotalElements(),
                listingPage.getTotalPages(),
                listingPage.isFirst(),
                listingPage.isLast()
        );
    }

    public List<ListingDTO> getListingsByCategory(String category) {
        return listingRepository.findByCategoryAndIsActive(category, true).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public PagedResponse<ListingDTO> getListingsByCategory(String category, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Listing> listingPage = listingRepository.findByCategoryAndIsActiveOrderByCreatedAtDesc(category, true, pageable);
        List<ListingDTO> content = listingPage.getContent().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        return new PagedResponse<>(
                content,
                listingPage.getNumber(),
                listingPage.getSize(),
                (int) listingPage.getTotalElements(),
                listingPage.getTotalPages(),
                listingPage.isFirst(),
                listingPage.isLast()
        );
    }

    // Search non-biddable listings only
    public PagedResponse<ListingDTO> searchNonBiddableListings(String query, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Listing> listingPage = listingRepository.searchNonBiddableListings(query, pageable);
        List<ListingDTO> content = listingPage.getContent().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        
        // Get total count for non-biddable search results
        long totalNonBiddable = listingRepository.searchNonBiddableListings(query).size();
        
        int totalPages = (int) Math.ceil((double) totalNonBiddable / size);
        
        return new PagedResponse<>(
                content,
                page,
                size,
                (int) totalNonBiddable,
                totalPages,
                page == 0,
                page >= totalPages - 1
        );
    }

    // Search by category for non-biddable listings only
    public PagedResponse<ListingDTO> getNonBiddableListingsByCategory(String category, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Listing> listingPage = listingRepository.findNonBiddableByCategoryAndIsActiveOrderByCreatedAtDesc(category, pageable);
        List<ListingDTO> content = listingPage.getContent().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        
        // Get total count for non-biddable category results
        long totalNonBiddable = listingRepository.findNonBiddableByCategoryAndIsActive(category).size();
        
        int totalPages = (int) Math.ceil((double) totalNonBiddable / size);
        
        return new PagedResponse<>(
                content,
                page,
                size,
                (int) totalNonBiddable,
                totalPages,
                page == 0,
                page >= totalPages - 1
        );
    }

    @Transactional
    public ListingDTO updateListing(String userId, String listingId, ListingCreateDTO updateDTO) {
        Listing listing = listingRepository.findById(listingId)
                .orElseThrow(() -> new ResourceNotFoundException("Listing not found"));

        if (!listing.getUserId().equals(userId)) {
            throw new BadRequestException("You can only update your own listings");
        }

        listing.setTitle(updateDTO.getTitle());
        listing.setDescription(updateDTO.getDescription());
        listing.setPrice(updateDTO.getPrice());
        listing.setIsTradeable(updateDTO.getIsTradeable());
        listing.setIsBiddable(updateDTO.getIsBiddable());
        listing.setCategory(updateDTO.getCategory());

        listing = listingRepository.save(listing);

        listingTagRepository.deleteByListingId(listingId);
        if (updateDTO.getTags() != null) {
            for (String tag : updateDTO.getTags()) {
                ListingTag listingTag = new ListingTag();
                listingTag.setListingId(listingId);
                listingTag.setTag(tag);
                listingTagRepository.save(listingTag);
            }
        }

        return toDTO(listing);
    }

    @Transactional
    public void deactivateListing(String userId, String listingId) {
        Listing listing = listingRepository.findById(listingId)
                .orElseThrow(() -> new ResourceNotFoundException("Listing not found"));

        if (!listing.getUserId().equals(userId)) {
            throw new BadRequestException("You can only deactivate your own listings");
        }

        listing.setIsActive(false);
        listingRepository.save(listing);
    }

    @Transactional
    public void deleteListing(String userId, String listingId) {
        Listing listing = listingRepository.findById(listingId)
                .orElseThrow(() -> new ResourceNotFoundException("Listing not found"));

        if (!listing.getUserId().equals(userId)) {
            throw new BadRequestException("You can only delete your own listings");
        }

        // Delete associated images
        listingImageRepository.deleteByListingId(listingId);
        
        // Delete associated tags
        listingTagRepository.deleteByListingId(listingId);
        
        // Delete associated bids (if any)
        bidRepository.deleteByListingId(listingId);
        
        // Delete the listing itself
        listingRepository.delete(listing);
    }

    @Transactional
    public void addImages(String listingId, List<String> imageUrls, Authentication authentication) {
        Listing listing = listingRepository.findById(listingId)
                .orElseThrow(() -> new ResourceNotFoundException("Listing not found"));

        int order = listingImageRepository.findByListingIdOrderByDisplayOrderAsc(listingId).size();
        for (String imageUrl : imageUrls) {
            ListingImage image = new ListingImage();
            image.setListingId(listingId);
            image.setImageUrl(imageUrl);
            image.setDisplayOrder(order++);
            listingImageRepository.save(image);
        }
        
        // Trigger moderation check after images are added (if mandatory moderation is enabled)
        boolean mandatoryModerationEnabled = appSettingService != null && 
            appSettingService.isMandatoryModerationEnabled();
        
        if (mandatoryModerationEnabled && moderationService != null && authentication != null) {
            try {
                com.tradenbysell.dto.ModerationResponseDTO moderationResult = 
                    moderationService.moderateListing(listingId, authentication);
                
                // If flagged, deactivate listing automatically
                if (moderationResult != null && moderationResult.getShould_flag() != null && 
                    moderationResult.getShould_flag()) {
                    listing.setIsActive(false);
                    listingRepository.save(listing);
                }
            } catch (Exception e) {
                // Log error but don't fail listing creation if moderation fails
                System.err.println("Error during moderation check: " + e.getMessage());
            }
        }
    }

    private ListingDTO toDTO(Listing listing) {
        ListingDTO dto = new ListingDTO();
        dto.setListingId(listing.getListingId());
        dto.setUserId(listing.getUserId());

        User seller = userRepository.findById(listing.getUserId()).orElse(null);
        if (seller != null) {
            dto.setSellerName(seller.getFullName());
            dto.setSellerTrustScore(seller.getTrustScore());
        }

        dto.setTitle(listing.getTitle());
        dto.setDescription(listing.getDescription());
        dto.setPrice(listing.getPrice());
        dto.setIsTradeable(listing.getIsTradeable());
        dto.setIsBiddable(listing.getIsBiddable());
        dto.setStartingPrice(listing.getStartingPrice());
        dto.setBidIncrement(listing.getBidIncrement());
        dto.setBidStartTime(listing.getBidStartTime());
        dto.setBidEndTime(listing.getBidEndTime());
        dto.setIsActive(listing.getIsActive());
        dto.setIsFeatured(listing.getIsFeatured() != null && listing.getIsFeatured());
        dto.setFeaturedUntil(listing.getFeaturedUntil());
        dto.setFeaturedType(listing.getFeaturedType());
        dto.setCategory(listing.getCategory());
        dto.setCreatedAt(listing.getCreatedAt());
        dto.setUpdatedAt(listing.getUpdatedAt());

        List<String> imageUrls = listingImageRepository.findByListingIdOrderByDisplayOrderAsc(listing.getListingId())
                .stream().map(ListingImage::getImageUrl).collect(Collectors.toList());
        dto.setImageUrls(imageUrls);

        List<String> tags = listingTagRepository.findByListingId(listing.getListingId())
                .stream().map(ListingTag::getTag).collect(Collectors.toList());
        dto.setTags(tags);

        Bid highestBid = bidRepository.findTopByListingIdOrderByBidAmountDescBidTimeAsc(listing.getListingId()).orElse(null);
        List<Bid> allBids = bidRepository.findByListingIdOrderByBidAmountDescBidTimeAsc(listing.getListingId());
        
        if (highestBid != null) {
            dto.setHighestBid(highestBid.getBidAmount());
        }
        
        // Always set bid count, even if 0
        dto.setBidCount((long) allBids.size());

        return dto;
    }
}
