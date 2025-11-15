package com.tradenbysell.service;

import com.tradenbysell.dto.BidDTO;
import com.tradenbysell.exception.BadRequestException;
import com.tradenbysell.exception.ResourceNotFoundException;
import com.tradenbysell.model.Bid;
import com.tradenbysell.model.Listing;
import com.tradenbysell.model.User;
import com.tradenbysell.repository.BidRepository;
import com.tradenbysell.repository.ListingRepository;
import com.tradenbysell.repository.UserRepository;
import com.tradenbysell.util.TestDataBuilder;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class BidServiceTest {

    @Mock
    private BidRepository bidRepository;

    @Mock
    private ListingRepository listingRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private WalletService walletService;

    @InjectMocks
    private BidService bidService;

    private User seller;
    private User bidder;
    private Listing biddableListing;

    @BeforeEach
    void setUp() {
        seller = TestDataBuilder.createTestUser();
        seller.setUserId("seller-id");
        
        bidder = TestDataBuilder.createTestUser();
        bidder.setUserId("bidder-id");
        bidder.setEmail("bidder@pilani.bits-pilani.ac.in");
        
        biddableListing = TestDataBuilder.createBiddableListing(seller);
        biddableListing.setListingId("listing-id");
    }

    @Test
    void placeBid_ValidBid_PlacesBid() {
        // Given
        BigDecimal bidAmount = new BigDecimal("60.00");
        when(listingRepository.findById("listing-id")).thenReturn(Optional.of(biddableListing));
        when(bidRepository.findTopByListingIdOrderByBidAmountDescBidTimeAsc("listing-id"))
                .thenReturn(Optional.empty());
        when(bidRepository.save(any(Bid.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(walletService.getBalance("bidder-id")).thenReturn(new BigDecimal("1000.00"));
        when(walletService.holdFunds(anyString(), any(BigDecimal.class), anyString()))
                .thenReturn(new com.tradenbysell.dto.WalletTransactionDTO());
        // releaseFunds is only called if there's an existing highest bid, which we don't have in this test

        // When
        BidDTO result = bidService.placeBid("bidder-id", "listing-id", bidAmount);

        // Then
        assertNotNull(result);
        assertEquals(bidAmount, result.getBidAmount());
        verify(bidRepository).save(any(Bid.class));
        verify(walletService).holdFunds(anyString(), any(BigDecimal.class), anyString());
    }

    @Test
    void placeBid_ListingNotFound_ThrowsResourceNotFoundException() {
        // Given
        when(listingRepository.findById("nonexistent")).thenReturn(Optional.empty());

        // When & Then
        assertThrows(ResourceNotFoundException.class, 
            () -> bidService.placeBid("bidder-id", "nonexistent", new BigDecimal("60.00")));
        verify(bidRepository, never()).save(any(Bid.class));
    }

    @Test
    void placeBid_NotBiddable_ThrowsBadRequestException() {
        // Given
        Listing nonBiddable = TestDataBuilder.createTestListing(seller);
        when(listingRepository.findById("listing-id")).thenReturn(Optional.of(nonBiddable));

        // When & Then
        assertThrows(BadRequestException.class, 
            () -> bidService.placeBid("bidder-id", "listing-id", new BigDecimal("60.00")));
    }

    @Test
    void placeBid_BidOnOwnListing_ThrowsBadRequestException() {
        // Given
        when(listingRepository.findById("listing-id")).thenReturn(Optional.of(biddableListing));

        // When & Then
        assertThrows(BadRequestException.class, 
            () -> bidService.placeBid("seller-id", "listing-id", new BigDecimal("60.00")));
    }

    @Test
    void placeBid_BidLowerThanHighest_ThrowsBadRequestException() {
        // Given
        BigDecimal bidAmount = new BigDecimal("40.00");
        Bid existingBid = TestDataBuilder.createTestBid(bidder, biddableListing, new BigDecimal("50.00"));
        
        when(listingRepository.findById("listing-id")).thenReturn(Optional.of(biddableListing));
        when(bidRepository.findTopByListingIdOrderByBidAmountDescBidTimeAsc("listing-id"))
                .thenReturn(Optional.of(existingBid));

        // When & Then
        assertThrows(BadRequestException.class, 
            () -> bidService.placeBid("bidder-id", "listing-id", bidAmount));
        verify(bidRepository, never()).save(any(Bid.class));
    }

    @Test
    void placeBid_BidLowerThanStartingPrice_ThrowsBadRequestException() {
        // Given
        BigDecimal bidAmount = new BigDecimal("30.00");
        when(listingRepository.findById("listing-id")).thenReturn(Optional.of(biddableListing));
        when(bidRepository.findTopByListingIdOrderByBidAmountDescBidTimeAsc("listing-id"))
                .thenReturn(Optional.empty());

        // When & Then
        assertThrows(BadRequestException.class, 
            () -> bidService.placeBid("bidder-id", "listing-id", bidAmount));
    }
}

