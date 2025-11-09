package com.tradenbysell.service;

import com.tradenbysell.dto.AuthRequest;
import com.tradenbysell.dto.AuthResponse;
import com.tradenbysell.dto.PasswordSetupRequest;
import com.tradenbysell.dto.RegisterRequest;
import com.tradenbysell.exception.BadRequestException;
import com.tradenbysell.exception.ResourceNotFoundException;
import com.tradenbysell.exception.UnauthorizedException;
import com.tradenbysell.model.User;
import com.tradenbysell.repository.UserRepository;
import com.tradenbysell.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class AuthService {
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    @Value("${app.allowed-domain}")
    private String allowedDomain;

    public AuthResponse login(AuthRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new UnauthorizedException("Invalid email or password"));

        if (user.getPasswordHash() == null || !passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new UnauthorizedException("Invalid email or password");
        }

        user.setLastLoginAt(java.time.LocalDateTime.now());
        userRepository.save(user);

        String token = jwtUtil.generateToken(user.getUserId());
        return new AuthResponse(token, user.getUserId(), user.getEmail(), user.getFullName(), user.getRole().name());
    }

    public AuthResponse register(RegisterRequest request) {
        if (!request.getEmail().endsWith("@" + allowedDomain)) {
            throw new BadRequestException("Only " + allowedDomain + " emails are allowed");
        }

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email already exists");
        }

        User user = new User();
        user.setUserId(UUID.randomUUID().toString());
        user.setEmail(request.getEmail());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setFullName(request.getFullName());
        user.setRole(User.Role.STUDENT);
        user.setWalletBalance(new java.math.BigDecimal("1000.00"));
        user.setTrustScore(0.0f);
        user.setRegisteredAt(java.time.LocalDateTime.now());
        user.setIsSuspended(false);

        userRepository.save(user);

        String token = jwtUtil.generateToken(user.getUserId());
        return new AuthResponse(token, user.getUserId(), user.getEmail(), user.getFullName(), user.getRole().name());
    }

    public void setupPassword(String userId, PasswordSetupRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (user.getPasswordHash() != null) {
            throw new BadRequestException("Password already set");
        }

        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        userRepository.save(user);
    }

    public AuthResponse getCurrentUser(String userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        String token = jwtUtil.generateToken(user.getUserId());
        return new AuthResponse(token, user.getUserId(), user.getEmail(), user.getFullName(), user.getRole().name());
    }
}

