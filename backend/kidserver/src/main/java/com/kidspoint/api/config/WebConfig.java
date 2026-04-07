package com.kidspoint.api.config;

import com.kidspoint.api.organization.config.OrganizationGuard;
import jakarta.servlet.ServletContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.web.servlet.ServletContextInitializer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Autowired
    private OrganizationGuard organizationGuard;

    @Bean
    public ServletContextInitializer servletContextInitializer() {
        return servletContext -> {
            jakarta.servlet.SessionCookieConfig sessionCookieConfig = servletContext.getSessionCookieConfig();
            sessionCookieConfig.setName("SESSION");
            sessionCookieConfig.setHttpOnly(true);
            sessionCookieConfig.setSecure(false); // 개발 환경: HTTP 허용 (application.properties와 일치)
            sessionCookieConfig.setPath("/");
            // SameSite는 application.properties에서 설정
            // sessionCookieConfig.setDomain(null); // 도메인은 설정하지 않음 (모든 도메인 허용)
        };
    }

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        // CORS 설정은 SecurityConfig에서 관리하므로 여기서는 제거
        // SecurityConfig의 corsConfigurationSource()가 우선 적용됨
        // WebConfig의 CORS 설정이 SecurityConfig와 충돌할 수 있으므로 비워둠
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(organizationGuard)
            .addPathPatterns("/api/boxes/**", "/api/items/**")
            .excludePathPatterns(
                "/api/health", 
                "/api/auth/**",
                "/api/boxes/*/organization",  // 딥링크용: 박스 ID로 organization ID 조회 (organization context 불필요)
                "/api/uploads/items/**"  // 업로드된 이미지 파일은 인증 없이 접근 가능
            );
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 정적 리소스 핸들러를 명시적으로 설정하여 /api/** 경로는 제외
        // /api/** 경로는 컨트롤러가 처리하도록 함
        registry.addResourceHandler("/static/**", "/public/**", "/resources/**")
            .addResourceLocations("classpath:/static/", "classpath:/public/", "classpath:/resources/", "classpath:/META-INF/resources/");
        
        // 업로드된 이미지 파일 제공
        // Railway에서는 /data 경로, 로컬에서는 uploads/items 경로 사용
        String uploadDir = System.getenv("UPLOAD_DIR");
        if (uploadDir == null || uploadDir.isEmpty()) {
            uploadDir = "uploads/items";
        }
        // 경로가 절대 경로인지 확인하고 file: 접두사 추가
        String resourceLocation = uploadDir.startsWith("/") 
            ? "file:" + uploadDir + "/" 
            : "file:" + uploadDir + "/";
        registry.addResourceHandler("/api/uploads/items/**")
            .addResourceLocations(resourceLocation)
            .setCachePeriod(3600);
    }
}
