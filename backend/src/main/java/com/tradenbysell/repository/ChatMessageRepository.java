package com.tradenbysell.repository;

import com.tradenbysell.model.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {
    List<ChatMessage> findBySenderIdAndReceiverIdOrderByTimestampAsc(String senderId, String receiverId);
    List<ChatMessage> findBySenderIdOrReceiverIdOrderByTimestampDesc(String senderId, String receiverId);
    List<ChatMessage> findByListingIdOrderByTimestampAsc(String listingId);
    Long countByReceiverIdAndIsReadFalse(String receiverId);
}

