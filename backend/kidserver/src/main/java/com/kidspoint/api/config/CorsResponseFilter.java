package com.kidspoint.api.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * CORS 응답 후 Set-Cookie 헤더가 제거되지 않도록 보장하는 필터
 * Spring Security의 CORS 필터 이후에 실행되어 Set-Cookie 헤더를 보존
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE + 1) // CORS 필터 이후에 실행
public class CorsResponseFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {
        
        // Set-Cookie 헤더를 추적하기 위한 래퍼
        SetCookieTrackingResponseWrapper wrappedResponse = new SetCookieTrackingResponseWrapper(response);
        
        filterChain.doFilter(request, wrappedResponse);
        
        // 필터 체인 실행 후 Set-Cookie 헤더 확인
        Collection<String> headerNames = response.getHeaderNames();
        List<String> setCookieHeaders = new ArrayList<>();
        for (String name : headerNames) {
            if ("Set-Cookie".equalsIgnoreCase(name)) {
                setCookieHeaders.add(response.getHeader(name));
            }
        }
        
        // Set-Cookie 헤더가 없으면 추가 (필터 체인에서 제거된 경우)
        if (setCookieHeaders.isEmpty() && !wrappedResponse.getSetCookieHeaders().isEmpty()) {
            for (String cookieValue : wrappedResponse.getSetCookieHeaders()) {
                response.addHeader("Set-Cookie", cookieValue);
            }
        }
    }
    
    /**
     * Set-Cookie 헤더를 추적하는 응답 래퍼
     */
    private static class SetCookieTrackingResponseWrapper extends jakarta.servlet.http.HttpServletResponseWrapper {
        private final List<String> setCookieHeaders = new ArrayList<>();
        
        public SetCookieTrackingResponseWrapper(HttpServletResponse response) {
            super(response);
        }
        
        @Override
        public void addHeader(String name, String value) {
            super.addHeader(name, value);
            if ("Set-Cookie".equalsIgnoreCase(name)) {
                setCookieHeaders.add(value);
            }
        }
        
        @Override
        public void setHeader(String name, String value) {
            super.setHeader(name, value);
            if ("Set-Cookie".equalsIgnoreCase(name)) {
                setCookieHeaders.clear();
                setCookieHeaders.add(value);
            }
        }
        
        public List<String> getSetCookieHeaders() {
            return setCookieHeaders;
        }
    }
}
