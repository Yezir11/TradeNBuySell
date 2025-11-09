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
import com.tradenbysell.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    @Transactional
    public ListingDTO createListing(String userId, ListingCreateDTO createDTO) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

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

        if (createDTO.getTags() != null) {
            for (String tag : createDTO.getTags()) {
                ListingTag listingTag = new ListingTag();
                listingTag.setListingId(listing.getListingId());
                listingTag.setTag(tag);
                listingTagRepository.save(listingTag);
            }
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
        Pageable pageable = PageRequest.of(page, size);
        Page<Listing> listingPage = listingRepository.findByIsActiveOrderByCreatedAtDesc(true, pageable);
        List<ListingDTO> content = listingPage.getContent().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        return new PagedResponse<>(
                content,
                listingPage.getNumber(),
                listingPage.getSize(),
                listingPage.getTotalElements(),
                listingPage.getTotalPages(),
                listingPage.isFirst(),
                listingPage.isLast()
        );
    }

    public List<ListingDTO> getUserListings(String userId, Boolean activeOnly) {
        List<Listing> listings;
        if (activeOnly != null && activeOnly) {
            listings = listingRepository.findByUserIdAndIsActive(userId, true);
        } else {
            listings = listingRepository.findByUserIdAndIsActive(userId, false);
        }
        return listings.stream().map(this::toDTO).collect(Collectors.toList());
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
                listingPage.getTotalElements(),
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
                listingPage.getTotalElements(),
                listingPage.getTotalPages(),
                listingPage.isFirst(),
                listingPage.isLast()
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
    public void addImages(String listingId, List<String> imageUrls) {
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
        if (highestBid != null) {
            dto.setHighestBid(highestBid.getBidAmount());
            dto.setBidCount((long) bidRepository.findByListingIdOrderByBidAmountDescBidTimeAsc(listing.getListingId()).size());
        }

        return dto;
    }
}

