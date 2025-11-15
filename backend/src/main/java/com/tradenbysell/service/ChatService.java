package com.tradenbysell.service;

import com.tradenbysell.dto.ChatMessageDTO;
import com.tradenbysell.exception.BadRequestException;
import com.tradenbysell.exception.ResourceNotFoundException;
import com.tradenbysell.model.ChatMessage;
import com.tradenbysell.model.Listing;
import com.tradenbysell.model.User;
import com.tradenbysell.repository.ChatMessageRepository;
import com.tradenbysell.repository.ListingRepository;
import com.tradenbysell.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ChatService {
    @Autowired
    private ChatMessageRepository chatMessageRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ListingRepository listingRepository;

    @Transactional
    public ChatMessageDTO sendMessage(String senderId, String receiverId, String messageText, String listingId) {
        if (senderId.equals(receiverId)) {
            throw new BadRequestException("Cannot send message to yourself");
        }

        User sender = userRepository.findById(senderId)
                .orElseThrow(() -> new ResourceNotFoundException("Sender not found"));

        User receiver = userRepository.findById(receiverId)
                .orElseThrow(() -> new ResourceNotFoundException("Receiver not found"));

        if (listingId != null) {
            Listing listing = listingRepository.findById(listingId)
                    .orElseThrow(() -> new ResourceNotFoundException("Listing not found"));
        }

        ChatMessage message = new ChatMessage();
        message.setSenderId(senderId);
        message.setReceiverId(receiverId);
        message.setListingId(listingId);
        message.setMessageText(messageText);
        message.setIsReported(false);
        message = chatMessageRepository.save(message);

        return toDTO(message);
    }

    public List<ChatMessageDTO> getConversation(String userId1, String userId2) {
        // Get messages in both directions
        List<ChatMessage> messages1 = chatMessageRepository.findBySenderIdAndReceiverIdOrderByTimestampAsc(userId1, userId2);
        List<ChatMessage> messages2 = chatMessageRepository.findBySenderIdAndReceiverIdOrderByTimestampAsc(userId2, userId1);
        
        List<ChatMessage> allMessages = new java.util.ArrayList<>();
        allMessages.addAll(messages1);
        allMessages.addAll(messages2);
        
        // Sort by timestamp
        allMessages.sort((m1, m2) -> m1.getTimestamp().compareTo(m2.getTimestamp()));
        
        return allMessages.stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public List<ChatMessageDTO> getUserConversations(String userId) {
        return chatMessageRepository.findBySenderIdOrReceiverIdOrderByTimestampDesc(userId, userId).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public List<ChatMessageDTO> getListingMessages(String listingId) {
        return chatMessageRepository.findByListingIdOrderByTimestampAsc(listingId).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public void reportMessage(String userId, Long messageId, String reason) {
        ChatMessage message = chatMessageRepository.findById(messageId)
                .orElseThrow(() -> new ResourceNotFoundException("Message not found"));

        if (!message.getSenderId().equals(userId) && !message.getReceiverId().equals(userId)) {
            throw new BadRequestException("You can only report messages in your conversations");
        }

        message.setIsReported(true);
        chatMessageRepository.save(message);
    }
    
    @Transactional
    public ChatMessageDTO sendOfferMessage(String senderId, String receiverId, String listingId, String offerId, String messageText) {
        ChatMessage message = new ChatMessage();
        message.setSenderId(senderId);
        message.setReceiverId(receiverId);
        message.setListingId(listingId);
        message.setOfferId(offerId);
        message.setMessageText(messageText);
        message.setMessageType("PURCHASE_OFFER");
        message.setIsReported(false);
        message = chatMessageRepository.save(message);
        return toDTO(message);
    }
    
    @Transactional
    public ChatMessageDTO sendOfferStatusMessage(String senderId, String receiverId, String listingId, String offerId, String messageType, String messageText) {
        ChatMessage message = new ChatMessage();
        message.setSenderId(senderId);
        message.setReceiverId(receiverId);
        message.setListingId(listingId);
        message.setOfferId(offerId);
        message.setMessageText(messageText);
        message.setMessageType(messageType);
        message.setIsReported(false);
        message = chatMessageRepository.save(message);
        return toDTO(message);
    }

    private ChatMessageDTO toDTO(ChatMessage message) {
        ChatMessageDTO dto = new ChatMessageDTO();
        dto.setMessageId(message.getMessageId());
        dto.setSenderId(message.getSenderId());
        dto.setReceiverId(message.getReceiverId());
        dto.setListingId(message.getListingId());
        dto.setMessageText(message.getMessageText());
        dto.setMessageType(message.getMessageType());
        dto.setOfferId(message.getOfferId());
        dto.setTimestamp(message.getTimestamp());
        dto.setIsReported(message.getIsReported());

        User sender = userRepository.findById(message.getSenderId()).orElse(null);
        if (sender != null) {
            dto.setSenderName(sender.getFullName());
        }

        User receiver = userRepository.findById(message.getReceiverId()).orElse(null);
        if (receiver != null) {
            dto.setReceiverName(receiver.getFullName());
        }

        if (message.getListingId() != null) {
            Listing listing = listingRepository.findById(message.getListingId()).orElse(null);
            if (listing != null) {
                dto.setListingTitle(listing.getTitle());
            }
        }

        return dto;
    }
}

