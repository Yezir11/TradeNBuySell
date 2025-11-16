package com.tradenbysell.repository;

import com.tradenbysell.model.Notification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByUserIdOrderByCreatedAtDesc(String userId);
    
    Page<Notification> findByUserIdOrderByCreatedAtDesc(String userId, Pageable pageable);
    
    List<Notification> findByUserIdAndIsReadOrderByCreatedAtDesc(String userId, Boolean isRead);
    
    Page<Notification> findByUserIdAndIsReadOrderByCreatedAtDesc(String userId, Boolean isRead, Pageable pageable);
    
    Long countByUserIdAndIsRead(String userId, Boolean isRead);
    
    @Query("SELECT COUNT(n) FROM Notification n WHERE n.userId = :userId AND n.isRead = false")
    Long countUnreadByUserId(@Param("userId") String userId);
    
    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true, n.readAt = :readAt WHERE n.userId = :userId AND n.isRead = false")
    int markAllAsReadByUserId(@Param("userId") String userId, @Param("readAt") LocalDateTime readAt);
    
    @Modifying
    @Query("DELETE FROM Notification n WHERE n.userId = :userId AND n.createdAt < :beforeDate")
    int deleteOldNotifications(@Param("userId") String userId, @Param("beforeDate") LocalDateTime beforeDate);
    
    List<Notification> findByUserIdAndTypeOrderByCreatedAtDesc(String userId, Notification.NotificationType type);
    
    List<Notification> findByUserIdAndPriorityOrderByCreatedAtDesc(String userId, Notification.Priority priority);
}

