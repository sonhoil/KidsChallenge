package com.kidspoint.api.push.service;

import com.kidspoint.api.push.domain.UserPushToken;
import com.kidspoint.api.push.dto.RegisterFcmTokenRequest;
import com.kidspoint.api.push.mapper.UserPushTokenMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@Transactional
public class PushTokenService {
    private final UserPushTokenMapper userPushTokenMapper;

    public PushTokenService(UserPushTokenMapper userPushTokenMapper) {
        this.userPushTokenMapper = userPushTokenMapper;
    }

    public void registerOrUpdate(UUID userId, RegisterFcmTokenRequest request) {
        UserPushToken row = new UserPushToken();
        row.setUserId(userId);
        row.setFcmToken(request.getFcmToken().trim());
        row.setPlatform(request.getPlatform() != null ? request.getPlatform().trim() : null);
        row.setUpdatedAt(Instant.now());
        userPushTokenMapper.upsert(row);
    }
}
