package com.tradenbysell.service;

import com.tradenbysell.dto.AuthRequest;
import com.tradenbysell.dto.AuthResponse;
import com.tradenbysell.dto.RegisterRequest;
import com.tradenbysell.exception.BadRequestException;
import com.tradenbysell.exception.UnauthorizedException;
import com.tradenbysell.model.User;
import com.tradenbysell.repository.UserRepository;
import com.tradenbysell.security.JwtUtil;
import com.tradenbysell.util.TestDataBuilder;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtUtil jwtUtil;

    @InjectMocks
    private AuthService authService;

    private User testUser;
    private String testToken = "test-jwt-token";

    @BeforeEach
    void setUp() {
        ReflectionTestUtils.setField(authService, "allowedDomain", "pilani.bits-pilani.ac.in");
        testUser = TestDataBuilder.createTestUser();
    }

    @Test
    void login_ValidCredentials_ReturnsAuthResponse() {
        // Given
        AuthRequest request = new AuthRequest();
        request.setEmail(testUser.getEmail());
        request.setPassword("password123");

        when(userRepository.findByEmail(testUser.getEmail())).thenReturn(Optional.of(testUser));
        when(passwordEncoder.matches(request.getPassword(), testUser.getPasswordHash())).thenReturn(true);
        when(jwtUtil.generateToken(testUser.getUserId())).thenReturn(testToken);
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        // When
        AuthResponse response = authService.login(request);

        // Then
        assertNotNull(response);
        assertEquals(testToken, response.getToken());
        assertEquals(testUser.getUserId(), response.getUserId());
        assertEquals(testUser.getEmail(), response.getEmail());
        verify(userRepository).save(any(User.class));
    }

    @Test
    void login_InvalidEmail_ThrowsUnauthorizedException() {
        // Given
        AuthRequest request = new AuthRequest();
        request.setEmail("nonexistent@pilani.bits-pilani.ac.in");
        request.setPassword("password123");

        when(userRepository.findByEmail(request.getEmail())).thenReturn(Optional.empty());

        // When & Then
        assertThrows(UnauthorizedException.class, () -> authService.login(request));
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void login_InvalidPassword_ThrowsUnauthorizedException() {
        // Given
        AuthRequest request = new AuthRequest();
        request.setEmail(testUser.getEmail());
        request.setPassword("wrongpassword");

        when(userRepository.findByEmail(testUser.getEmail())).thenReturn(Optional.of(testUser));
        when(passwordEncoder.matches(request.getPassword(), testUser.getPasswordHash())).thenReturn(false);

        // When & Then
        assertThrows(UnauthorizedException.class, () -> authService.login(request));
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void register_ValidRequest_ReturnsAuthResponse() {
        // Given
        RegisterRequest request = new RegisterRequest();
        request.setEmail("newuser@pilani.bits-pilani.ac.in");
        request.setPassword("password123");
        request.setFullName("New User");

        when(userRepository.existsByEmail(request.getEmail())).thenReturn(false);
        when(passwordEncoder.encode(request.getPassword())).thenReturn("$2a$10$encoded");
        when(jwtUtil.generateToken(anyString())).thenReturn(testToken);
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> {
            User user = invocation.getArgument(0);
            user.setUserId("new-user-id");
            return user;
        });

        // When
        AuthResponse response = authService.register(request);

        // Then
        assertNotNull(response);
        assertEquals(testToken, response.getToken());
        verify(userRepository).save(any(User.class));
    }

    @Test
    void register_DuplicateEmail_ThrowsBadRequestException() {
        // Given
        RegisterRequest request = new RegisterRequest();
        request.setEmail(testUser.getEmail());
        request.setPassword("password123");
        request.setFullName("New User");

        when(userRepository.existsByEmail(request.getEmail())).thenReturn(true);

        // When & Then
        assertThrows(BadRequestException.class, () -> authService.register(request));
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void register_InvalidDomain_ThrowsBadRequestException() {
        // Given
        RegisterRequest request = new RegisterRequest();
        request.setEmail("user@gmail.com");
        request.setPassword("password123");
        request.setFullName("New User");

        // When & Then
        assertThrows(BadRequestException.class, () -> authService.register(request));
        verify(userRepository, never()).existsByEmail(anyString());
        verify(userRepository, never()).save(any(User.class));
    }
}

