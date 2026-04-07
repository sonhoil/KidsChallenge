package com.kidspoint.api.subscription.mapper;

import com.kidspoint.api.subscription.domain.Subscription;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.UUID;

@Mapper
public interface SubscriptionMapper {
    int insert(Subscription subscription);
    Subscription selectById(@Param("id") UUID id);
    Subscription selectByOrganizationId(@Param("organizationId") UUID organizationId);
    int update(Subscription subscription);
    int delete(@Param("id") UUID id);
}
