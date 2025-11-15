package com.tradenbysell.service;

import com.tradenbysell.dto.TradeDTO;
import com.tradenbysell.exception.BadRequestException;
import com.tradenbysell.exception.InsufficientFundsException;
import com.tradenbysell.exception.ResourceNotFoundException;
import com.tradenbysell.model.Listing;
import com.tradenbysell.model.Trade;
import com.tradenbysell.model.User;
import com.tradenbysell.repository.ListingRepository;
import com.tradenbysell.repository.TradeOfferingRepository;
import com.tradenbysell.repository.TradeRepository;
import com.tradenbysell.repository.UserRepository;
import com.tradenbysell.util.TestDataBuilder;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TradeServiceTest {

    @Mock
    private TradeRepository tradeRepository;

    @Mock
    private TradeOfferingRepository tradeOfferingRepository;

    @Mock
    private ListingRepository listingRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private WalletService walletService;

    @InjectMocks
    private TradeService tradeService;

    private User initiator;
    private User recipient;
    private Listing requestedListing;
    private Listing offeringListing;

    @BeforeEach
    void setUp() {
        initiator = TestDataBuilder.createTestUser();
        initiator.setUserId("initiator-id");
        initiator.setTrustScore(5.0f);
        
        recipient = TestDataBuilder.createTestUser();
        recipient.setUserId("recipient-id");
        recipient.setEmail("recipient@pilani.bits-pilani.ac.in");
        recipient.setTrustScore(4.0f);
        
        requestedListing = TestDataBuilder.createTradeableListing(recipient);
        requestedListing.setListingId("requested-id");
        
        offeringListing = TestDataBuilder.createTradeableListing(initiator);
        offeringListing.setListingId("offering-id");
    }

    @Test
    void createTrade_ValidTrade_CreatesTrade() {
        // Given
        List<String> offeringIds = Arrays.asList("offering-id");
        BigDecimal cashAdjustment = new BigDecimal("50.00");
        
        when(listingRepository.findById("requested-id")).thenReturn(Optional.of(requestedListing));
        when(userRepository.findById("recipient-id")).thenReturn(Optional.of(recipient));
        when(listingRepository.findById("offering-id")).thenReturn(Optional.of(offeringListing));
        when(walletService.getBalance("initiator-id")).thenReturn(new BigDecimal("1000.00"));
        when(tradeRepository.save(any(Trade.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(tradeOfferingRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

        // When
        TradeDTO result = tradeService.createTrade("initiator-id", "requested-id", offeringIds, cashAdjustment);

        // Then
        assertNotNull(result);
        verify(tradeRepository).save(any(Trade.class));
        verify(tradeOfferingRepository).save(any());
    }

    @Test
    void createTrade_ListingNotFound_ThrowsResourceNotFoundException() {
        // Given
        when(listingRepository.findById("nonexistent")).thenReturn(Optional.empty());

        // When & Then
        assertThrows(ResourceNotFoundException.class, 
            () -> tradeService.createTrade("initiator-id", "nonexistent", Arrays.asList("offering-id"), null));
    }

    @Test
    void createTrade_NotTradeable_ThrowsBadRequestException() {
        // Given
        Listing nonTradeable = TestDataBuilder.createTestListing(recipient);
        when(listingRepository.findById("requested-id")).thenReturn(Optional.of(nonTradeable));

        // When & Then
        assertThrows(BadRequestException.class, 
            () -> tradeService.createTrade("initiator-id", "requested-id", Arrays.asList("offering-id"), null));
    }

    @Test
    void createTrade_TradeWithOwnListing_ThrowsBadRequestException() {
        // Given
        Listing ownListing = TestDataBuilder.createTradeableListing(initiator);
        when(listingRepository.findById("requested-id")).thenReturn(Optional.of(ownListing));

        // When & Then
        assertThrows(BadRequestException.class, 
            () -> tradeService.createTrade("initiator-id", "requested-id", Arrays.asList("offering-id"), null));
    }

    @Test
    void createTrade_LowTrustScore_ThrowsBadRequestException() {
        // Given
        recipient.setTrustScore(2.0f);
        when(listingRepository.findById("requested-id")).thenReturn(Optional.of(requestedListing));
        when(userRepository.findById("recipient-id")).thenReturn(Optional.of(recipient));

        // When & Then
        assertThrows(BadRequestException.class, 
            () -> tradeService.createTrade("initiator-id", "requested-id", Arrays.asList("offering-id"), null));
    }

    @Test
    void createTrade_InsufficientFunds_ThrowsInsufficientFundsException() {
        // Given
        BigDecimal cashAdjustment = new BigDecimal("2000.00");
        when(listingRepository.findById("requested-id")).thenReturn(Optional.of(requestedListing));
        when(userRepository.findById("recipient-id")).thenReturn(Optional.of(recipient));
        when(walletService.getBalance("initiator-id")).thenReturn(new BigDecimal("100.00"));

        // When & Then
        assertThrows(InsufficientFundsException.class, 
            () -> tradeService.createTrade("initiator-id", "requested-id", Arrays.asList("offering-id"), cashAdjustment));
    }
}

