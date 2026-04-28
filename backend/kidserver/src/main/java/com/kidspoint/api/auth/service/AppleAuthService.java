package com.kidspoint.api.auth.service;

import com.kidspoint.api.auth.domain.User;
import com.kidspoint.api.auth.mapper.UserMapper;
import com.nimbusds.jwt.JWTClaimsSet;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.UUID;

@Service
public class AppleAuthService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final AppleIdentityTokenVerifier tokenVerifier;

    @Autowired
    public AppleAuthService(
            UserMapper userMapper,
            PasswordEncoder passwordEncoder,
            AppleIdentityTokenVerifier tokenVerifier) {
        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
        this.tokenVerifier = tokenVerifier;
    }

    public User loginOrRegister(String identityToken) throws Exception {
        JWTClaimsSet claims = tokenVerifier.verifyAndParseClaims(identityToken);
        String sub = claims.getSubject();
        if (sub == null || sub.isBlank()) {
            throw new IllegalArgumentException("Apple token missing subject");
        }
        String email = claims.getClaim("email") != null ? claims.getStringClaim("email") : null;

        User user = userMapper.selectByAuthTypeAndSocialId("apple", sub);
        if (user != null) {
            if (email != null && !email.isBlank()
                && (user.getEmail() == null || user.getEmail().isBlank())) {
                user.setEmail(email);
                user.setUpdatedAt(Instant.now());
                userMapper.update(user);
            }
            return user;
        }

        String username = "apple_" + sub;
        User newUser = new User();
        newUser.setId(UUID.randomUUID());
        newUser.setUsername(username);
        byte[] rnd = new byte[32];
        new SecureRandom().nextBytes(rnd);
        newUser.setPasswordHash(passwordEncoder.encode(UUID.randomUUID().toString()));
        newUser.setEmail(email);
        newUser.setNickname("Apple 사용자");
        newUser.setAuthType("apple");
        newUser.setSocialId(sub);
        newUser.setCreatedAt(Instant.now());
        newUser.setUpdatedAt(Instant.now());
        userMapper.insert(newUser);
        return newUser;
    }
}
