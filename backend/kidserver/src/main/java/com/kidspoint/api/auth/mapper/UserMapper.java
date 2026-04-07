package com.kidspoint.api.auth.mapper;

import com.kidspoint.api.auth.domain.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.UUID;

@Mapper
public interface UserMapper {
    User selectById(@Param("id") UUID id);
    User selectByUsername(@Param("username") String username);
    User selectByEmail(@Param("email") String email);
    User selectByAuthTypeAndSocialId(@Param("authType") String authType, @Param("socialId") String socialId);
    int insert(User user);
    int update(User user);
    int delete(@Param("id") UUID id);
}
