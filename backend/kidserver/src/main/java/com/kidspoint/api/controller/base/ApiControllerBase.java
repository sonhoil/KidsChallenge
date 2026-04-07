package com.kidspoint.api.controller.base;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.UUID;

public abstract class ApiControllerBase {
    
    private static final Logger logger = LoggerFactory.getLogger(ApiControllerBase.class);
    
    /**
     * 현재 로그인한 사용자 ID를 반환합니다.
     * Spring Security에서 현재 사용자 ID를 추출합니다.
     */
    protected UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        logger.debug("[ApiControllerBase] Authentication: {}", authentication != null ? (authentication.isAuthenticated() ? "authenticated as " + authentication.getName() : "not authenticated") : "null");
        
        if (authentication == null || !authentication.isAuthenticated()) {
            logger.warn("[ApiControllerBase] No authentication found");
            return null;
        }
        
        try {
            // authentication.getName()은 UserDetailsService에서 설정한 username (UUID 문자열)
            UUID userId = UUID.fromString(authentication.getName());
            logger.debug("[ApiControllerBase] User ID extracted: {}", userId);
            return userId;
        } catch (IllegalArgumentException e) {
            logger.warn("[ApiControllerBase] Invalid user ID format: {}", authentication.getName());
            return null;
        }
    }

    /**
     * 현재 세션의 조직 ID를 반환합니다.
     * OrganizationContext를 통해 세션에서 현재 조직 ID를 추출합니다.
     */
    protected UUID getCurrentOrgIdFromSession() {
        // 이 메서드는 HttpSession이 필요한 경우 컨트롤러에서 직접 OrganizationContext 사용
        return null;
    }
}
