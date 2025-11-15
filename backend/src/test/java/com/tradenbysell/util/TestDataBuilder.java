package com.tradenbysell.util;

import com.tradenbysell.model.Listing;
import com.tradenbysell.model.User;
import com.tradenbysell.model.Bid;
import com.tradenbysell.model.Trade;
import com.tradenbysell.model.TradeOffering;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

public class TestDataBuilder {

    public static User createTestUser() {
        User user = new User();
        user.setUserId(UUID.randomUUID().toString());
        user.setEmail("test@pilani.bits-pilani.ac.in");
        user.setFullName("Test User");
        user.setPasswordHash("$2a$10$hashedpassword");
        user.setRole(User.Role.STUDENT);
        user.setWalletBalance(new BigDecimal("1000.00"));
        user.setTrustScore(5.0f);
        user.setRegisteredAt(LocalDateTime.now());
        user.setIsSuspended(false);
        return user;
    }

    public static User createAdminUser() {
        User user = createTestUser();
        user.setEmail("admin@pilani.bits-pilani.ac.in");
        user.setRole(User.Role.ADMIN);
        return user;
    }

    public static Listing createTestListing(User seller) {
        Listing listing = new Listing();
        listing.setListingId(UUID.randomUUID().toString());
        listing.setUserId(seller.getUserId());
        listing.setTitle("Test Listing Title - This is a test listing with sufficient characters to meet the minimum requirement");
        listing.setDescription("This is a test listing description that contains at least 500 characters to meet the minimum requirement. " +
                "It should provide enough detail about the item being sold, including its condition, features, and any relevant information " +
                "that would help potential buyers make an informed decision. The description should be comprehensive and clear.");
        listing.setPrice(new BigDecimal("100.00"));
        listing.setCategory("Electronics");
        listing.setIsActive(true);
        listing.setIsBiddable(false);
        listing.setIsTradeable(false);
        listing.setCreatedAt(LocalDateTime.now());
        listing.setIsActive(true);
        return listing;
    }

    public static Listing createBiddableListing(User seller) {
        Listing listing = createTestListing(seller);
        listing.setIsBiddable(true);
        listing.setStartingPrice(new BigDecimal("50.00"));
        listing.setBidIncrement(new BigDecimal("5.00"));
        listing.setBidStartTime(LocalDateTime.now().minusDays(1));
        listing.setBidEndTime(LocalDateTime.now().plusDays(7));
        return listing;
    }

    public static Listing createTradeableListing(User seller) {
        Listing listing = createTestListing(seller);
        listing.setIsTradeable(true);
        listing.setPrice(null);
        return listing;
    }

    public static Bid createTestBid(User bidder, Listing listing, BigDecimal amount) {
        Bid bid = new Bid();
        // bidId is auto-generated, don't set it
        bid.setUserId(bidder.getUserId());
        bid.setListingId(listing.getListingId());
        bid.setBidAmount(amount);
        bid.setBidTime(LocalDateTime.now());
        bid.setIsWinning(false);
        return bid;
    }

    public static Trade createTestTrade(User initiator, User recipient) {
        Trade trade = new Trade();
        trade.setTradeId(UUID.randomUUID().toString());
        trade.setInitiatorId(initiator.getUserId());
        trade.setRecipientId(recipient.getUserId());
        trade.setCashAdjustmentAmount(new BigDecimal("50.00"));
        trade.setStatus(Trade.TradeStatus.PENDING);
        trade.setCreatedAt(LocalDateTime.now());
        return trade;
    }
}

