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
  const [listingContext, setListingContext] = useState(null);
  const [offers, setOffers] = useState({}); // Map of offerId -> offer details
  const [showCounterModal, setShowCounterModal] = useState(false);
  const [selectedOffer, setSelectedOffer] = useState(null);
  const [counterAmount, setCounterAmount] = useState('');
  const [counterMessage, setCounterMessage] = useState('');
  const [processingOffer, setProcessingOffer] = useState(false);
  const messagesEndRef = useRef(null);
  const messagesRef = useRef(null);

  useEffect(() => {
    fetchConversations();
    if (userIdParam) {
      loadConversation(userIdParam, listingIdParam);
    }
    // Fetch listing context if listingId is provided
    if (listingIdParam) {
      fetchListingContext(listingIdParam);
    } else {
      setListingContext(null);
    }
  }, [userIdParam, listingIdParam]);

  const fetchListingContext = async (listingId) => {
    try {
      const response = await api.get(`/api/listings/${listingId}`);
      setListingContext(response.data);
    } catch (err) {
      console.error('Failed to fetch listing context:', err);
      setListingContext(null);
    }
  };

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

  // Fetch offer details for messages with offerId
  useEffect(() => {
    const offerIds = messages
      .filter(m => m.offerId && !offers[m.offerId])
      .map(m => m.offerId);
    
    if (offerIds.length > 0) {
      offerIds.forEach(offerId => {
        fetchOfferDetails(offerId);
      });
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [messages]);

  const fetchOfferDetails = async (offerId) => {
    try {
      const response = await api.get(`/api/offers/${offerId}`);
      setOffers(prev => ({ ...prev, [offerId]: response.data }));
    } catch (err) {
      console.error('Failed to fetch offer details:', err);
    }
  };

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

  const handleAcceptOffer = async (offerId) => {
    if (!window.confirm('Are you sure you want to accept this offer? The buyer\'s funds will be held in escrow.')) {
      return;
    }
    
    setProcessingOffer(true);
    try {
      await api.post(`/api/offers/${offerId}/accept`);
      alert('Offer accepted! Funds have been held in escrow. The buyer will be notified.');
      await fetchMessages(activeConversation);
      await fetchOfferDetails(offerId);
    } catch (err) {
      console.error('Failed to accept offer:', err);
      alert(err.response?.data?.message || 'Failed to accept offer');
    } finally {
      setProcessingOffer(false);
    }
  };

  const handleRejectOffer = async (offerId) => {
    if (!window.confirm('Are you sure you want to reject this offer?')) {
      return;
    }
    
    setProcessingOffer(true);
    try {
      await api.post(`/api/offers/${offerId}/reject`);
      alert('Offer rejected. The buyer has been notified.');
      await fetchMessages(activeConversation);
      await fetchOfferDetails(offerId);
    } catch (err) {
      console.error('Failed to reject offer:', err);
      alert(err.response?.data?.message || 'Failed to reject offer');
    } finally {
      setProcessingOffer(false);
    }
  };

  const handleAcceptCounterOffer = async (offerId) => {
    if (!window.confirm('Are you sure you want to accept the counter offer? Your funds will be held in escrow.')) {
      return;
    }
    
    setProcessingOffer(true);
    try {
      await api.post(`/api/offers/${offerId}/accept`);
      alert('Counter offer accepted! Funds have been held in escrow.');
      await fetchMessages(activeConversation);
      await fetchOfferDetails(offerId);
    } catch (err) {
      console.error('Failed to accept counter offer:', err);
      alert(err.response?.data?.message || 'Failed to accept counter offer');
    } finally {
      setProcessingOffer(false);
    }
  };

  const handleSubmitCounterOffer = async (e) => {
    e.preventDefault();
    
    if (!counterAmount || parseFloat(counterAmount) <= 0) {
      alert('Please enter a valid counter offer amount');
      return;
    }

    setProcessingOffer(true);
    try {
      await api.post(`/api/offers/${selectedOffer.offerId}/counter`, {
        counterAmount: parseFloat(counterAmount),
        message: counterMessage
      });
      alert('Counter offer sent!');
      setShowCounterModal(false);
      setCounterAmount('');
      setCounterMessage('');
      setSelectedOffer(null);
      await fetchMessages(activeConversation);
      await fetchOfferDetails(selectedOffer.offerId);
    } catch (err) {
      console.error('Failed to submit counter offer:', err);
      alert(err.response?.data?.message || 'Failed to submit counter offer');
    } finally {
      setProcessingOffer(false);
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
                  <div>
                    <h2>
                      {messages.length > 0 && getConversationPartner(messages[0])}
                    </h2>
                    {listingContext && (
                      <div className="listing-context-header">
                        <span className="context-label">Chatting about:</span>
                        <span className="context-listing-title">{listingContext.title}</span>
                      </div>
                    )}
                  </div>
                  {listingIdParam && (
                    <Link to={`/listing/${listingIdParam}`} className="listing-link">
                      View Listing
                    </Link>
                  )}
                </div>

                {/* Listing Context Banner */}
                {listingContext && (
                  <div className="listing-context-banner">
                    <div className="listing-context-content">
                      <div className="listing-context-image">
                        {listingContext.imageUrls && listingContext.imageUrls.length > 0 && (
                          <Link to={`/listing/${listingContext.listingId}`}>
                            <img 
                              src={listingContext.imageUrls[0]} 
                              alt={listingContext.title}
                              className="context-thumbnail"
                            />
                          </Link>
                        )}
                      </div>
                      <div className="listing-context-details">
                        <h4>{listingContext.title}</h4>
                        <p className="context-description">
                          {listingContext.description?.length > 100 
                            ? listingContext.description.substring(0, 100) + '...'
                            : listingContext.description}
                        </p>
                        {listingContext.price && (
                          <span className="context-price">₹{listingContext.price.toFixed(2)}</span>
                        )}
                      </div>
                      <div className="listing-context-action">
                        <Link 
                          to={`/listing/${listingContext.listingId}`} 
                          className="btn-view-listing"
                        >
                          View Full Listing
                        </Link>
                      </div>
                    </div>
                  </div>
                )}

                <div className="messages-container" ref={messagesRef}>
                  {messages.length === 0 ? (
                    <div className="no-messages">No messages yet. Start the conversation!</div>
                  ) : (
                    messages.map(message => {
                      const isOwnMessage = message.senderId === user?.userId;
                      const isOfferMessage = message.messageType && 
                        ['PURCHASE_OFFER', 'OFFER_ACCEPTED', 'OFFER_REJECTED', 'OFFER_COUNTERED'].includes(message.messageType);
                      const offer = message.offerId ? offers[message.offerId] : null;
                      const isSeller = offer && offer.sellerId === user?.userId;
                      
                      if (isOfferMessage && offer) {
                        return (
                          <div key={message.messageId} className={`message ${isOwnMessage ? 'own' : 'other'} offer-message`}>
                            <div className={`offer-bubble ${message.messageType.toLowerCase().replace('_', '-')}`}>
                              <div className="offer-header">
                                <span className="offer-icon">
                                  {message.messageType === 'PURCHASE_OFFER' && '💰'}
                                  {message.messageType === 'OFFER_ACCEPTED' && '✅'}
                                  {message.messageType === 'OFFER_REJECTED' && '❌'}
                                  {message.messageType === 'OFFER_COUNTERED' && '💬'}
                                </span>
                                <span className="offer-title">
                                  {message.messageType === 'PURCHASE_OFFER' && 'Purchase Offer'}
                                  {message.messageType === 'OFFER_ACCEPTED' && 'Offer Accepted'}
                                  {message.messageType === 'OFFER_REJECTED' && 'Offer Rejected'}
                                  {message.messageType === 'OFFER_COUNTERED' && 'Counter Offer'}
                                </span>
                              </div>
                              
                              <div className="offer-details">
                                <div className="offer-amounts">
                                  <div className="offer-amount">
                                    <span className="label">Offer:</span>
                                    <span className="value">₹{parseFloat(offer.offerAmount).toFixed(2)}</span>
                                  </div>
                                  {offer.counterOfferAmount && (
                                    <div className="counter-amount">
                                      <span className="label">Counter:</span>
                                      <span className="value">₹{parseFloat(offer.counterOfferAmount).toFixed(2)}</span>
                                    </div>
                                  )}
                                  <div className="original-price">
                                    <span className="label">Original:</span>
                                    <span className="value">₹{parseFloat(offer.originalListingPrice).toFixed(2)}</span>
                                  </div>
                                </div>
                                
                                {offer.message && (
                                  <div className="offer-message-text">
                                    <strong>Message:</strong> {offer.message}
                                  </div>
                                )}
                                
                                <div className="offer-status">
                                  Status: <span className={`status-badge ${offer.status.toLowerCase()}`}>
                                    {offer.status}
                                  </span>
                                </div>
                              </div>
                              
                              {/* Action Buttons */}
                              {message.messageType === 'PURCHASE_OFFER' && isSeller && offer.status === 'PENDING' && (
                                <div className="offer-actions">
                                  <button 
                                    className="btn-accept"
                                    onClick={() => handleAcceptOffer(offer.offerId)}
                                    disabled={processingOffer}
                                  >
                                    Accept Offer
                                  </button>
                                  <button 
                                    className="btn-counter"
                                    onClick={() => {
                                      setSelectedOffer(offer);
                                      setCounterAmount(offer.originalListingPrice);
                                      setShowCounterModal(true);
                                    }}
                                    disabled={processingOffer}
                                  >
                                    Counter Offer
                                  </button>
                                  <button 
                                    className="btn-reject"
                                    onClick={() => handleRejectOffer(offer.offerId)}
                                    disabled={processingOffer}
                                  >
                                    Reject
                                  </button>
                                </div>
                              )}
                              
                              {message.messageType === 'OFFER_COUNTERED' && !isSeller && offer.status === 'COUNTERED' && (
                                <div className="offer-actions">
                                  <button 
                                    className="btn-accept"
                                    onClick={() => handleAcceptCounterOffer(offer.offerId)}
                                    disabled={processingOffer}
                                  >
                                    Accept Counter Offer
                                  </button>
                                  <button 
                                    className="btn-new-offer"
                                    onClick={() => {
                                      // Navigate to listing to make new offer
                                      window.location.href = `/listing/${offer.listingId}`;
                                    }}
                                  >
                                    Make New Offer
                                  </button>
                                </div>
                              )}
                              
                              <span className="message-time">
                                {new Date(message.timestamp).toLocaleTimeString()}
                              </span>
                            </div>
                          </div>
                        );
                      }
                      
                      // Regular message
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

      {/* Counter Offer Modal */}
      {showCounterModal && selectedOffer && (
        <div className="modal-overlay" onClick={() => setShowCounterModal(false)}>
          <div className="modal-content offer-modal" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Counter Offer</h2>
              <button className="close-btn" onClick={() => setShowCounterModal(false)}>×</button>
            </div>
            <div className="modal-body">
              <div className="offer-summary">
                <p><strong>Original Offer:</strong> ₹{parseFloat(selectedOffer.offerAmount).toFixed(2)}</p>
                <p><strong>Original Listing Price:</strong> ₹{parseFloat(selectedOffer.originalListingPrice).toFixed(2)}</p>
              </div>
              
              <form onSubmit={handleSubmitCounterOffer}>
                <div className="form-group">
                  <label htmlFor="counterAmount">Your Counter Offer (₹)</label>
                  <input
                    type="number"
                    id="counterAmount"
                    value={counterAmount}
                    onChange={(e) => setCounterAmount(e.target.value)}
                    min="1"
                    step="0.01"
                    required
                    placeholder="Enter counter offer amount"
                  />
                </div>
                
                <div className="form-group">
                  <label htmlFor="counterMessage">Message to Buyer (Optional)</label>
                  <textarea
                    id="counterMessage"
                    value={counterMessage}
                    onChange={(e) => setCounterMessage(e.target.value)}
                    rows="4"
                    placeholder="Add a message to the buyer..."
                  />
                </div>
                
                <div className="modal-actions">
                  <button type="button" className="btn-cancel" onClick={() => setShowCounterModal(false)}>
                    Cancel
                  </button>
                  <button type="submit" className="btn-submit" disabled={processingOffer}>
                    {processingOffer ? 'Sending...' : 'Send Counter Offer'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default ChatPage;
