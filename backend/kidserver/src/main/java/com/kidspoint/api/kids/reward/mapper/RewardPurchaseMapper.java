package com.kidspoint.api.kids.reward.mapper;

import com.kidspoint.api.kids.reward.domain.RewardPurchase;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.UUID;

@Mapper
public interface RewardPurchaseMapper {
    int insert(RewardPurchase purchase);
    RewardPurchase selectById(@Param("id") UUID id);
    List<RewardPurchase> selectByBuyerId(@Param("buyerId") UUID buyerId);
    List<RewardPurchase> selectByBuyerIdAndStatus(@Param("buyerId") UUID buyerId, @Param("status") RewardPurchase.PurchaseStatus status);
    List<RewardPurchase> selectByFamilyId(@Param("familyId") UUID familyId);
    int update(RewardPurchase purchase);
}
