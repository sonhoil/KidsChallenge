package com.kidspoint.api.category.mapper;

import com.kidspoint.api.category.domain.Category;
import com.kidspoint.api.category.dto.CategoryResponse;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.UUID;

@Mapper
public interface CategoryMapper {
    int insert(Category category);
    Category selectById(@Param("id") UUID id);
    List<CategoryResponse> selectByOrganizationId(@Param("organizationId") UUID organizationId);
    int update(Category category);
    int delete(@Param("id") UUID id, @Param("organizationId") UUID organizationId);
}
