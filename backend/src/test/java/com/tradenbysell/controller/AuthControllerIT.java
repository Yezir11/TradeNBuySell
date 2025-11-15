package com.tradenbysell.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tradenbysell.dto.AuthRequest;
import com.tradenbysell.dto.RegisterRequest;
import com.tradenbysell.model.User;
import com.tradenbysell.repository.UserRepository;
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

import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class AuthControllerIT {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private User testUser;
    private String testToken;

    @BeforeEach
    void setUp() {
        // Note: @Transactional ensures test data is rolled back after each test
        // No need to manually delete - schema is created automatically by Hibernate
        
        // Create test user
        testUser = new User();
        testUser.setUserId(UUID.randomUUID().toString());
        testUser.setEmail("test@pilani.bits-pilani.ac.in");
        testUser.setFullName("Test User");
        testUser.setPasswordHash(passwordEncoder.encode("password123"));
        testUser.setRole(User.Role.STUDENT);
        testUser.setWalletBalance(new java.math.BigDecimal("1000.00"));
        testUser.setTrustScore(5.0f);
        testUser.setRegisteredAt(java.time.LocalDateTime.now());
        testUser.setIsSuspended(false);
        testUser = userRepository.save(testUser);
    }

    @Test
    void register_ValidRequest_Returns201() throws Exception {
        RegisterRequest request = new RegisterRequest();
        request.setEmail("newuser@pilani.bits-pilani.ac.in");
        request.setPassword("password123");
        request.setFullName("New User");

        mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.token").exists())
            .andExpect(jsonPath("$.email").value("newuser@pilani.bits-pilani.ac.in"));
    }

    @Test
    void register_DuplicateEmail_Returns400() throws Exception {
        RegisterRequest request = new RegisterRequest();
        request.setEmail(testUser.getEmail());
        request.setPassword("password123");
        request.setFullName("New User");

        mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isBadRequest());
    }

    @Test
    void register_InvalidDomain_Returns400() throws Exception {
        RegisterRequest request = new RegisterRequest();
        request.setEmail("user@gmail.com");
        request.setPassword("password123");
        request.setFullName("New User");

        mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isBadRequest());
    }

    @Test
    void login_ValidCredentials_Returns200() throws Exception {
        AuthRequest request = new AuthRequest();
        request.setEmail(testUser.getEmail());
        request.setPassword("password123");

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.token").exists())
            .andExpect(jsonPath("$.email").value(testUser.getEmail()));
    }

    @Test
    void login_InvalidCredentials_Returns401() throws Exception {
        AuthRequest request = new AuthRequest();
        request.setEmail(testUser.getEmail());
        request.setPassword("wrongpassword");

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isUnauthorized());
    }

    @Test
    void login_NonexistentUser_Returns401() throws Exception {
        AuthRequest request = new AuthRequest();
        request.setEmail("nonexistent@pilani.bits-pilani.ac.in");
        request.setPassword("password123");

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isUnauthorized());
    }
}

