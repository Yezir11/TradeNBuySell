package com.tradenbysell.security;

import com.tradenbysell.model.User;
import com.tradenbysell.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Optional;
import java.util.UUID;

@Service
public class CustomUserDetailsService implements UserDetailsService {
    @Autowired
    private UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String identifier) throws UsernameNotFoundException {
        User user;
        
        // Check if identifier is a UUID (user ID) or email
        if (isUUID(identifier)) {
            // Try to find by user ID first (for JWT tokens)
            Optional<User> userById = userRepository.findById(identifier);
            if (userById.isPresent()) {
                user = userById.get();
            } else {
                // If not found by ID, try by email (backward compatibility)
                user = userRepository.findByEmail(identifier)
                        .orElseThrow(() -> new UsernameNotFoundException("User not found: " + identifier));
            }
        } else {
            // Assume it's an email
            user = userRepository.findByEmail(identifier)
                    .orElseThrow(() -> new UsernameNotFoundException("User not found: " + identifier));
        }

        return new org.springframework.security.core.userdetails.User(
                user.getUserId(),
                user.getPasswordHash() != null ? user.getPasswordHash() : "",
                new ArrayList<>()
        );
    }

    private boolean isUUID(String str) {
        try {
            UUID.fromString(str);
            return true;
        } catch (IllegalArgumentException e) {
            return false;
        }
    }
}

