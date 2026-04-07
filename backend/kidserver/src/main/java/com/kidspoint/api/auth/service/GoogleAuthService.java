package com.kidspoint.api.auth.service;

import com.kidspoint.api.auth.domain.User;
import com.kidspoint.api.auth.dto.GoogleUserInfoResponse;
import com.kidspoint.api.auth.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

@Service
public class GoogleAuthService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final WebClient webClient;

    @Autowired
    public GoogleAuthService(UserMapper userMapper, PasswordEncoder passwordEncoder) {
        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
        this.webClient = WebClient.builder()
            .baseUrl("https://www.googleapis.com")
            .build();
    }

    /**
     * 액세스 토큰으로 구글 사용자 정보 조회
     */
    public Mono<GoogleUserInfoResponse> getUserInfo(String accessToken) {
        return webClient.get()
            .uri("/oauth2/v2/userinfo")
            .header("Authorization", "Bearer " + accessToken)
            .retrieve()
            .onStatus(status -> !status.is2xxSuccessful(), response -> {
                return response.bodyToMono(String.class)
                    .then(Mono.error(new RuntimeException("구글 사용자 정보 요청 실패: " + response.statusCode())));
            })
            .bodyToMono(GoogleUserInfoResponse.class)
            .onErrorMap(e -> new RuntimeException("Failed to get Google user info: " + e.getMessage(), e));
    }

    /**
     * 구글 사용자 정보로 로그인 또는 회원가입
     */
    @Transactional
    public User loginOrRegister(GoogleUserInfoResponse googleUserInfo) {
        try {
            String googleId = "google_" + googleUserInfo.getId();
            String email = googleUserInfo.getEmail();
            String nickname = googleUserInfo.getName() != null 
                ? googleUserInfo.getName() 
                : (googleUserInfo.getGivenName() != null 
                    ? googleUserInfo.getGivenName() 
                    : "구글사용자");

            // 구글 ID로 사용자 찾기 (auth_type='google' AND social_id=구글ID)
            User user = userMapper.selectByAuthTypeAndSocialId("google", googleUserInfo.getId());
            
            if (user == null) {
                // 신규 사용자 - 자동 회원가입
                user = new User();
                user.setId(UUID.randomUUID());
                user.setUsername(googleId);  // 기존 호환성을 위해 username도 설정
                // 구글 로그인 사용자는 비밀번호 없음 (랜덤 해시 저장)
                user.setPasswordHash(passwordEncoder.encode(UUID.randomUUID().toString()));
                user.setEmail(email);
                user.setNickname(nickname);
                user.setAuthType("google");  // 구글 로그인 사용자
                user.setSocialId(googleUserInfo.getId());  // 구글 ID 저장
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
                // 닉네임은 사용자가 마이페이지에서 수정한 것을 유지하므로 구글 닉네임으로 덮어쓰지 않음
                // 단, 닉네임이 없는 경우에만 구글 닉네임으로 설정
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
}
