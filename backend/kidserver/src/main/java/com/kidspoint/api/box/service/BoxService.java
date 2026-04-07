package com.kidspoint.api.box.service;

import com.kidspoint.api.box.domain.Box;
import com.kidspoint.api.box.dto.BoxResponse;
import com.kidspoint.api.box.dto.CreateBoxRequest;
import com.kidspoint.api.box.dto.UpdateBoxRequest;
import com.kidspoint.api.box.mapper.BoxMapper;
import com.kidspoint.api.organization.mapper.OrganizationMapper;
import com.kidspoint.api.organization.domain.Organization;
import com.kidspoint.api.organization.service.OrganizationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class BoxService {

    private final BoxMapper boxMapper;
    private final OrganizationMapper organizationMapper;
    private final OrganizationService organizationService;

    @Autowired
    public BoxService(BoxMapper boxMapper, OrganizationMapper organizationMapper, OrganizationService organizationService) {
        this.boxMapper = boxMapper;
        this.organizationMapper = organizationMapper;
        this.organizationService = organizationService;
    }

    public BoxResponse createBox(UUID userId, UUID organizationId, CreateBoxRequest request) {
        // 조직 존재 및 박스 한도 확인
        Organization organization = organizationMapper.selectById(organizationId);
        if (organization == null) {
            throw new IllegalArgumentException("Organization not found");
        }

        int currentBoxCount = boxMapper.countByOrganization(organizationId);
        int boxLimit = organization.getBoxLimit() != null ? organization.getBoxLimit() : 5;

        if (currentBoxCount >= boxLimit) {
            throw new IllegalStateException("Box limit exceeded for this organization");
        }

        // 박스 생성
        Box box = new Box();
        box.setId(UUID.randomUUID());
        box.setOrganizationId(organizationId);
        box.setName(request.getName());
        box.setLocation(request.getLocation());
        box.setDescription(request.getDescription());
        box.setQrCode(box.getId().toString()); // QR 코드는 박스 UUID를 문자열로 저장
        box.setCreatedAt(Instant.now());
        box.setUpdatedAt(Instant.now());
        box.setCreatedBy(userId);

        boxMapper.insert(box);

        return toResponse(box);
    }

    public List<BoxResponse> listBoxes(UUID organizationId, Integer limit, Integer offset) {
        if (limit == null || limit <= 0) {
            limit = 50;
        }
        if (limit > 100) {
            limit = 100;
        }
        if (offset == null || offset < 0) {
            offset = 0;
        }

        return boxMapper.listWithStats(organizationId, limit, offset);
    }

    public BoxResponse getBox(UUID organizationId, UUID boxId) {
        Box box = boxMapper.selectById(organizationId, boxId);
        if (box == null) {
            throw new IllegalArgumentException("Box not found");
        }
        return toResponse(box);
    }

    public BoxResponse updateBox(UUID userId, UUID organizationId, UUID boxId, UpdateBoxRequest request) {
        // 관리자 권한 확인
        try {
            com.kidspoint.api.organization.domain.OrganizationMember.OrgRole role = organizationService.getUserRoleInOrg(userId, organizationId);
            if (role != com.kidspoint.api.organization.domain.OrganizationMember.OrgRole.admin) {
                throw new IllegalStateException("Only admins can update boxes");
            }
        } catch (IllegalStateException e) {
            throw new IllegalStateException("Only admins can update boxes");
        }

        Box box = boxMapper.selectById(organizationId, boxId);
        if (box == null) {
            throw new IllegalArgumentException("Box not found");
        }

        if (request.getName() != null) {
            box.setName(request.getName());
        }
        if (request.getLocation() != null) {
            box.setLocation(request.getLocation());
        }
        if (request.getDescription() != null) {
            box.setDescription(request.getDescription());
        }
        box.setUpdatedAt(Instant.now());

        boxMapper.update(box);

        return toResponse(box);
    }

    public void deleteBox(UUID userId, UUID organizationId, UUID boxId) {
        // 관리자 권한 확인
        try {
            com.kidspoint.api.organization.domain.OrganizationMember.OrgRole role = organizationService.getUserRoleInOrg(userId, organizationId);
            if (role != com.kidspoint.api.organization.domain.OrganizationMember.OrgRole.admin) {
                throw new IllegalStateException("Only admins can delete boxes");
            }
        } catch (IllegalStateException e) {
            throw new IllegalStateException("Only admins can delete boxes");
        }

        Box box = boxMapper.selectById(organizationId, boxId);
        if (box == null) {
            throw new IllegalArgumentException("Box not found");
        }

        try {
            boxMapper.delete(organizationId, boxId);
        } catch (Exception e) {
            // FK 제약 위반 시 409 에러
            if (e.getMessage() != null && e.getMessage().contains("violates foreign key constraint")) {
                throw new IllegalStateException("Cannot delete box: items exist in this box");
            }
            throw e;
        }
    }

    /**
     * 박스 ID만으로 단체 ID 조회 (QR 스캔 딥링크용)
     */
    public UUID getBoxOrganizationId(UUID boxId) {
        UUID organizationId = boxMapper.selectOrganizationIdByBoxId(boxId);
        if (organizationId == null) {
            throw new IllegalArgumentException("Box not found");
        }
        return organizationId;
    }

    private BoxResponse toResponse(Box box) {
        BoxResponse response = new BoxResponse();
        response.setId(box.getId());
        response.setOrganizationId(box.getOrganizationId());
        response.setName(box.getName());
        response.setLocation(box.getLocation());
        response.setDescription(box.getDescription());
        response.setCreatedAt(box.getCreatedAt());
        response.setUpdatedAt(box.getUpdatedAt());
        return response;
    }
}
