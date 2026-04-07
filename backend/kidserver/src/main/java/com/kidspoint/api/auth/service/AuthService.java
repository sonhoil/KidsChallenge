package com.kidspoint.api.auth.service;

import com.kidspoint.api.auth.domain.User;
import com.kidspoint.api.auth.dto.RegisterRequest;
import com.kidspoint.api.auth.dto.UserResponse;
import com.kidspoint.api.auth.mapper.UserMapper;
import com.kidspoint.api.item.mapper.ItemMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@Transactional
public class AuthService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final ItemMapper itemMapper;

    @Autowired
    public AuthService(UserMapper userMapper, PasswordEncoder passwordEncoder, ItemMapper itemMapper) {
        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
        this.itemMapper = itemMapper;
    }

    public UserResponse register(RegisterRequest request) {
        // 이메일 중복 체크
        if (request.getEmail() != null && userMapper.selectByEmail(request.getEmail()) != null) {
            throw new IllegalArgumentException("Email already exists");
        }

        // Username 중복 체크
        if (userMapper.selectByUsername(request.getUsername()) != null) {
            throw new IllegalArgumentException("Username already exists");
        }

            // 사용자 생성
            User user = new User();
            user.setId(UUID.randomUUID());
            user.setUsername(request.getUsername());
            user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
            user.setEmail(request.getEmail());
            user.setNickname(request.getNickname());
            user.setAuthType("local");  // 일반 로그인 사용자
            user.setSocialId(null);     // 소셜 로그인 ID 없음
            user.setCreatedAt(Instant.now());
            user.setUpdatedAt(Instant.now());

        userMapper.insert(user);

        UserResponse response = new UserResponse(
            user.getId(),
            user.getUsername(),
            user.getEmail(),
            user.getNickname()
        );
        response.setAuthType(user.getAuthType());
        return response;
    }

    public User findByUsername(String username) {
        System.out.println("[AuthService] Finding user by username: " + username);
        User user = userMapper.selectByUsername(username);
        if (user != null) {
            System.out.println("[AuthService] User found: " + user.getId());
        } else {
            System.out.println("[AuthService] User not found: " + username);
        }
        return user;
    }

    public User findById(UUID id) {
        return userMapper.selectById(id);
    }

    public UserResponse getUserInfo(UUID userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new IllegalArgumentException("User not found");
        }
        UserResponse response = new UserResponse(
            user.getId(),
            user.getUsername(),
            user.getEmail(),
            user.getNickname()
        );
        // 사용자가 등록한 물품 수 추가
        int itemCount = itemMapper.countByCreatedBy(userId);
        response.setItemCount(itemCount);
        return response;
    }

    public UserResponse updateNickname(UUID userId, String nickname) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new IllegalArgumentException("User not found");
        }
        
        user.setNickname(nickname);
        user.setUpdatedAt(Instant.now());
        userMapper.update(user);
        
        UserResponse response = new UserResponse(
            user.getId(),
            user.getUsername(),
            user.getEmail(),
            user.getNickname()
        );
        response.setAuthType(user.getAuthType());
        return response;
    }
}
