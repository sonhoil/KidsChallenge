package com.kidspoint.api.item.service;

import com.kidspoint.api.auth.domain.User;
import com.kidspoint.api.auth.mapper.UserMapper;
import com.kidspoint.api.box.mapper.BoxMapper;
import com.kidspoint.api.box.domain.Box;
import com.kidspoint.api.item.domain.Item;
import com.kidspoint.api.item.dto.CreateItemRequest;
import com.kidspoint.api.item.dto.ItemResponse;
import com.kidspoint.api.item.dto.UpdateItemRequest;
import com.kidspoint.api.item.mapper.ItemMapper;
import com.kidspoint.api.organization.service.OrganizationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class ItemService {

    private final ItemMapper itemMapper;
    private final BoxMapper boxMapper;
    private final UserMapper userMapper;
    private final OrganizationService organizationService;

    @Autowired
    public ItemService(ItemMapper itemMapper, BoxMapper boxMapper, UserMapper userMapper, OrganizationService organizationService) {
        this.itemMapper = itemMapper;
        this.boxMapper = boxMapper;
        this.userMapper = userMapper;
        this.organizationService = organizationService;
    }

    public ItemResponse createItem(UUID userId, UUID organizationId, CreateItemRequest request) {
        // 박스가 조직에 속하는지 확인
        Box box = boxMapper.selectById(organizationId, request.getBoxId());
        if (box == null) {
            throw new IllegalStateException("Box not found or does not belong to this organization");
        }

        // 아이템 생성
        Item item = new Item();
        UUID itemId = UUID.randomUUID();
        item.setId(itemId);
        item.setBoxId(request.getBoxId());
        item.setName(request.getName());
        item.setDescription(request.getDescription());
        item.setImageUrl(request.getImageUrl() != null && !request.getImageUrl().isEmpty() 
            ? request.getImageUrl() : null);
        item.setQrCode(itemId.toString()); // QR 코드는 아이템 UUID를 문자열로 저장
        item.setCreatedAt(Instant.now());
        item.setUpdatedAt(Instant.now());
        item.setCreatedBy(userId);

        itemMapper.insert(item);

        // 카테고리 처리
        if (request.getCategories() != null && !request.getCategories().isEmpty()) {
            for (String categoryName : request.getCategories()) {
                if (categoryName != null && !categoryName.trim().isEmpty()) {
                    // 카테고리 찾기 또는 생성
                    UUID categoryId = itemMapper.findOrCreateCategory(categoryName.trim(), organizationId);
                    // item_categories에 연결
                    itemMapper.insertItemCategory(itemId, categoryId);
                }
            }
        }

        ItemResponse response = toResponse(item, box);
        // 카테고리 정보 추가
        if (request.getCategories() != null && !request.getCategories().isEmpty()) {
            response.setCategories(request.getCategories());
        }
        return response;
    }

    public ItemResponse getItemDetail(String idOrQrUuid, UUID organizationId) {
        Item item = itemMapper.selectByIdOrQrUuid(idOrQrUuid);
        if (item == null) {
            throw new IllegalArgumentException("Item not found");
        }

        // 삭제된 물건은 조회 불가 (관리자는 permanentlyDeleteItem을 통해 접근)
        if (item.getDeletedAt() != null) {
            throw new IllegalArgumentException("Item not found");
        }

        // 박스가 조직에 속하는지 확인
        Box box = boxMapper.selectById(organizationId, item.getBoxId());
        if (box == null) {
            throw new IllegalStateException("Item does not belong to this organization");
        }

        return toResponse(item, box);
    }

    public List<ItemResponse> listItemsByBox(UUID boxId, UUID organizationId, Integer page, Integer size) {
        // 박스가 조직에 속하는지 확인
        Box box = boxMapper.selectById(organizationId, boxId);
        if (box == null) {
            throw new IllegalStateException("Box not found or does not belong to this organization");
        }

        if (size == null || size <= 0) {
            size = 50;
        }
        if (size > 100) {
            size = 100;
        }
        if (page == null || page < 0) {
            page = 0;
        }
        int offset = page * size;

        List<ItemResponse> items = itemMapper.selectPageByBoxWithJoin(boxId, size, offset);
        // 사용자 이름이 없는 경우 조회하여 설정
        // 카테고리 정보 추가
        for (ItemResponse item : items) {
            if (item.getInUseByUserId() != null && item.getInUseByUserName() == null) {
                User user = userMapper.selectById(item.getInUseByUserId());
                if (user != null) {
                    item.setInUseByUserName(user.getNickname() != null ? user.getNickname() : user.getUsername());
                }
            }
            // 카테고리 조회
            List<String> categories = itemMapper.selectItemCategories(item.getId());
            item.setCategories(categories);
        }
        return items;
    }

    public ItemResponse updateItem(String idOrQrUuid, UUID organizationId, UpdateItemRequest request) {
        Item item = itemMapper.selectByIdOrQrUuid(idOrQrUuid);
        if (item == null) {
            throw new IllegalArgumentException("Item not found");
        }

        // 삭제된 물건은 수정 불가
        if (item.getDeletedAt() != null) {
            throw new IllegalStateException("Item is deleted");
        }

        // 박스가 조직에 속하는지 확인
        Box box = boxMapper.selectById(organizationId, item.getBoxId());
        if (box == null) {
            throw new IllegalStateException("Item does not belong to this organization");
        }

        if (request.getName() != null) {
            item.setName(request.getName());
        }
        if (request.getDescription() != null) {
            item.setDescription(request.getDescription());
        }
        if (request.getImageUrl() != null) {
            item.setImageUrl(request.getImageUrl().isEmpty() ? null : request.getImageUrl());
        }
        item.setUpdatedAt(Instant.now());

        itemMapper.update(item);

        // 카테고리 업데이트
        if (request.getCategories() != null) {
            // 기존 카테고리 삭제
            itemMapper.deleteItemCategories(item.getId());
            // 새 카테고리 추가
            for (String categoryName : request.getCategories()) {
                if (categoryName != null && !categoryName.trim().isEmpty()) {
                    // 카테고리 찾기 또는 생성
                    UUID categoryId = itemMapper.findOrCreateCategory(categoryName.trim(), organizationId);
                    // item_categories에 연결
                    itemMapper.insertItemCategory(item.getId(), categoryId);
                }
            }
        }

        ItemResponse response = toResponse(item, box);
        // 카테고리 정보 추가
        if (request.getCategories() != null) {
            response.setCategories(request.getCategories());
        } else {
            // 기존 카테고리 조회
            List<String> categories = itemMapper.selectItemCategories(item.getId());
            response.setCategories(categories);
        }
        return response;
    }

    public void deleteItem(String idOrQrUuid, UUID organizationId) {
        Item item = itemMapper.selectByIdOrQrUuid(idOrQrUuid);
        if (item == null) {
            throw new IllegalArgumentException("Item not found");
        }

        // 박스가 조직에 속하는지 확인
        Box box = boxMapper.selectById(organizationId, item.getBoxId());
        if (box == null) {
            throw new IllegalStateException("Item does not belong to this organization");
        }

        // 이미 삭제된 경우
        if (item.getDeletedAt() != null) {
            throw new IllegalStateException("Item is already deleted");
        }

        // Soft delete 수행
        itemMapper.softDelete(item.getId());
    }

    /**
     * 관리자용 삭제 취소 (Restore)
     */
    public ItemResponse restoreItem(UUID userId, String idOrQrUuid, UUID organizationId) {
        // 관리자 권한 확인
        try {
            com.kidspoint.api.organization.domain.OrganizationMember.OrgRole role = organizationService.getUserRoleInOrg(userId, organizationId);
            if (role != com.kidspoint.api.organization.domain.OrganizationMember.OrgRole.admin) {
                throw new IllegalStateException("Only admins can restore items");
            }
        } catch (IllegalStateException e) {
            throw new IllegalStateException("Only admins can restore items");
        }

        Item item = itemMapper.selectByIdOrQrUuid(idOrQrUuid);
        if (item == null) {
            throw new IllegalArgumentException("Item not found");
        }

        // 삭제되지 않은 물건은 복구 불가
        if (item.getDeletedAt() == null) {
            throw new IllegalStateException("Item is not deleted");
        }

        // 박스가 조직에 속하는지 확인
        Box box = boxMapper.selectById(organizationId, item.getBoxId());
        if (box == null) {
            throw new IllegalStateException("Item does not belong to this organization");
        }

        // 삭제 취소 수행
        int updated = itemMapper.restore(item.getId());
        if (updated == 0) {
            throw new IllegalStateException("Failed to restore item");
        }

        // 복구된 아이템 다시 조회
        item = itemMapper.selectById(item.getId());
        return toResponse(item, box);
    }

    /**
     * 관리자용 실제 삭제 (Hard delete)
     */
    public void permanentlyDeleteItem(UUID userId, String idOrQrUuid, UUID organizationId) {
        // 관리자 권한 확인
        try {
            com.kidspoint.api.organization.domain.OrganizationMember.OrgRole role = organizationService.getUserRoleInOrg(userId, organizationId);
            if (role != com.kidspoint.api.organization.domain.OrganizationMember.OrgRole.admin) {
                throw new IllegalStateException("Only admins can permanently delete items");
            }
        } catch (IllegalStateException e) {
            throw new IllegalStateException("Only admins can permanently delete items");
        }

        Item item = itemMapper.selectByIdOrQrUuid(idOrQrUuid);
        if (item == null) {
            throw new IllegalArgumentException("Item not found");
        }

        // 박스가 조직에 속하는지 확인
        Box box = boxMapper.selectById(organizationId, item.getBoxId());
        if (box == null) {
            throw new IllegalStateException("Item does not belong to this organization");
        }

        // 실제 삭제 수행
        itemMapper.delete(item.getId());
    }

    public ItemResponse useItem(String idOrQrUuid, UUID userId, UUID organizationId) {
        Item item = itemMapper.selectByIdOrQrUuid(idOrQrUuid);
        if (item == null) {
            throw new IllegalArgumentException("Item not found");
        }

        // 삭제된 물건은 사용 불가
        if (item.getDeletedAt() != null) {
            throw new IllegalStateException("Item is deleted");
        }

        // 박스가 조직에 속하는지 확인
        Box box = boxMapper.selectById(organizationId, item.getBoxId());
        if (box == null) {
            throw new IllegalStateException("Item does not belong to this organization");
        }

        // 이미 사용 중인지 확인
        if (item.getInUseByUserId() != null) {
            throw new IllegalStateException("Item is already in use by another user");
        }

        // 사용하기 처리
        Instant now = Instant.now();
        itemMapper.updateInUse(item.getId(), userId, now, now);
        item.setInUseByUserId(userId);
        item.setInUseAt(now);
        item.setUpdatedAt(now);

        return toResponse(item, box);
    }

    public ItemResponse returnItem(String idOrQrUuid, UUID userId, UUID organizationId) {
        Item item = itemMapper.selectByIdOrQrUuid(idOrQrUuid);
        if (item == null) {
            throw new IllegalArgumentException("Item not found");
        }

        // 삭제된 물건은 반납 불가
        if (item.getDeletedAt() != null) {
            throw new IllegalStateException("Item is deleted");
        }

        // 박스가 조직에 속하는지 확인
        Box box = boxMapper.selectById(organizationId, item.getBoxId());
        if (box == null) {
            throw new IllegalStateException("Item does not belong to this organization");
        }

        // 사용 중이 아니면 오류
        if (item.getInUseByUserId() == null) {
            throw new IllegalStateException("Item is not currently in use");
        }

        // 반납하기 처리
        Instant now = Instant.now();
        itemMapper.updateReturn(item.getId(), now);
        item.setInUseByUserId(null);
        item.setInUseAt(null);
        item.setUpdatedAt(now);

        return toResponse(item, box);
    }

    public ItemResponse moveItem(String idOrQrUuid, UUID newBoxId, UUID userId, UUID organizationId) {
        Item item = itemMapper.selectByIdOrQrUuid(idOrQrUuid);
        if (item == null) {
            throw new IllegalArgumentException("Item not found");
        }

        // 삭제된 물건은 이동 불가
        if (item.getDeletedAt() != null) {
            throw new IllegalStateException("Item is deleted");
        }

        // 기존 박스가 조직에 속하는지 확인
        Box oldBox = boxMapper.selectById(organizationId, item.getBoxId());
        if (oldBox == null) {
            throw new IllegalStateException("Item does not belong to this organization");
        }

        // 새 박스가 조직에 속하는지 확인
        Box newBox = boxMapper.selectById(organizationId, newBoxId);
        if (newBox == null) {
            throw new IllegalStateException("Target box not found or does not belong to this organization");
        }

        // 이동하기 처리
        Instant now = Instant.now();
        itemMapper.updateMoveBox(item.getId(), newBoxId, now);
        item.setBoxId(newBoxId);
        item.setUpdatedAt(now);

        return toResponse(item, newBox);
    }

    private ItemResponse toResponse(Item item, Box box) {
        ItemResponse response = new ItemResponse();
        response.setId(item.getId());
        response.setBoxId(item.getBoxId());
        response.setBoxName(box.getName());
        response.setBoxLocation(box.getLocation());
        response.setName(item.getName());
        response.setDescription(item.getDescription());
        response.setImageUrl(item.getImageUrl());
        response.setQrCode(item.getQrCode());
        response.setCreatedAt(item.getCreatedAt());
        response.setUpdatedAt(item.getUpdatedAt());
        response.setInUseByUserId(item.getInUseByUserId());
        response.setInUseAt(item.getInUseAt());
        response.setDeletedAt(item.getDeletedAt());
        
        // 사용자 이름 조회
        if (item.getInUseByUserId() != null) {
            User user = userMapper.selectById(item.getInUseByUserId());
            if (user != null) {
                response.setInUseByUserName(user.getNickname() != null ? user.getNickname() : user.getUsername());
            }
        }
        
        // 카테고리 조회
        List<String> categories = itemMapper.selectItemCategories(item.getId());
        response.setCategories(categories);
        
        return response;
    }
}
