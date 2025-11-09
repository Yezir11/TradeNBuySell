package com.tradenbysell.util;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

@Component
public class AuthUtil {
    public String getUserId(Authentication authentication) {
        if (authentication == null || authentication.getPrincipal() == null) {
            return null;
        }
        
        Object principal = authentication.getPrincipal();
        if (principal instanceof UserDetails) {
            return ((UserDetails) principal).getUsername();
        }
        return principal.toString();
    }
}

