package com.tradenbysell.repository;

import com.tradenbysell.model.WalletTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WalletTransactionRepository extends JpaRepository<WalletTransaction, Long> {
    List<WalletTransaction> findByUserIdOrderByTimestampDesc(String userId);
    List<WalletTransaction> findByUserIdAndTypeOrderByTimestampDesc(String userId, WalletTransaction.TransactionType type);
}

