package com.tradenbysell.service;

import com.tradenbysell.dto.WalletTransactionDTO;
import com.tradenbysell.exception.InsufficientFundsException;
import com.tradenbysell.exception.ResourceNotFoundException;
import com.tradenbysell.model.User;
import com.tradenbysell.model.WalletTransaction;
import com.tradenbysell.repository.UserRepository;
import com.tradenbysell.repository.WalletTransactionRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class WalletService {
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private WalletTransactionRepository walletTransactionRepository;
    
    @PersistenceContext
    private EntityManager entityManager;
    
    @Autowired(required = false)
    private NotificationService notificationService;

    public BigDecimal getBalance(String userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return user.getWalletBalance();
    }

    public List<WalletTransactionDTO> getTransactionHistory(String userId) {
        return walletTransactionRepository.findByUserIdOrderByTimestampDesc(userId).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public WalletTransactionDTO addFunds(String userId, BigDecimal amount, String description) {
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        user.setWalletBalance(user.getWalletBalance().add(amount));
        userRepository.save(user);
        entityManager.flush(); // Force immediate persistence

        WalletTransaction transaction = new WalletTransaction();
        transaction.setUserId(userId);
        transaction.setAmount(amount);
        transaction.setType(WalletTransaction.TransactionType.CREDIT);
        transaction.setReason(WalletTransaction.TransactionReason.TOPUP);
        transaction.setDescription(description);
        transaction = walletTransactionRepository.save(transaction);

        return toDTO(transaction);
    }

    @Transactional
    public WalletTransactionDTO debitFunds(String userId, BigDecimal amount, 
                                           WalletTransaction.TransactionReason reason, 
                                           String referenceId, String description) {
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (user.getWalletBalance().compareTo(amount) < 0) {
            throw new InsufficientFundsException("Insufficient wallet balance");
        }

        user.setWalletBalance(user.getWalletBalance().subtract(amount));
        userRepository.save(user);
        entityManager.flush(); // Force immediate persistence

        WalletTransaction transaction = new WalletTransaction();
        transaction.setUserId(userId);
        transaction.setAmount(amount);
        transaction.setType(WalletTransaction.TransactionType.DEBIT);
        transaction.setReason(reason);
        transaction.setReferenceId(referenceId);
        transaction.setDescription(description);
        transaction = walletTransactionRepository.save(transaction);
        
        // Send notification for debit
        if (notificationService != null) {
            notificationService.notifyWalletDebited(userId, amount, reason.toString(), description);
        }

        return toDTO(transaction);
    }

    @Transactional
    public WalletTransactionDTO creditFunds(String userId, BigDecimal amount,
                                            WalletTransaction.TransactionReason reason,
                                            String referenceId, String description) {
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        user.setWalletBalance(user.getWalletBalance().add(amount));
        userRepository.save(user);
        entityManager.flush(); // Force immediate persistence

        WalletTransaction transaction = new WalletTransaction();
        transaction.setUserId(userId);
        transaction.setAmount(amount);
        transaction.setType(WalletTransaction.TransactionType.CREDIT);
        transaction.setReason(reason);
        transaction.setReferenceId(referenceId);
        transaction.setDescription(description);
        transaction = walletTransactionRepository.save(transaction);
        
        // Send notification for credit
        if (notificationService != null) {
            notificationService.notifyWalletCredited(userId, amount, reason.toString(), description);
        }

        return toDTO(transaction);
    }

    @Transactional
    public WalletTransactionDTO holdFunds(String userId, BigDecimal amount, String referenceId) {
        return debitFunds(userId, amount, WalletTransaction.TransactionReason.ESCROW_HOLD, referenceId, "Escrow hold");
    }

    @Transactional
    public WalletTransactionDTO releaseFunds(String userId, BigDecimal amount, String referenceId) {
        return creditFunds(userId, amount, WalletTransaction.TransactionReason.ESCROW_RELEASE, referenceId, "Escrow release");
    }

    private WalletTransactionDTO toDTO(WalletTransaction transaction) {
        WalletTransactionDTO dto = new WalletTransactionDTO();
        dto.setTransactionId(transaction.getTransactionId());
        dto.setUserId(transaction.getUserId());
        dto.setAmount(transaction.getAmount());
        dto.setType(transaction.getType());
        dto.setReason(transaction.getReason());
        dto.setReferenceId(transaction.getReferenceId());
        dto.setDescription(transaction.getDescription());
        dto.setTimestamp(transaction.getTimestamp());
        return dto;
    }
}

