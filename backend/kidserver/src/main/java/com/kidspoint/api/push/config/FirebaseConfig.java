package com.kidspoint.api.push.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.StringUtils;

import java.io.ByteArrayInputStream;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Base64;

/**
 * FCM: 서비스 계정 JSON. 우선순위:
 * 1) firebase.service-account-b64: Base64(서비스 계정 JSON 전체)
 * 2) firebase.service-account-file: 파일 경로
 * 비어 있으면 FCM 전송을 건너뜀.
 */
@Configuration
public class FirebaseConfig {
    private static final Logger log = LoggerFactory.getLogger(FirebaseConfig.class);

    @Value("${firebase.service-account-b64:}")
    private String serviceAccountBase64;
    @Value("${firebase.service-account-file:}")
    private String serviceAccountFile;

    @PostConstruct
    public void init() {
        if (FirebaseApp.getApps() != null && !FirebaseApp.getApps().isEmpty()) {
            return;
        }
        try {
            InputStream in = null;
            if (StringUtils.hasText(serviceAccountBase64)) {
                byte[] json = Base64.getDecoder().decode(serviceAccountBase64.trim());
                in = new ByteArrayInputStream(json);
                log.info("[Firebase] Initializing from firebase.service-account-b64");
            } else if (StringUtils.hasText(serviceAccountFile)) {
                in = new FileInputStream(serviceAccountFile);
                log.info("[Firebase] Initializing from file {}", serviceAccountFile);
            }
            if (in == null) {
                log.warn("[Firebase] No credentials. Push notifications disabled. Set firebase.service-account-b64 or firebase.service-account-file.");
                return;
            }
            try (InputStream input = in) {
                FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(input))
                    .build();
                FirebaseApp.initializeApp(options);
                log.info("[Firebase] FCM ready");
            }
        } catch (Exception e) {
            log.error("[Firebase] Init failed, push disabled: {}", e.getMessage());
        }
    }
}
