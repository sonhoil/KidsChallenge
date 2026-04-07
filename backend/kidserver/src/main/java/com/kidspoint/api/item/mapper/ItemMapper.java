package com.kidspoint.api.item.mapper;

import com.kidspoint.api.item.domain.Item;
import com.kidspoint.api.item.dto.ItemResponse;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.UUID;

@Mapper
public interface ItemMapper {
    int insert(Item item);
    Item selectById(@Param("id") UUID id);
    Item selectByIdOrQrUuid(@Param("idOrQrUuid") String idOrQrUuid);
    List<ItemResponse> selectPageByBoxWithJoin(
        @Param("boxId") UUID boxId,
        @Param("limit") Integer limit,
        @Param("offset") Integer offset
    );
    int update(Item item);
    int softDelete(@Param("id") UUID id);
    int restore(@Param("id") UUID id);
    int delete(@Param("id") UUID id);
    Item selectByBoxIdAndOrgId(@Param("boxId") UUID boxId, @Param("organizationId") UUID organizationId);
    int updateInUse(@Param("id") UUID id, @Param("userId") UUID userId, @Param("inUseAt") java.time.Instant inUseAt, @Param("updatedAt") java.time.Instant updatedAt);
    int updateReturn(@Param("id") UUID id, @Param("updatedAt") java.time.Instant updatedAt);
    int updateMoveBox(@Param("id") UUID id, @Param("newBoxId") UUID newBoxId, @Param("updatedAt") java.time.Instant updatedAt);
    
    // 카테고리 관련 메서드
    UUID findOrCreateCategory(@Param("categoryName") String categoryName, @Param("organizationId") UUID organizationId);
    void insertItemCategory(@Param("itemId") UUID itemId, @Param("categoryId") UUID categoryId);
    void deleteItemCategories(@Param("itemId") UUID itemId);
    List<String> selectItemCategories(@Param("itemId") UUID itemId);
    
    // 사용자가 등록한 물품 수 조회
    int countByCreatedBy(@Param("userId") UUID userId);
}
