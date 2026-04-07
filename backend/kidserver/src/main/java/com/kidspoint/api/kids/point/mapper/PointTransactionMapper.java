package com.kidspoint.api.kids.point.mapper;

import com.kidspoint.api.kids.point.domain.PointTransaction;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.UUID;

@Mapper
public interface PointTransactionMapper {
    int insert(PointTransaction transaction);
    List<PointTransaction> selectByPointAccountId(@Param("pointAccountId") UUID pointAccountId);
    List<PointTransaction> selectByPointAccountIdOrderByCreatedAtDesc(@Param("pointAccountId") UUID pointAccountId, @Param("limit") Integer limit);
}
