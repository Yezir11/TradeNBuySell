package com.tradenbysell.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tradenbysell.dto.ListingCreateDTO;
import com.tradenbysell.model.Listing;
import com.tradenbysell.model.User;
import com.tradenbysell.repository.ListingRepository;
import com.tradenbysell.repository.UserRepository;
import com.tradenbysell.security.JwtUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.UUID;

import static org.hamcrest.Matchers.greaterThanOrEqualTo;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
@org.springframework.test.annotation.DirtiesContext(classMode = org.springframework.test.annotation.DirtiesContext.ClassMode.AFTER_CLASS)
class ListingControllerIT {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ListingRepository listingRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    private User testUser;
    private String authToken;
    private Listing testListing;

    @BeforeEach
    void setUp() {
        // Note: @Transactional ensures test data is rolled back after each test
        // Schema is created automatically by Hibernate ddl-auto=create-drop
        
        // Create test user
        testUser = new User();
        testUser.setUserId(UUID.randomUUID().toString());
        testUser.setEmail("test@pilani.bits-pilani.ac.in");
        testUser.setFullName("Test User");
        testUser.setPasswordHash(passwordEncoder.encode("password123"));
        testUser.setRole(User.Role.STUDENT);
        testUser.setWalletBalance(new BigDecimal("1000.00"));
        testUser.setTrustScore(5.0f);
        testUser.setRegisteredAt(java.time.LocalDateTime.now());
        testUser.setIsSuspended(false);
        testUser = userRepository.save(testUser);

        authToken = jwtUtil.generateToken(testUser.getUserId());

        // Create test listing
        testListing = new Listing();
        testListing.setListingId(UUID.randomUUID().toString());
        testListing.setUserId(testUser.getUserId());
        testListing.setTitle("Test Listing Title - This is a test listing with sufficient characters to meet the minimum requirement");
        testListing.setDescription("This is a test listing description that contains at least 500 characters to meet the minimum requirement. " +
                "It should provide enough detail about the item being sold, including its condition, features, and any relevant information " +
                "that would help potential buyers make an informed decision. The description should be comprehensive and clear.");
        testListing.setPrice(new BigDecimal("100.00"));
        testListing.setCategory("Electronics");
        testListing.setIsBiddable(false);
        testListing.setIsTradeable(false);
        testListing.setCreatedAt(java.time.LocalDateTime.now());
        testListing.setIsActive(true);
        testListing = listingRepository.save(testListing);
    }

    @Test
    void getListings_ReturnsPaginatedList() throws Exception {
        mockMvc.perform(get("/api/listings")
                .param("page", "0")
                .param("size", "10"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.content").isArray())
            .andExpect(jsonPath("$.totalElements").value(greaterThanOrEqualTo(1)));
    }

    @Test
    void getListings_FilterByCategory_ReturnsFilteredList() throws Exception {
        mockMvc.perform(get("/api/listings")
                .param("category", "Electronics")
                .param("page", "0")
                .param("size", "10"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.content").isArray());
    }

    @Test
    void getListingById_ValidId_ReturnsListing() throws Exception {
        mockMvc.perform(get("/api/listings/" + testListing.getListingId()))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.listingId").value(testListing.getListingId()))
            .andExpect(jsonPath("$.title").value(testListing.getTitle()));
    }

    @Test
    void getListingById_InvalidId_Returns404() throws Exception {
        mockMvc.perform(get("/api/listings/nonexistent"))
            .andExpect(status().isNotFound());
    }

    @Test
    void createListing_AuthenticatedUser_CreatesListing() throws Exception {
        ListingCreateDTO dto = new ListingCreateDTO();
        dto.setTitle("New Listing Title - This is a new listing with sufficient characters to meet the minimum requirement");
        dto.setDescription("This is a new listing description that contains at least 500 characters to meet the minimum requirement. " +
                "It should provide enough detail about the item being sold, including its condition, features, and any relevant information " +
                "that would help potential buyers make an informed decision. The description should be comprehensive and clear.");
        dto.setPrice(new BigDecimal("200.00"));
        dto.setCategory("Electronics");
        dto.setIsBiddable(false);
        dto.setIsTradeable(false);

        mockMvc.perform(post("/api/listings")
                .header("Authorization", "Bearer " + authToken)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.listingId").exists())
            .andExpect(jsonPath("$.title").value(dto.getTitle()));
    }

    @Test
    void createListing_Unauthenticated_Returns401() throws Exception {
        ListingCreateDTO dto = new ListingCreateDTO();
        dto.setTitle("New Listing");
        dto.setDescription("Description");

        mockMvc.perform(post("/api/listings")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)))
            .andExpect(status().isUnauthorized());
    }
}

