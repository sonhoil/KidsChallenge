package com.kidspoint.api.push.schedule;

import com.kidspoint.api.push.service.FcmPushService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * 아이 계정: 매일 오전 일정 시각에 오늘 미션 수행 알림 (FCM).
 * {@code fcm.daily-cron} 기본: 매일 08:00 (Asia/Seoul)
 */
@Component
public class DailyMissionNotificationScheduler {
    private static final Logger log = LoggerFactory.getLogger(DailyMissionNotificationScheduler.class);

    private final FcmPushService fcmPushService;

    public DailyMissionNotificationScheduler(FcmPushService fcmPushService) {
        this.fcmPushService = fcmPushService;
    }

    @Scheduled(cron = "${fcm.daily-cron:0 0 8 * * *}", zone = "Asia/Seoul")
    public void sendDailyReminders() {
        if (!fcmPushService.isFcmEnabled()) {
            return;
        }
        try {
            fcmPushService.sendDailyMissionReminders();
        } catch (Exception e) {
            log.error("[FCM] Daily reminder error: {}", e.getMessage());
        }
    }
}
