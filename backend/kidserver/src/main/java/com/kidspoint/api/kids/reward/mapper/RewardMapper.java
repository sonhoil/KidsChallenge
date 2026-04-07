package com.kidspoint.api.kids.reward.mapper;

import com.kidspoint.api.kids.reward.domain.Reward;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.UUID;

@Mapper
public interface RewardMapper {
    int insert(Reward reward);
    Reward selectById(@Param("id") UUID id);
    List<Reward> selectByFamilyId(@Param("familyId") UUID familyId);
    List<Reward> selectActiveByFamilyId(@Param("familyId") UUID familyId);
    int update(Reward reward);
    int delete(@Param("id") UUID id);
}
