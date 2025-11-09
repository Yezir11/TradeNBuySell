import React, { useState, useEffect, useRef } from 'react';
import { useSearchParams, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import api from '../services/api';
import Navigation from '../components/Navigation';
import './ChatPage.css';

const ChatPage = () => {
  const { user } = useAuth();
  const [searchParams] = useSearchParams();
  const userIdParam = searchParams.get('userId');
  const listingIdParam = searchParams.get('listingId');
  
  const [conversations, setConversations] = useState([]);
  const [activeConversation, setActiveConversation] = useState(null);
  const [messages, setMessages] = useState([]);
  const [messageText, setMessageText] = useState('');
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);
  const messagesEndRef = useRef(null);
  const messagesRef = useRef(null);

  useEffect(() => {
    fetchConversations();
    if (userIdParam) {
      loadConversation(userIdParam, listingIdParam);
    }
  }, [userIdParam, listingIdParam]);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  useEffect(() => {
    if (activeConversation) {
      const interval = setInterval(() => {
        fetchMessages(activeConversation);
      }, 3000);
      return () => clearInterval(interval);
    }
  }, [activeConversation]);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const fetchConversations = async () => {
    try {
      const response = await api.get('/api/chat/conversations');
      setConversations(response.data);
    } catch (err) {
      console.error('Failed to fetch conversations:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchMessages = async (conversationUserId) => {
    try {
      const response = await api.get(`/api/chat/conversation?userId2=${conversationUserId}`);
      setMessages(response.data);
    } catch (err) {
      console.error('Failed to fetch messages:', err);
    }
  };

  const loadConversation = async (userId, listingId) => {
    setActiveConversation(userId);
    await fetchMessages(userId);
  };

  const handleSendMessage = async (e) => {
    e.preventDefault();
    if (!messageText.trim() || !activeConversation) return;

    setSending(true);
    try {
      await api.post('/api/chat/send', {
        receiverId: activeConversation,
        messageText: messageText.trim(),
        listingId: listingIdParam || null
      });
      setMessageText('');
      await fetchMessages(activeConversation);
      await fetchConversations();
    } catch (err) {
      console.error('Failed to send message:', err);
      alert('Failed to send message');
    } finally {
      setSending(false);
    }
  };

  const getConversationPartner = (message) => {
    return message.senderId === user?.userId ? message.receiverName : message.senderName;
  };

  const getConversationTitle = (conversation) => {
    if (conversation.senderId === user?.userId) {
      return conversation.receiverName;
    }
    return conversation.senderName;
  };

  if (loading) {
    return (
      <>
        <Navigation />
        <div className="chat-page">Loading...</div>
      </>
    );
  }

  return (
    <>
      <Navigation />
      <div className="chat-page">
        <div className="chat-container">
          <div className="conversations-sidebar">
            <h2>Conversations</h2>
            <div className="conversations-list">
              {conversations.length === 0 ? (
                <div className="no-conversations">No conversations yet</div>
              ) : (
                conversations.map((conv, index) => {
                  const partnerId = conv.senderId === user?.userId ? conv.receiverId : conv.senderId;
                  const partnerName = conv.senderId === user?.userId ? conv.receiverName : conv.senderName;
                  const isActive = activeConversation === partnerId;
                  return (
                    <div
                      key={index}
                      className={`conversation-item ${isActive ? 'active' : ''}`}
                      onClick={() => loadConversation(partnerId, conv.listingId)}
                    >
                      <div className="conversation-info">
                        <h4>{partnerName}</h4>
                        {conv.listingTitle && (
                          <p className="listing-context">About: {conv.listingTitle}</p>
                        )}
                        <p className="last-message">{conv.messageText}</p>
                      </div>
                      <div className="message-time">
                        {new Date(conv.timestamp).toLocaleTimeString()}
                      </div>
                    </div>
                  );
                })
              )}
            </div>
          </div>

          <div className="chat-main">
            {activeConversation ? (
              <>
                <div className="chat-header">
                  <h2>
                    {messages.length > 0 && getConversationPartner(messages[0])}
                  </h2>
                  {listingIdParam && (
                    <Link to={`/listing/${listingIdParam}`} className="listing-link">
                      View Listing
                    </Link>
                  )}
                </div>

                <div className="messages-container" ref={messagesRef}>
                  {messages.length === 0 ? (
                    <div className="no-messages">No messages yet. Start the conversation!</div>
                  ) : (
                    messages.map(message => {
                      const isOwnMessage = message.senderId === user?.userId;
                      return (
                        <div
                          key={message.messageId}
                          className={`message ${isOwnMessage ? 'own' : 'other'}`}
                        >
                          <div className="message-content">
                            <p>{message.messageText}</p>
                            <span className="message-time">
                              {new Date(message.timestamp).toLocaleTimeString()}
                            </span>
                          </div>
                        </div>
                      );
                    })
                  )}
                  <div ref={messagesEndRef} />
                </div>

                <form onSubmit={handleSendMessage} className="message-input-form">
                  <input
                    type="text"
                    value={messageText}
                    onChange={(e) => setMessageText(e.target.value)}
                    placeholder="Type a message..."
                    className="message-input"
                    disabled={sending}
                  />
                  <button type="submit" disabled={sending || !messageText.trim()} className="send-btn">
                    {sending ? 'Sending...' : 'Send'}
                  </button>
                </form>
              </>
            ) : (
              <div className="no-active-conversation">
                <h2>Select a conversation to start chatting</h2>
                <p>Or start a new conversation from a listing page</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </>
  );
};

export default ChatPage;
