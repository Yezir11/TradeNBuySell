package com.tradenbysell.security;

import com.tradenbysell.model.User;
import com.tradenbysell.repository.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;
import java.util.UUID;

@Component
public class OAuth2LoginSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtUtil jwtUtil;

    @Value("${app.allowed-domain}")
    private String allowedDomain;

    @Value("${app.frontend.url}")
    private String frontendUrl;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                        Authentication authentication) throws IOException {
        OAuth2User oAuth2User = (OAuth2User) authentication.getPrincipal();
        String email = oAuth2User.getAttribute("email");
        String name = oAuth2User.getAttribute("name");

        if (email == null || !email.endsWith("@" + allowedDomain)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Only " + allowedDomain + " emails are allowed.");
            return;
        }

        User user = userRepository.findByEmail(email).orElse(null);
        if (user == null) {
            user = new User();
            user.setUserId(UUID.randomUUID().toString());
            user.setEmail(email);
            user.setFullName(name != null ? name : email.split("@")[0]);
            user.setRole(User.Role.STUDENT);
            user.setWalletBalance(new java.math.BigDecimal("1000.00"));
            user.setTrustScore(0.0f);
            user.setIsSuspended(false);
            user.setRegisteredAt(java.time.LocalDateTime.now());
            userRepository.save(user);
        } else {
            user.setLastLoginAt(java.time.LocalDateTime.now());
            userRepository.save(user);
        }

        String token = jwtUtil.generateToken(user.getUserId());
        String redirectUrl = UriComponentsBuilder.fromUriString(frontendUrl)
                .path("/auth/callback")
                .queryParam("token", token)
                .toUriString();

        getRedirectStrategy().sendRedirect(request, response, redirectUrl);
    }
}

