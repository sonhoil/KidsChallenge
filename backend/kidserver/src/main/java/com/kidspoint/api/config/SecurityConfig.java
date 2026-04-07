package com.kidspoint.api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;
import org.springframework.security.web.csrf.CsrfTokenRequestAttributeHandler;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.security.web.util.matcher.RequestMatcher;
import com.kidspoint.api.config.CorsResponseFilter;

import java.util.Arrays;
import java.util.List;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private BearerTokenAuthenticationFilter bearerTokenAuthenticationFilter;
    
    @Autowired
    private CorsResponseFilter corsResponseFilter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        // CSRF 설정
        CookieCsrfTokenRepository tokenRepository = CookieCsrfTokenRepository.withHttpOnlyFalse();
        CsrfTokenRequestAttributeHandler requestHandler = new CsrfTokenRequestAttributeHandler();
        requestHandler.setCsrfRequestAttributeName("_csrf");

        // 개발 환경: CSRF 완전 비활성화 및 CORS 완화
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .addFilterAfter(corsResponseFilter, org.springframework.web.filter.CorsFilter.class)
            .addFilterBefore(bearerTokenAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
            .csrf(csrf -> csrf.disable()) // 개발 환경: CSRF 완전 비활성화
            .authorizeHttpRequests(auth -> auth
                .requestMatchers(org.springframework.http.HttpMethod.OPTIONS, "/api/**").permitAll() // OPTIONS 요청은 인증 불필요
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/auth/test/**").permitAll() // 테스트용 엔드포인트
                .requestMatchers("/api/health").permitAll()
                .requestMatchers("/invite/**").permitAll()
                .requestMatchers("/api/uploads/items/**").permitAll() // 업로드된 이미지는 인증 없이 접근 가능
                .requestMatchers("/api/kids/**").permitAll() // 개발 환경: Kids API 임시로 인증 불필요 (디버깅용)
                .anyRequest().authenticated()
            )
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
            )
            .formLogin(form -> form.disable())
            .httpBasic(basic -> basic.disable());

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        // 개발 환경: localhost의 모든 포트 허용
        // setAllowedOriginPatterns를 사용하면 allowCredentials(true)와 함께 사용 가능
        // localhost와 127.0.0.1의 모든 포트를 허용하는 패턴 사용
        configuration.setAllowedOriginPatterns(Arrays.asList(
            "http://localhost:*",
            "http://127.0.0.1:*",
            "http://[::1]:*" // IPv6 localhost
        ));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS", "HEAD", "PATCH"));
        configuration.setAllowedHeaders(Arrays.asList("*")); // 모든 헤더 허용
        // Set-Cookie는 브라우저가 자동으로 처리하므로 exposedHeaders에 명시적으로 포함
        configuration.setExposedHeaders(Arrays.asList("Set-Cookie", "*")); // Set-Cookie와 모든 헤더 노출
        configuration.setAllowCredentials(true); // 쿠키 전송 허용
        configuration.setMaxAge(3600L);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", configuration);
        return source;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }

    @Bean
    public AuthenticationManager authenticationManager(
            AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }
}
