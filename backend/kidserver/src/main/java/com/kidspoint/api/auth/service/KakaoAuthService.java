package com.kidspoint.api.auth.service;

import com.kidspoint.api.auth.domain.User;
import com.kidspoint.api.auth.dto.KakaoTokenResponse;
import com.kidspoint.api.auth.dto.KakaoUserInfoResponse;
import com.kidspoint.api.auth.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

@Service
public class KakaoAuthService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final WebClient webClient;
    
    @Value("${kakao.client-id:}")
    private String clientId;
    
    @Value("${kakao.client-secret:}")
    private String clientSecret;
    
    @Value("${kakao.redirect-uri:http://localhost:8080/api/auth/kakao/callback}")
    private String redirectUri;
    
    @Value("${kakao.frontend-redirect-uri:http://localhost:5173}")
    private String frontendRedirectUri;

    @Autowired
    public KakaoAuthService(UserMapper userMapper, PasswordEncoder passwordEncoder) {
        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
        this.webClient = WebClient.builder()
            .baseUrl("https://kauth.kakao.com")
            .build();
    }

    /**
     * 카카오 인증 URL 생성
     * @param prompt 카카오 로그인 프롬프트 설정 (none: 자동 로그인 시도, login: 항상 로그인 화면 표시)
     */
    public String getAuthorizationUrl(String prompt) {
        String url = String.format(
            "https://kauth.kakao.com/oauth/authorize?client_id=%s&redirect_uri=%s&response_type=code",
            clientId,
            redirectUri
        );
        if (prompt != null && !prompt.isEmpty()) {
            url += "&prompt=" + prompt;
        }
        return url;
    }
    
    /**
     * 카카오 인증 URL 생성 (기본값: prompt=none으로 자동 로그인 시도)
     */
    public String getAuthorizationUrl() {
        return getAuthorizationUrl("none");
    }

    /**
     * 카카오 인증 코드로 액세스 토큰 받기
     */
    public Mono<String> getAccessToken(String code) {
        return webClient.post()
            .uri("/oauth/token")
            .body(BodyInserters.fromFormData("grant_type", "authorization_code")
                .with("client_id", clientId)
                .with("client_secret", clientSecret)
                .with("redirect_uri", redirectUri)
                .with("code", code))
            .retrieve()
            .onStatus(status -> !status.is2xxSuccessful(), response -> {
                return response.bodyToMono(String.class)
                    .then(Mono.error(new RuntimeException("카카오 토큰 요청 실패: " + response.statusCode())));
            })
            .bodyToMono(KakaoTokenResponse.class)
            .map(KakaoTokenResponse::getAccessToken)
            .onErrorMap(e -> new RuntimeException("Failed to get Kakao access token: " + e.getMessage(), e));
    }

    /**
     * 액세스 토큰으로 카카오 사용자 정보 조회
     */
    public Mono<KakaoUserInfoResponse> getUserInfo(String accessToken) {
        WebClient userInfoClient = WebClient.builder()
            .baseUrl("https://kapi.kakao.com")
            .defaultHeader("Authorization", "Bearer " + accessToken)
            .build();

        return userInfoClient.get()
            .uri("/v2/user/me")
            .retrieve()
            .onStatus(status -> !status.is2xxSuccessful(), response -> {
                return response.bodyToMono(String.class)
                    .then(Mono.error(new RuntimeException("카카오 사용자 정보 요청 실패: " + response.statusCode())));
            })
            .bodyToMono(KakaoUserInfoResponse.class)
            .onErrorMap(e -> new RuntimeException("Failed to get Kakao user info: " + e.getMessage(), e));
    }

    /**
     * 카카오 사용자 정보로 로그인 또는 회원가입
     */
    @Transactional
    public User loginOrRegister(KakaoUserInfoResponse kakaoUserInfo) {
        try {
            // 카카오에서 내려오는 id는 Long 이므로, 문자열로 변환하여 socialId로 사용한다
            String kakaoNumericId = String.valueOf(kakaoUserInfo.getId());
            String kakaoId = "kakao_" + kakaoNumericId;
            String email = kakaoUserInfo.getKakaoAccount() != null 
                ? kakaoUserInfo.getKakaoAccount().getEmail() 
                : null;
            String nickname = kakaoUserInfo.getKakaoAccount() != null 
                && kakaoUserInfo.getKakaoAccount().getProfile() != null
                ? kakaoUserInfo.getKakaoAccount().getProfile().getNickname()
                : (kakaoUserInfo.getProperties() != null 
                    ? kakaoUserInfo.getProperties().getNickname() 
                    : "카카오사용자");

            // 카카오 ID로 사용자 찾기 (auth_type='kakao' AND social_id=카카오ID)
            User user = userMapper.selectByAuthTypeAndSocialId("kakao", kakaoNumericId);
            
            if (user == null) {
                // 신규 사용자 - 자동 회원가입
                user = new User();
                user.setId(UUID.randomUUID());
                user.setUsername(kakaoId);  // 기존 호환성을 위해 username도 설정
                // 카카오 로그인 사용자는 비밀번호 없음 (랜덤 해시 저장)
                user.setPasswordHash(passwordEncoder.encode(UUID.randomUUID().toString()));
                user.setEmail(email);
                user.setNickname(nickname);
                user.setAuthType("kakao");  // 카카오 로그인 사용자
                user.setSocialId(kakaoNumericId);  // 카카오 ID 문자열로 저장
                user.setCreatedAt(Instant.now());
                user.setUpdatedAt(Instant.now());
                
                userMapper.insert(user);
            } else {
                // 기존 사용자 - 이메일만 업데이트 (닉네임은 사용자가 수정한 것을 유지)
                boolean updated = false;
                if (email != null && !email.equals(user.getEmail())) {
                    user.setEmail(email);
                    updated = true;
                }
                // 닉네임은 사용자가 마이페이지에서 수정한 것을 유지하므로 카카오 닉네임으로 덮어쓰지 않음
                // 단, 닉네임이 없는 경우에만 카카오 닉네임으로 설정
                if (user.getNickname() == null || user.getNickname().trim().isEmpty()) {
                    if (nickname != null && !nickname.trim().isEmpty()) {
                        user.setNickname(nickname);
                        updated = true;
                    }
                }
                if (updated) {
                    user.setUpdatedAt(Instant.now());
                    userMapper.update(user);
                }
            }
            
            return user;
        } catch (Exception e) {
            throw new RuntimeException("사용자 로그인/회원가입 처리 중 오류: " + e.getMessage(), e);
        }
    }
    
    public String getFrontendRedirectUri() {
        return frontendRedirectUri;
    }
}
