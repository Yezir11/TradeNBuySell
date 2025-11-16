import React, { useState, useEffect, useRef, useCallback } from 'react';
import { useAuth } from '../context/AuthContext';
import api from '../services/api';
import './NotificationBell.css';

const NotificationBell = () => {
  const { isAuthenticated, user } = useAuth();
  const [isOpen, setIsOpen] = useState(false);
  const [notifications, setNotifications] = useState([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const [loading, setLoading] = useState(false);
  const dropdownRef = useRef(null);

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setIsOpen(false);
      }
    };

    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
      return () => {
        document.removeEventListener('mousedown', handleClickOutside);
      };
    }
  }, [isOpen]);

  const fetchNotifications = useCallback(async (showLoading = false) => {
    if (!isAuthenticated || !user) {
      setUnreadCount(0);
      setNotifications([]);
      return;
    }

    // Don't fetch if tab is hidden (performance optimization)
    if (document.hidden) {
      return;
    }

    try {
      if (showLoading) {
        setLoading(true);
      }
      const [notificationsResponse, countResponse] = await Promise.all([
        api.get('/api/notifications?page=0&size=10'),
        api.get('/api/notifications/unread-count')
      ]);
      
      setNotifications(notificationsResponse.data.content || []);
      setUnreadCount(countResponse.data.unreadCount || 0);
    } catch (err) {
      console.error('Failed to fetch notifications:', err);
    } finally {
      if (showLoading) {
        setLoading(false);
      }
    }
  }, [isAuthenticated, user]);

  // Fetch notifications and unread count on mount and periodically
  useEffect(() => {
    if (!isAuthenticated || !user) {
      setUnreadCount(0);
      setNotifications([]);
      return;
    }

    fetchNotifications(true);
    
    // Poll every 30 seconds for new notifications (reduced from 15s)
    const interval = setInterval(() => {
      if (!document.hidden) {
        fetchNotifications(false);
      }
    }, 30000);
    
    // Fetch when tab becomes visible
    const handleVisibilityChange = () => {
      if (!document.hidden) {
        fetchNotifications(false);
      }
    };
    
    document.addEventListener('visibilitychange', handleVisibilityChange);
    
    return () => {
      clearInterval(interval);
      document.removeEventListener('visibilitychange', handleVisibilityChange);
    };
  }, [isAuthenticated, user, fetchNotifications]);

  // Refresh when dropdown opens
  useEffect(() => {
    if (isOpen && isAuthenticated && !document.hidden) {
      fetchNotifications(false);
    }
  }, [isOpen, isAuthenticated, fetchNotifications]);

  const handleMarkAsRead = async (notificationId, e) => {
    e.stopPropagation();
    try {
      await api.put(`/api/notifications/${notificationId}/read`);
      setNotifications(prev => 
        prev.map(n => n.notificationId === notificationId 
          ? { ...n, isRead: true } 
          : n
        )
      );
      setUnreadCount(prev => Math.max(0, prev - 1));
    } catch (err) {
      console.error('Failed to mark notification as read:', err);
    }
  };

  const handleMarkAllAsRead = async (e) => {
    e.stopPropagation();
    try {
      await api.put('/api/notifications/read-all');
      setNotifications(prev => prev.map(n => ({ ...n, isRead: true })));
      setUnreadCount(0);
    } catch (err) {
      console.error('Failed to mark all as read:', err);
    }
  };

  const handleDelete = async (notificationId, e) => {
    e.stopPropagation();
    try {
      await api.delete(`/api/notifications/${notificationId}`);
      setNotifications(prev => prev.filter(n => n.notificationId !== notificationId));
      // Update unread count if it was unread
      const notification = notifications.find(n => n.notificationId === notificationId);
      if (notification && !notification.isRead) {
        setUnreadCount(prev => Math.max(0, prev - 1));
      }
    } catch (err) {
      console.error('Failed to delete notification:', err);
    }
  };

  const getPriorityClass = (priority) => {
    switch (priority) {
      case 'HIGH':
        return 'priority-high';
      case 'MEDIUM':
        return 'priority-medium';
      case 'LOW':
        return 'priority-low';
      default:
        return '';
    }
  };

  const formatTime = (timestamp) => {
    const date = new Date(timestamp);
    const now = new Date();
    const diffMs = now - date;
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    if (diffHours < 24) return `${diffHours}h ago`;
    if (diffDays < 7) return `${diffDays}d ago`;
    return date.toLocaleDateString();
  };

  if (!isAuthenticated) {
    return null;
  }

  return (
    <div className="notification-bell-container" ref={dropdownRef}>
      <button 
        className="notification-bell-button"
        onClick={() => setIsOpen(!isOpen)}
        aria-label="Notifications"
      >
        <i className="fas fa-bell"></i>
        {unreadCount > 0 && (
          <span className="notification-badge">{unreadCount > 99 ? '99+' : unreadCount}</span>
        )}
      </button>

      {isOpen && (
        <div className="notification-dropdown">
          <div className="notification-dropdown-header">
            <h3>Notifications</h3>
            {unreadCount > 0 && (
              <button 
                className="mark-all-read-btn"
                onClick={handleMarkAllAsRead}
              >
                Mark all as read
              </button>
            )}
          </div>

          <div className="notification-list">
            {loading ? (
              <div className="notification-loading">Loading...</div>
            ) : notifications.length === 0 ? (
              <div className="notification-empty">No notifications</div>
            ) : (
              notifications.map(notification => (
                <div 
                  key={notification.notificationId}
                  className={`notification-item ${!notification.isRead ? 'unread' : ''} ${getPriorityClass(notification.priority)}`}
                >
                  <div className="notification-content">
                    <div className="notification-header-row">
                      <h4 className="notification-title">{notification.title}</h4>
                      {!notification.isRead && (
                        <button
                          className="mark-read-btn"
                          onClick={(e) => handleMarkAsRead(notification.notificationId, e)}
                          title="Mark as read"
                        >
                          <i className="fas fa-check"></i>
                        </button>
                      )}
                      <button
                        className="delete-notification-btn"
                        onClick={(e) => handleDelete(notification.notificationId, e)}
                        title="Delete"
                      >
                        <i className="fas fa-times"></i>
                      </button>
                    </div>
                    <p className="notification-message">{notification.message}</p>
                    <div className="notification-footer">
                      <span className="notification-time">{formatTime(notification.createdAt)}</span>
                      {notification.priority === 'HIGH' && (
                        <span className="priority-indicator">High Priority</span>
                      )}
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>

          {notifications.length >= 10 && (
            <div className="notification-dropdown-footer">
              <span className="notification-footer-text">
                Showing latest 10 notifications
              </span>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default NotificationBell;

