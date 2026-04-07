package com.kidspoint.api.box.mapper;

import com.kidspoint.api.box.domain.Box;
import com.kidspoint.api.box.dto.BoxResponse;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.UUID;

@Mapper
public interface BoxMapper {
    int insert(Box box);
    Box selectById(@Param("organizationId") UUID organizationId, @Param("id") UUID id);
    List<BoxResponse> listWithStats(
        @Param("organizationId") UUID organizationId,
        @Param("limit") Integer limit,
        @Param("offset") Integer offset
    );
    int countByOrganization(@Param("organizationId") UUID organizationId);
    UUID selectOrganizationIdByBoxId(@Param("boxId") UUID boxId); // 박스 ID로 organizationId 조회
    int update(Box box);
    int delete(@Param("organizationId") UUID organizationId, @Param("id") UUID id);
}
