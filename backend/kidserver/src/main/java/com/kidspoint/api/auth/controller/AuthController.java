package com.kidspoint.api.auth.controller;

import com.kidspoint.api.auth.dto.KakaoUserInfoResponse;
import com.kidspoint.api.auth.dto.LoginRequest;
import com.kidspoint.api.auth.dto.RegisterRequest;
import com.kidspoint.api.auth.dto.UpdateNicknameRequest;
import com.kidspoint.api.auth.dto.UserResponse;
import com.kidspoint.api.auth.service.AuthService;
import com.kidspoint.api.auth.service.KakaoAuthService;
import com.kidspoint.api.auth.service.GoogleAuthService;
import com.kidspoint.api.controller.base.ApiControllerBase;
import com.kidspoint.api.dto.ApiResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.security.web.context.SecurityContextRepository;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.util.UUID;

@RestController
@RequestMapping("/api/auth")
public class AuthController extends ApiControllerBase {

        private final AuthService authService;
        private final AuthenticationManager authenticationManager;
        private final KakaoAuthService kakaoAuthService;
        private final GoogleAuthService googleAuthService;

        @Autowired
        public AuthController(AuthService authService, AuthenticationManager authenticationManager, KakaoAuthService kakaoAuthService, GoogleAuthService googleAuthService) {
            this.authService = authService;
            this.authenticationManager = authenticationManager;
            this.kakaoAuthService = kakaoAuthService;
            this.googleAuthService = googleAuthService;
        }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<UserResponse>> register(@Valid @RequestBody RegisterRequest request) {
        UserResponse userResponse = authService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.ok(userResponse, "User registered successfully"));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<UserResponse>> login(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest httpRequest,
            HttpServletResponse httpResponse) {
        System.out.println("[AuthController] Login request received for username: " + request.getUsername());
        try {
            // UserDetailsService에서 username은 UUID 문자열이므로 username으로 조회
            System.out.println("[AuthController] Finding user by username: " + request.getUsername());
            com.kidspoint.api.auth.domain.User user = authService.findByUsername(request.getUsername());
            if (user == null) {
                System.out.println("[AuthController] User not found: " + request.getUsername());
                throw new BadCredentialsException("Invalid username or password");
            }
            System.out.println("[AuthController] User found: " + user.getId() + ", authenticating...");

            // authenticationManager.authenticate는 UserDetailsService를 통해 사용자를 조회하고
            // PasswordEncoder를 사용하여 비밀번호를 검증합니다.
            // username으로 user.getId().toString() (UUID 문자열)을 전달하면
            // UserDetailsServiceImpl에서 UUID로 인식하여 findById로 조회합니다.
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                    user.getId().toString(), // UUID를 문자열로 변환하여 UserDetailsService에 전달
                    request.getPassword()
                )
            );

            // SecurityContext 설정 및 세션에 저장 (Spring Session JDBC 방식)
            SecurityContext securityContext = SecurityContextHolder.createEmptyContext();
            securityContext.setAuthentication(authentication);
            SecurityContextHolder.setContext(securityContext);
            System.out.println("[AuthController] Authentication successful for user: " + user.getId());

            // 세션 생성 및 SecurityContext 저장 (Spring Session JDBC 방식)
            jakarta.servlet.http.HttpSession session = httpRequest.getSession(true);
            org.springframework.security.web.context.SecurityContextRepository securityContextRepository = 
                new org.springframework.security.web.context.HttpSessionSecurityContextRepository();
            securityContextRepository.saveContext(securityContext, httpRequest, httpResponse);
            String sessionId = session != null ? session.getId() : "null";
            System.out.println("[AuthController] Session created and SecurityContext saved: " + sessionId);

            // Spring Session JDBC가 자동으로 Set-Cookie를 추가하지 않는 경우를 대비하여 명시적으로 추가
            // 웹 환경에서 쿠키가 제대로 전송되도록 SameSite 설정 포함
            String cookieValue = String.format("SESSION=%s; Path=/; HttpOnly; SameSite=Lax", sessionId);
            httpResponse.addHeader("Set-Cookie", cookieValue);
            System.out.println("[AuthController] Set-Cookie header added: " + cookieValue);

                UserResponse userResponse = new UserResponse(
                    user.getId(),
                    user.getUsername(),
                    user.getEmail(),
                    user.getNickname()
                );
                userResponse.setAuthType(user.getAuthType());

            System.out.println("[AuthController] Login successful, returning response");
            
            // ResponseEntity를 사용하면 HttpServletResponse에 직접 추가한 헤더가 무시될 수 있으므로
            // ResponseEntity에 헤더를 명시적으로 추가해야 함
            org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
            headers.add("Set-Cookie", cookieValue);
            
