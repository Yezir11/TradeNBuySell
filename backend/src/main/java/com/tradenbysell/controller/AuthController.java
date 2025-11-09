package com.tradenbysell.controller;

import com.tradenbysell.dto.AuthRequest;
import com.tradenbysell.dto.AuthResponse;
import com.tradenbysell.dto.PasswordSetupRequest;
import com.tradenbysell.dto.RegisterRequest;
import com.tradenbysell.service.AuthService;
import com.tradenbysell.util.AuthUtil;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {
    @Autowired
    private AuthService authService;

    @Autowired
    private AuthUtil authUtil;

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody AuthRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        AuthResponse response = authService.register(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/setup-password")
    public ResponseEntity<Void> setupPassword(@Valid @RequestBody PasswordSetupRequest request,
                                             Authentication authentication) {
        String userId = authUtil.getUserId(authentication);
        authService.setupPassword(userId, request);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/me")
    public ResponseEntity<AuthResponse> getCurrentUser(Authentication authentication) {
        AuthResponse response = authService.getCurrentUser(authUtil.getUserId(authentication));
        return ResponseEntity.ok(response);
    }
}

