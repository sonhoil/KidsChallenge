package com.kidspoint.api.organization.config;

import com.kidspoint.api.organization.mapper.OrganizationMemberMapper;
import com.kidspoint.api.organization.util.OrganizationContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.util.UUID;

@Component
public class OrganizationGuard implements HandlerInterceptor {

    @Autowired
    private OrganizationMemberMapper organizationMemberMapper;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String path = request.getRequestURI();

        // 업로드된 이미지 파일은 인증 없이 접근 가능하도록 제외
        if (path.startsWith("/api/uploads/items/")) {
            return true;
        }

        // /api/boxes/** 또는 /api/items/** 경로인 경우 currentOrgId 필수
        if (path.startsWith("/api/boxes") || path.startsWith("/api/items")) {
            // Bearer Token 인증인 경우 세션이 없을 수 있으므로 세션을 생성하거나 가져옴
            HttpSession session = request.getSession(true);
            
            // 세션에 currentOrgId가 없으면 URL 파라미터에서 확인 (Bearer Token 인증 대비)
            if (!OrganizationContext.getCurrentOrgId(session).isPresent()) {
                String orgIdParam = request.getParameter("orgId");
                if (orgIdParam != null) {
                    try {
                        UUID orgId = UUID.fromString(orgIdParam);
                        // Bearer Token 인증인 경우 사용자 ID 추출
                        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
                        if (authentication != null && authentication.isAuthenticated()) {
                            try {
                                UUID userId = UUID.fromString(authentication.getName());
                                // 사용자가 해당 단체의 멤버인지 확인 (최소한의 쿼리만 실행)
                                try {
                                    if (organizationMemberMapper.selectByUserAndOrg(userId, orgId) != null) {
                                        // 멤버라면 세션에 설정
                                        OrganizationContext.setCurrentOrgId(session, orgId);
                                    } else {
                                        // 멤버가 아니면 422 에러
                                        response.setStatus(422);
                                        response.getWriter().write("{\"error\":\"Organization context required. Please select an organization first.\"}");
                                        return false;
                                    }
                                } catch (Exception e) {
                                    // DB 쿼리 실패 시 로그 없이 422 에러 반환 (로그 과다 생성 방지)
                                    response.setStatus(422);
                                    response.getWriter().write("{\"error\":\"Organization context required. Please select an organization first.\"}");
                                    return false;
                                }
                            } catch (IllegalArgumentException e) {
                                // 사용자 ID가 유효하지 않은 경우
                                response.setStatus(422);
                                response.getWriter().write("{\"error\":\"Organization context required. Please select an organization first.\"}");
                                return false;
                            }
                        } else {
                            // 인증되지 않은 경우
                            response.setStatus(422);
                            response.getWriter().write("{\"error\":\"Organization context required. Please select an organization first.\"}");
                            return false;
                        }
                    } catch (IllegalArgumentException e) {
                        // orgId가 유효하지 않은 경우
                        response.setStatus(422);
                        response.getWriter().write("{\"error\":\"Organization context required. Please select an organization first.\"}");
                        return false;
                    }
                } else {
                    // orgId 파라미터가 없는 경우
                    response.setStatus(422);
                    response.getWriter().write("{\"error\":\"Organization context required. Please select an organization first.\"}");
                    return false;
                }
            }
        }

        return true;
    }
}
