package com.tradenbysell.service;

import com.tradenbysell.dto.WalletTransactionDTO;
import com.tradenbysell.exception.InsufficientFundsException;
import com.tradenbysell.exception.ResourceNotFoundException;
import com.tradenbysell.model.User;
import com.tradenbysell.model.WalletTransaction;
import com.tradenbysell.repository.UserRepository;
import com.tradenbysell.repository.WalletTransactionRepository;
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
class WalletServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private WalletTransactionRepository walletTransactionRepository;

    @InjectMocks
    private WalletService walletService;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = TestDataBuilder.createTestUser();
        testUser.setWalletBalance(new BigDecimal("1000.00"));
    }

    @Test
    void getBalance_ValidUser_ReturnsBalance() {
        // Given
        when(userRepository.findById(testUser.getUserId())).thenReturn(Optional.of(testUser));

        // When
        BigDecimal balance = walletService.getBalance(testUser.getUserId());

        // Then
        assertEquals(new BigDecimal("1000.00"), balance);
        verify(userRepository).findById(testUser.getUserId());
    }

    @Test
    void getBalance_UserNotFound_ThrowsResourceNotFoundException() {
        // Given
        when(userRepository.findById("nonexistent")).thenReturn(Optional.empty());

        // When & Then
        assertThrows(ResourceNotFoundException.class, () -> walletService.getBalance("nonexistent"));
    }

    @Test
    void addFunds_ValidAmount_AddsFundsAndCreatesTransaction() {
        // Given
        BigDecimal amount = new BigDecimal("100.00");
        when(userRepository.findById(testUser.getUserId())).thenReturn(Optional.of(testUser));
        when(userRepository.save(any(User.class))).thenReturn(testUser);
        when(walletTransactionRepository.save(any(WalletTransaction.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        // When
        WalletTransactionDTO result = walletService.addFunds(testUser.getUserId(), amount, "Test topup");

        // Then
        assertNotNull(result);
        assertEquals(amount, result.getAmount());
        verify(userRepository).save(argThat(user -> 
            user.getWalletBalance().compareTo(new BigDecimal("1100.00")) == 0));
        verify(walletTransactionRepository).save(any(WalletTransaction.class));
    }

    @Test
    void addFunds_InvalidAmount_ThrowsIllegalArgumentException() {
        // Given
        BigDecimal invalidAmount = new BigDecimal("-10.00");

        // When & Then
        assertThrows(IllegalArgumentException.class, 
            () -> walletService.addFunds(testUser.getUserId(), invalidAmount, "Test"));
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void debitFunds_SufficientBalance_DeductsFunds() {
        // Given
        BigDecimal amount = new BigDecimal("100.00");
        when(userRepository.findById(testUser.getUserId())).thenReturn(Optional.of(testUser));
        when(userRepository.save(any(User.class))).thenReturn(testUser);
        when(walletTransactionRepository.save(any(WalletTransaction.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        // When
        WalletTransactionDTO result = walletService.debitFunds(
            testUser.getUserId(), 
            amount, 
            WalletTransaction.TransactionReason.PURCHASE,
            "ref-123",
            "Test purchase"
        );

        // Then
        assertNotNull(result);
        assertEquals(amount, result.getAmount());
        verify(userRepository).save(argThat(user -> 
            user.getWalletBalance().compareTo(new BigDecimal("900.00")) == 0));
    }

    @Test
    void debitFunds_InsufficientBalance_ThrowsInsufficientFundsException() {
        // Given
        BigDecimal amount = new BigDecimal("2000.00");
        when(userRepository.findById(testUser.getUserId())).thenReturn(Optional.of(testUser));

        // When & Then
        assertThrows(InsufficientFundsException.class, 
            () -> walletService.debitFunds(
                testUser.getUserId(), 
                amount, 
                WalletTransaction.TransactionReason.PURCHASE,
                "ref-123",
                "Test"
            ));
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void getTransactionHistory_ReturnsTransactions() {
        // Given
        WalletTransaction transaction1 = new WalletTransaction();
        transaction1.setAmount(new BigDecimal("100.00"));
        WalletTransaction transaction2 = new WalletTransaction();
        transaction2.setAmount(new BigDecimal("50.00"));
        
        when(walletTransactionRepository.findByUserIdOrderByTimestampDesc(testUser.getUserId()))
                .thenReturn(Arrays.asList(transaction1, transaction2));

        // When
        List<WalletTransactionDTO> history = walletService.getTransactionHistory(testUser.getUserId());

        // Then
        assertEquals(2, history.size());
        verify(walletTransactionRepository).findByUserIdOrderByTimestampDesc(testUser.getUserId());
    }
}

