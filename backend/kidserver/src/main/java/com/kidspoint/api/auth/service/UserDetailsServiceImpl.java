package com.kidspoint.api.auth.service;

import com.kidspoint.api.auth.domain.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    private final AuthService authService;

    @Autowired
    public UserDetailsServiceImpl(AuthService authService) {
        this.authService = authService;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user;
        
        // username이 UUID 형식인지 확인 (카카오 로그인 등에서 UUID를 username으로 사용)
        try {
            UUID userId = UUID.fromString(username);
            // UUID 형식이면 ID로 조회
            user = authService.findById(userId);
        } catch (IllegalArgumentException e) {
            // UUID 형식이 아니면 일반 username으로 조회 (일반 로그인)
            user = authService.findByUsername(username);
        }
        
        if (user == null) {
            throw new UsernameNotFoundException("User not found: " + username);
        }

        return new org.springframework.security.core.userdetails.User(
            user.getId().toString(), // username으로 UUID 사용
            user.getPasswordHash(),
            getAuthorities(user)
        );
    }

    private Collection<? extends GrantedAuthority> getAuthorities(User user) {
        List<GrantedAuthority> authorities = new ArrayList<>();
        // 기본 권한 추가 (추후 역할 기반 권한으로 확장 가능)
        authorities.add(new SimpleGrantedAuthority("ROLE_USER"));
        return authorities;
    }
}
