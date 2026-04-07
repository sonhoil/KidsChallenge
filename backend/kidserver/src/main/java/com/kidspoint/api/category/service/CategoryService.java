package com.kidspoint.api.category.service;

import com.kidspoint.api.category.domain.Category;
import com.kidspoint.api.category.dto.CategoryResponse;
import com.kidspoint.api.category.dto.CreateCategoryRequest;
import com.kidspoint.api.category.dto.UpdateCategoryRequest;
import com.kidspoint.api.category.mapper.CategoryMapper;
import com.kidspoint.api.organization.mapper.OrganizationMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class CategoryService {

    private final CategoryMapper categoryMapper;
    private final OrganizationMapper organizationMapper;

    @Autowired
    public CategoryService(CategoryMapper categoryMapper, OrganizationMapper organizationMapper) {
        this.categoryMapper = categoryMapper;
        this.organizationMapper = organizationMapper;
    }

    public CategoryResponse createCategory(UUID organizationId, CreateCategoryRequest request) {
        // 조직 존재 확인
        if (organizationMapper.selectById(organizationId) == null) {
            throw new IllegalArgumentException("Organization not found");
        }

        // 카테고리 생성
        Category category = new Category();
        category.setId(UUID.randomUUID());
        category.setOrganizationId(organizationId);
        category.setName(request.getName());
        category.setDescription(request.getDescription());
        category.setColor(request.getColor() != null && !request.getColor().isEmpty() 
            ? request.getColor() : "#3b82f6");
        category.setCreatedAt(Instant.now());

        categoryMapper.insert(category);

        return toResponse(category);
    }

    public List<CategoryResponse> listCategories(UUID organizationId) {
        return categoryMapper.selectByOrganizationId(organizationId);
    }

    public CategoryResponse getCategory(UUID organizationId, UUID categoryId) {
        Category category = categoryMapper.selectById(categoryId);
        if (category == null) {
            throw new IllegalArgumentException("Category not found");
        }
        if (!category.getOrganizationId().equals(organizationId)) {
            throw new IllegalStateException("Category does not belong to this organization");
        }
        return toResponse(category);
    }

    public CategoryResponse updateCategory(UUID organizationId, UUID categoryId, UpdateCategoryRequest request) {
        Category category = categoryMapper.selectById(categoryId);
        if (category == null) {
            throw new IllegalArgumentException("Category not found");
        }
        if (!category.getOrganizationId().equals(organizationId)) {
            throw new IllegalStateException("Category does not belong to this organization");
        }

        if (request.getName() != null) {
            category.setName(request.getName());
        }
        if (request.getDescription() != null) {
            category.setDescription(request.getDescription());
        }
        if (request.getColor() != null) {
            category.setColor(request.getColor());
        }

        categoryMapper.update(category);

        return toResponse(category);
    }

    public void deleteCategory(UUID organizationId, UUID categoryId) {
        Category category = categoryMapper.selectById(categoryId);
        if (category == null) {
            throw new IllegalArgumentException("Category not found");
        }
        if (!category.getOrganizationId().equals(organizationId)) {
            throw new IllegalStateException("Category does not belong to this organization");
        }

        categoryMapper.delete(categoryId, organizationId);
    }

    private CategoryResponse toResponse(Category category) {
        CategoryResponse response = new CategoryResponse();
        response.setId(category.getId());
        response.setOrganizationId(category.getOrganizationId());
        response.setName(category.getName());
        response.setDescription(category.getDescription());
        response.setColor(category.getColor());
        response.setCreatedAt(category.getCreatedAt());
        return response;
    }
}
