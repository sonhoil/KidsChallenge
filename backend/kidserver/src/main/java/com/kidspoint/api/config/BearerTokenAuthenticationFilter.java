package com.kidspoint.api.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
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
        
        // 이미 인증된 경우(세션 기반 인증 등) Bearer Token 처리를 건너뛰기
        Authentication existingAuth = SecurityContextHolder.getContext().getAuthentication();
        if (existingAuth != null && existingAuth.isAuthenticated() && !(existingAuth instanceof org.springframework.security.authentication.AnonymousAuthenticationToken)) {
            logger.debug("[BearerTokenFilter] Already authenticated: {}", existingAuth.getName());
            filterChain.doFilter(request, response);
            return;
        }
        
        // 세션이 있는 경우도 건너뛰기 (세션 기반 인증 사용)
        jakarta.servlet.http.HttpSession session = request.getSession(false);
        if (session != null) {
            logger.debug("[BearerTokenFilter] Session exists: {}", session.getId());
            // 세션이 있으면 Spring Security가 자동으로 인증을 처리하도록 함
            filterChain.doFilter(request, response);
            return;
        }
        
        String authHeader = request.getHeader("Authorization");
        logger.debug("[BearerTokenFilter] Authorization header: {}", authHeader != null ? "present" : "absent");
        
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7); // "Bearer " 제거
            
            try {
                // 토큰을 UUID로 파싱 (현재는 단순히 UUID 문자열을 사용)
                // TODO: 실제 JWT 토큰을 사용하는 경우 JWT 파싱 로직으로 교체
                UUID userId = UUID.fromString(token);
                
                // 인증 객체 생성
                UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                    userId.toString(), // principal
                    null, // credentials
                    Collections.singletonList(new SimpleGrantedAuthority("ROLE_USER")) // authorities
                );
                
                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                
                // SecurityContext에 인증 정보 설정
                SecurityContextHolder.getContext().setAuthentication(authentication);
                logger.debug("[BearerTokenFilter] Bearer token authenticated: {}", userId);
                
            } catch (IllegalArgumentException e) {
                // 토큰이 유효한 UUID가 아닌 경우 무시 (다른 인증 방식 시도)
                logger.debug("[BearerTokenFilter] Invalid Bearer token format: " + e.getMessage());
            }
        }
        
        filterChain.doFilter(request, response);
    }
}
