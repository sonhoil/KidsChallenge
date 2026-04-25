package com.kidspoint.api.push.mapper;

import com.kidspoint.api.push.domain.UserPushToken;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.UUID;

@Mapper
public interface UserPushTokenMapper {
    int upsert(UserPushToken row);

    UserPushToken selectByUserId(@Param("userId") UUID userId);

    /** 아이(자녀) 역할이 있는 사용자 FCM 토큰 (일일 미션 알림용) */
    List<String> selectFcmTokensForChildRoleUsers();
}
