package com.tradenbysell.controller;

import com.tradenbysell.dto.ChatMessageDTO;
import com.tradenbysell.service.ChatService;
import com.tradenbysell.util.AuthUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chat")
@CrossOrigin(origins = "*")
public class ChatController {

    @Autowired
    private AuthUtil authUtil;
    @Autowired
    private ChatService chatService;

    @PostMapping("/send")
    public ResponseEntity<ChatMessageDTO> sendMessage(@RequestBody SendMessageRequest request,
                                                      Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        ChatMessageDTO message = chatService.sendMessage(userId, request.getReceiverId(),
                request.getMessageText(), request.getListingId());
        return ResponseEntity.ok(message);
    }

    @GetMapping("/conversation")
    public ResponseEntity<List<ChatMessageDTO>> getConversation(@RequestParam String userId2,
                                                                 Authentication authentication) {
        String userId1 = authUtil.getUserId(authentication);
        List<ChatMessageDTO> messages = chatService.getConversation(userId1, userId2);
        return ResponseEntity.ok(messages);
    }

    @GetMapping("/conversations")
    public ResponseEntity<List<ChatMessageDTO>> getUserConversations(Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        List<ChatMessageDTO> messages = chatService.getUserConversations(userId);
        return ResponseEntity.ok(messages);
    }

    @GetMapping("/listing/{listingId}")
    public ResponseEntity<List<ChatMessageDTO>> getListingMessages(@PathVariable String listingId) {
        List<ChatMessageDTO> messages = chatService.getListingMessages(listingId);
        return ResponseEntity.ok(messages);
    }

    @PostMapping("/message/{messageId}/report")
    public ResponseEntity<Void> reportMessage(@PathVariable Long messageId,
                                              @RequestBody ReportMessageRequest request,
                                              Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        chatService.reportMessage(userId, messageId, request.getReason());
        return ResponseEntity.ok().build();
    }
    
    @GetMapping("/unread-count")
    public ResponseEntity<UnreadCountResponse> getUnreadCount(Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        Long count = chatService.getUnreadMessageCount(userId);
        return ResponseEntity.ok(new UnreadCountResponse(count));
    }

    public static class SendMessageRequest {
        private String receiverId;
        private String messageText;
        private String listingId;

        public String getReceiverId() {
            return receiverId;
        }

        public void setReceiverId(String receiverId) {
            this.receiverId = receiverId;
        }

        public String getMessageText() {
            return messageText;
        }

        public void setMessageText(String messageText) {
            this.messageText = messageText;
        }

        public String getListingId() {
            return listingId;
        }

        public void setListingId(String listingId) {
            this.listingId = listingId;
        }
    }

    public static class ReportMessageRequest {
        private String reason;

        public String getReason() {
            return reason;
        }

        public void setReason(String reason) {
            this.reason = reason;
        }
    }
    
    public static class UnreadCountResponse {
        private Long unreadCount;
        
        public UnreadCountResponse() {}
        
        public UnreadCountResponse(Long unreadCount) {
            this.unreadCount = unreadCount;
        }
        
        public Long getUnreadCount() {
            return unreadCount;
        }
        
        public void setUnreadCount(Long unreadCount) {
            this.unreadCount = unreadCount;
        }
    }
}

