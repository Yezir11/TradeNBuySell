package com.tradenbysell.security;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationFailureHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
public class OAuth2LoginFailureHandler extends SimpleUrlAuthenticationFailureHandler {
    @Value("${app.frontend.url}")
    private String frontendUrl;

    @Override
    public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response,
                                        AuthenticationException exception) throws IOException {
        String errorMessage = exception.getMessage();
        String redirectUrl = frontendUrl + "/auth/callback?error=" + 
                java.net.URLEncoder.encode(errorMessage != null ? errorMessage : "authentication_failed", "UTF-8");
        
        getRedirectStrategy().sendRedirect(request, response, redirectUrl);
    }
}

