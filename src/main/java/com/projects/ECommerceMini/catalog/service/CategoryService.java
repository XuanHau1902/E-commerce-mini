package com.projects.ECommerceMini.catalog.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.projects.ECommerceMini.catalog.dto.CategoryResponse;
import com.projects.ECommerceMini.catalog.entity.Category;
import com.projects.ECommerceMini.catalog.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;

@Service 
@RequiredArgsConstructor 
public class CategoryService {
    private final CategoryRepository categoryRepository;

    @Transactional(readOnly = true)
    public List<CategoryResponse> getTree() {
        List<Category> all = categoryRepository.findByActiveTrueOrderBySortOrderAsc();

        // nhóm danh mục theo id của cha. Danh mục gốc có khóa là null.
        Map<UUID, List<Category>> childrenByParentId = new HashMap<>();
        for (Category category : all) {
            UUID parentId = category.getParent() == null ? null : category.getParent().getId();
            childrenByParentId.computeIfAbsent(parentId, key -> new ArrayList<>()).add(category);
        }

        return buildLevel(null, childrenByParentId);
    }

    //hàm đệ quy để xây dựng cây
    private List<CategoryResponse> buildLevel(UUID parentId, Map<UUID,List<Category>> childrenByParentId) {
        List<Category> level = childrenByParentId.getOrDefault(parentId, List.of());
        List<CategoryResponse> result = new ArrayList<>();
        for (Category category : level) {
            result.add(new CategoryResponse(
                    category.getId(),
                    category.getName(),
                    category.getSlug(),
                    buildLevel(category.getId(), childrenByParentId)));
        }
        return result;
    }
}
