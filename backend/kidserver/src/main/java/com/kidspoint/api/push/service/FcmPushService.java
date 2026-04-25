package com.kidspoint.api.push.service;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.BatchResponse;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import com.kidspoint.api.push.domain.UserPushToken;
import com.kidspoint.api.push.mapper.UserPushTokenMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class FcmPushService {
    private static final Logger log = LoggerFactory.getLogger(FcmPushService.class);
    public static final String DATA_TYPE = "type";
    public static final String TYPE_DAILY_MISSION = "DAILY_MISSION";
    public static final String TYPE_MISSION_SUBMIT = "MISSION_SUBMIT";
    public static final String TYPE_MISSION_APPROVED = "MISSION_APPROVED";
    public static final String TYPE_MISSION_REJECTED = "MISSION_REJECTED";
    public static final String TYPE_REWARD_PURCHASED = "REWARD_PURCHASED";

    private final UserPushTokenMapper userPushTokenMapper;

    public FcmPushService(UserPushTokenMapper userPushTokenMapper) {
        this.userPushTokenMapper = userPushTokenMapper;
    }

    public boolean isFcmEnabled() {
        return FirebaseApp.getApps() != null && !FirebaseApp.getApps().isEmpty();
    }

    public void sendToUser(UUID userId, String title, String body, Map<String, String> data) {
        if (!isFcmEnabled()) {
            return;
        }
        UserPushToken t = userPushTokenMapper.selectByUserId(userId);
        if (t == null || t.getFcmToken() == null || t.getFcmToken().isBlank()) {
            return;
        }
        sendToTokens(List.of(t.getFcmToken()), title, body, data);
    }

    public void sendToUsers(List<UUID> userIds, String title, String body, Map<String, String> data) {
        if (!isFcmEnabled() || userIds == null || userIds.isEmpty()) {
            return;
        }
        List<String> tokens = new ArrayList<>();
        for (UUID uid : userIds) {
            UserPushToken t = userPushTokenMapper.selectByUserId(uid);
            if (t != null && t.getFcmToken() != null && !t.getFcmToken().isBlank()) {
                tokens.add(t.getFcmToken());
            }
        }
        sendToTokens(tokens, title, body, data);
    }

    public void sendDailyMissionReminders() {
        if (!isFcmEnabled()) {
            return;
        }
        List<String> tokens = userPushTokenMapper.selectFcmTokensForChildRoleUsers();
        if (tokens == null || tokens.isEmpty()) {
            log.info("[FCM] No child FCM tokens for daily reminder");
            return;
        }
        Map<String, String> data = new HashMap<>();
        data.put(DATA_TYPE, TYPE_DAILY_MISSION);
        sendToTokens(tokens, "오늘의 미션", "오늘 할 일을 확인해보자!", data);
    }

    private void sendToTokens(List<String> tokens, String title, String body, Map<String, String> data) {
        if (tokens == null || tokens.isEmpty()) {
            return;
        }
        List<String> clean = tokens.stream()
            .filter(s -> s != null && !s.isBlank())
            .distinct()
            .collect(Collectors.toList());
        if (clean.isEmpty()) {
            return;
        }
        int batchSize = 500;
        for (int i = 0; i < clean.size(); i += batchSize) {
            int end = Math.min(i + batchSize, clean.size());
            List<String> batch = clean.subList(i, end);
            List<Message> messages = new ArrayList<>();
            for (String token : batch) {
                Message.Builder b = Message.builder()
                    .setToken(token)
                    .setNotification(Notification.builder().setTitle(title).setBody(body).build());
                if (data != null) {
                    b.putAllData(data);
                }
                messages.add(b.build());
            }
            try {
                BatchResponse response = FirebaseMessaging.getInstance().sendEach(messages);
                if (response.getFailureCount() > 0) {
                    log.warn("[FCM] Partial failure: {}/{}", response.getFailureCount(), response.getResponses().size());
                }
            } catch (Exception e) {
                log.warn("[FCM] sendEach: {}", e.getMessage());
            }
        }
    }
}