            return ResponseEntity.ok()
                .headers(headers)
                .body(ApiResponse.ok(userResponse, "Login successful"));
        } catch (BadCredentialsException e) {
            System.out.println("[AuthController] BadCredentialsException: " + e.getMessage());
            // 일반화된 오류 메시지
            throw new IllegalArgumentException("Invalid username or password");
        } catch (AuthenticationException e) {
            System.out.println("[AuthController] AuthenticationException: " + e.getMessage());
            // 인증 실패 시 일반화된 오류 메시지
            throw new IllegalArgumentException("Invalid username or password");
        }
    }

    @GetMapping("/test/generate-hash")
    public ResponseEntity<ApiResponse<String>> generatePasswordHash(@RequestParam String password) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder(12);
        String hash = encoder.encode(password);
        System.out.println("[AuthController] Generated hash for password '" + password + "': " + hash);
        return ResponseEntity.ok(ApiResponse.ok(hash, "Password hash generated"));
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(HttpServletRequest request, HttpServletResponse response) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null) {
            new SecurityContextLogoutHandler().logout(request, response, auth);
        }
        
        // 세션 무효화
        jakarta.servlet.http.HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        
        // 세션 쿠키 명시적으로 삭제
        jakarta.servlet.http.Cookie cookie = new jakarta.servlet.http.Cookie("SESSION", "");
        cookie.setPath("/");
        cookie.setMaxAge(0); // 즉시 삭제
        cookie.setHttpOnly(true);
        cookie.setSecure(true);
        response.addCookie(cookie);
        
        // Set-Cookie 헤더로도 명시적으로 삭제 (브라우저 호환성)
        response.setHeader("Set-Cookie", "SESSION=; Path=/; HttpOnly; Secure; SameSite=None; Max-Age=0");
        
        return ResponseEntity.ok(ApiResponse.ok(null, "Logout successful"));
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        // authentication.getName()은 UserDetailsService에서 설정한 username (UUID 문자열)
        try {
            UUID userId = UUID.fromString(authentication.getName());
            UserResponse userResponse = authService.getUserInfo(userId);
            return ResponseEntity.ok(ApiResponse.ok(userResponse));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Invalid user ID"));
        }
    }

    @PutMapping("/me/nickname")
    public ResponseEntity<ApiResponse<UserResponse>> updateNickname(
            @Valid @RequestBody UpdateNicknameRequest request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            UUID userId = UUID.fromString(authentication.getName());
            UserResponse userResponse = authService.updateNickname(userId, request.getNickname());
            return ResponseEntity.ok(ApiResponse.ok(userResponse, "Nickname updated successfully"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 카카오 로그인 시작 - 카카오 인증 URL 반환
     * @param prompt 카카오 로그인 프롬프트 설정 (none: 자동 로그인 시도, login: 항상 로그인 화면 표시)
     */
    @GetMapping("/kakao")
    public ResponseEntity<ApiResponse<String>> kakaoLogin(@RequestParam(required = false) String prompt) {
        String authUrl = kakaoAuthService.getAuthorizationUrl(prompt);
        return ResponseEntity.ok(ApiResponse.ok(authUrl, "카카오 로그인 URL"));
    }

    /**
     * 카카오톡 앱 로그인 처리 (액세스 토큰 직접 전달)
     */
    @PostMapping("/kakao/token")
    public Mono<ResponseEntity<ApiResponse<UserResponse>>> kakaoTokenLogin(
            @RequestBody java.util.Map<String, String> request,
            HttpServletRequest httpRequest,
            HttpServletResponse httpResponse) {
        String accessToken = request.get("accessToken");
        if (accessToken == null || accessToken.isEmpty()) {
            ApiResponse<UserResponse> errorResponse = ApiResponse.error("Access token is required");
            return Mono.just(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse));
        }
        
        return kakaoAuthService.getUserInfo(accessToken)
            .flatMap(kakaoUserInfo -> {
                try {
                    // 로그인 또는 회원가입
                    com.kidspoint.api.auth.domain.User user = kakaoAuthService.loginOrRegister(kakaoUserInfo);
                    
                    // 카카오 로그인은 비밀번호 검증 없이 직접 인증 객체 생성
                    Authentication authentication = new UsernamePasswordAuthenticationToken(
                        user.getId().toString(),
                        null, // 비밀번호 없음
                        java.util.Collections.singletonList(new org.springframework.security.core.authority.SimpleGrantedAuthority("ROLE_USER"))
                    );
                    
                    // SecurityContext 설정
                    SecurityContext securityContext = SecurityContextHolder.createEmptyContext();
                    securityContext.setAuthentication(authentication);
                    SecurityContextHolder.setContext(securityContext);
                    
                    // 세션 생성 및 SecurityContext 저장 (Spring Session JDBC 방식)
                    jakarta.servlet.http.HttpSession session = httpRequest.getSession(true);
                    SecurityContextRepository securityContextRepository = new HttpSessionSecurityContextRepository();
                    securityContextRepository.saveContext(securityContext, httpRequest, httpResponse);
                    
                    // 세션 쿠키 설정 (일반 로그인과 동일한 방식으로 응답 헤더에도 추가)
                    String sessionId = session.getId();
                    String cookieValue = String.format("SESSION=%s; Path=/; HttpOnly; SameSite=Lax", sessionId);
                    httpResponse.addHeader("Set-Cookie", cookieValue);
                    
                    UserResponse userResponse = new UserResponse(
                        user.getId(),
                        user.getUsername(),
                        user.getEmail(),
                        user.getNickname()
                    );
                    userResponse.setAuthType(user.getAuthType());
                    
                    ApiResponse<UserResponse> successResponse = ApiResponse.ok(userResponse, "카카오톡 로그인 성공");
                    
                    // ResponseEntity 에도 Set-Cookie 를 명시적으로 추가해야 클라이언트에서 볼 수 있음
                    org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
                    headers.add("Set-Cookie", cookieValue);
                    
                    return Mono.just(ResponseEntity.ok()
                        .headers(headers)
                        .body(successResponse));
                } catch (Exception e) {
                    ApiResponse<UserResponse> errorResponse = ApiResponse.error("카카오톡 로그인 실패: " + e.getMessage());
                    return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse));
                }
            })
            .onErrorResume(e -> {
                ApiResponse<UserResponse> errorResponse = ApiResponse.error("카카오톡 로그인 실패: " + e.getMessage());
                return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse));
            });
    }

    /**
     * 카카오 로그인 콜백 처리
     */
    @GetMapping("/kakao/callback")
    public Mono<ResponseEntity<?>> kakaoCallback(
            @RequestParam(required = false) String code,
            HttpServletRequest httpRequest,
            HttpServletResponse httpResponse) {
        // code 파라미터가 없으면 조용히 프론트엔드로 리다이렉트 (카카오톡 앱 로그인은 /kakao/token 엔드포인트 사용)
        // 카카오 SDK가 자동으로 콜백 URL로 리다이렉트하는 것을 방지하기 위해 조용히 처리
        if (code == null || code.isEmpty()) {
            String frontendRedirectUri = kakaoAuthService.getFrontendRedirectUri();
            ResponseEntity<Void> redirectResponse = ResponseEntity.status(HttpStatus.FOUND)
                .header("Location", frontendRedirectUri + "/")
                .build();
            return Mono.just(redirectResponse);
        }
        return kakaoAuthService.getAccessToken(code)
            .flatMap(accessToken -> {
                return kakaoAuthService.getUserInfo(accessToken)
                    .flatMap(kakaoUserInfo -> {
                        try {
                            // 로그인 또는 회원가입
                            com.kidspoint.api.auth.domain.User user = kakaoAuthService.loginOrRegister(kakaoUserInfo);
                            
                            // 카카오 로그인은 비밀번호 검증 없이 직접 인증 객체 생성
                            Authentication authentication = new UsernamePasswordAuthenticationToken(
                                user.getId().toString(),
                                null, // 비밀번호 없음
                                java.util.Collections.singletonList(new org.springframework.security.core.authority.SimpleGrantedAuthority("ROLE_USER"))
                            );
                            
                            // SecurityContext 설정
                            SecurityContext securityContext = SecurityContextHolder.createEmptyContext();
                            securityContext.setAuthentication(authentication);
                            SecurityContextHolder.setContext(securityContext);
                            
                            // 세션 생성 및 SecurityContext 저장 (Spring Session JDBC 방식)
                            jakarta.servlet.http.HttpSession session = httpRequest.getSession(true);
                            SecurityContextRepository securityContextRepository = new HttpSessionSecurityContextRepository();
                            securityContextRepository.saveContext(securityContext, httpRequest, httpResponse);
                            
                            // 프론트엔드로 리다이렉트 (세션 쿠키 + Bearer Token)
                            // 크로스 도메인 리다이렉트 시 쿠키가 전달되지 않을 수 있으므로
                            // Bearer Token을 URL 파라미터로 전달 (단, 보안을 위해 짧은 유효기간의 토큰 사용)
                            String frontendRedirectUri = kakaoAuthService.getFrontendRedirectUri();
                            
                            // 세션 쿠키가 크로스 도메인으로 전달되도록 명시적으로 설정
                            // SameSite=None은 Java Cookie API로 직접 설정할 수 없으므로 Set-Cookie 헤더를 직접 추가
                            String sessionId = session.getId();
                            String cookieHeader = String.format("SESSION=%s; Path=/; HttpOnly; Secure; SameSite=None", sessionId);
                            httpResponse.addHeader("Set-Cookie", cookieHeader);
                            
                            // Bearer Token을 URL 파라미터로 전달 (세션 쿠키가 전달되지 않을 경우 대비)
                            // 사용자 ID를 Bearer Token으로 사용 (기존 BearerTokenAuthenticationFilter와 호환)
                            String bearerToken = user.getId().toString();
                            String redirectUrl = frontendRedirectUri + "/?kakao_login=success&token=" + bearerToken;
                            
                            // ResponseEntity를 명시적으로 생성하여 타입 불일치 해결
                            ResponseEntity<Void> redirectResponse = ResponseEntity.status(HttpStatus.FOUND)
                                .header("Location", redirectUrl)
                                .build();
                            return Mono.<ResponseEntity<?>>just(redirectResponse);
                        } catch (Exception e) {
                            return Mono.error(new RuntimeException("사용자 처리 중 오류: " + e.getMessage(), e));
                        }
                    });
            })
            .onErrorResume(e -> {
                ResponseEntity<ApiResponse<String>> errorResponse = ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("카카오 로그인 실패: " + e.getMessage()));
                return Mono.<ResponseEntity<?>>just(errorResponse);
            });
    }

    /**
     * 구글 로그인 처리 (액세스 토큰 직접 전달)
     */
    @PostMapping("/google/token")
    public Mono<ResponseEntity<ApiResponse<UserResponse>>> googleTokenLogin(
            @RequestBody java.util.Map<String, String> request,
            HttpServletRequest httpRequest,
            HttpServletResponse httpResponse) {
        String accessToken = request.get("accessToken");
        if (accessToken == null || accessToken.isEmpty()) {
            ApiResponse<UserResponse> errorResponse = ApiResponse.error("Access token is required");
            return Mono.just(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse));
        }
        
        return googleAuthService.getUserInfo(accessToken)
            .flatMap(googleUserInfo -> {
                try {
                    // 로그인 또는 회원가입
                    com.kidspoint.api.auth.domain.User user = googleAuthService.loginOrRegister(googleUserInfo);
                    
                    // 구글 로그인은 비밀번호 검증 없이 직접 인증 객체 생성
                    Authentication authentication = new UsernamePasswordAuthenticationToken(
                        user.getId().toString(),
                        null, // 비밀번호 없음
                        java.util.Collections.singletonList(new org.springframework.security.core.authority.SimpleGrantedAuthority("ROLE_USER"))
                    );
                    
                    // SecurityContext 설정
                    SecurityContext securityContext = SecurityContextHolder.createEmptyContext();
                    securityContext.setAuthentication(authentication);
                    SecurityContextHolder.setContext(securityContext);
                    
                    // 세션 생성 및 SecurityContext 저장 (Spring Session JDBC 방식)
                    jakarta.servlet.http.HttpSession session = httpRequest.getSession(true);
                    SecurityContextRepository securityContextRepository = new HttpSessionSecurityContextRepository();
                    securityContextRepository.saveContext(securityContext, httpRequest, httpResponse);
                    
                    // 세션 쿠키가 크로스 도메인으로 전달되도록 명시적으로 설정
                    String sessionId = session.getId();
                    String cookieHeader = String.format("SESSION=%s; Path=/; HttpOnly; SameSite=Lax", sessionId);
                    httpResponse.addHeader("Set-Cookie", cookieHeader);
                    
                    UserResponse userResponse = new UserResponse(
                        user.getId(),
                        user.getUsername(),
                        user.getEmail(),
                        user.getNickname()
                    );
                    userResponse.setAuthType(user.getAuthType());
                    
                    ApiResponse<UserResponse> successResponse = ApiResponse.ok(userResponse, "구글 로그인 성공");
                    return Mono.just(ResponseEntity.ok(successResponse));
                } catch (Exception e) {
                    ApiResponse<UserResponse> errorResponse = ApiResponse.error("구글 로그인 실패: " + e.getMessage());
                    return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse));
                }
            })
            .onErrorResume(e -> {
                ApiResponse<UserResponse> errorResponse = ApiResponse.error("구글 로그인 실패: " + e.getMessage());
                return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse));
            });
    }
}
