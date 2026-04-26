package com.kidspoint.api.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.Collections;
import java.util.UUID;

/**
 * Bearer 토큰을 처리하는 인증 필터
 * Authorization 헤더에서 Bearer 토큰을 추출하여 인증 처리
 */
@Component
public class BearerTokenAuthenticationFilter extends OncePerRequestFilter {

    private static final Logger logger = LoggerFactory.getLogger(BearerTokenAuthenticationFilter.class);

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {
        
        String requestPath = request.getRequestURI();
        String method = request.getMethod();
        
        logger.debug("[BearerTokenFilter] {} {}", method, requestPath);
        
        // OPTIONS 요청은 CORS preflight이므로 필터를 건너뛰기
        if ("OPTIONS".equalsIgnoreCase(method)) {
            filterChain.doFilter(request, response);
            return;
        }
        
        // 모바일은 Cookie(SESSION) + Authorization: Bearer(사용자 UUID) 를 함께 보낸다.
        // 세션이 먼저 복원되면 기존 로직은 "이미 인증됨"으로 Bearer 를 무시했는데, 그때 토큰을 등록·요청이
        // 세션에 묶인 다른 사용자(예: 이전에 로그인한 아이)로 처리되어 FCM 이 부모가 아닌 쪽에 저장될 수 있다.
        // Authorization: Bearer 가 있으면 항상 그 UUID 를 현재 인증으로 사용한다.
        String authHeader = request.getHeader("Authorization");
        logger.debug("[BearerTokenFilter] Authorization header: {}", authHeader != null ? "present" : "absent");

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            try {
                UUID userId = UUID.fromString(token);
                UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                    userId.toString(),
                    null,
                    Collections.singletonList(new SimpleGrantedAuthority("ROLE_USER"))
                );
                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authentication);
                logger.debug("[BearerTokenFilter] Bearer token authenticated: {}", userId);
            } catch (IllegalArgumentException e) {
                logger.debug("[BearerTokenFilter] Invalid Bearer token format: {}", e.getMessage());
            }
        }

        filterChain.doFilter(request, response);
    }
}
