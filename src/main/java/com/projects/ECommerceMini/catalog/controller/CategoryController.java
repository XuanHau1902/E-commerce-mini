package com.projects.ECommerceMini.catalog.controller;

import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.projects.ECommerceMini.catalog.dto.CategoryResponse;
import com.projects.ECommerceMini.catalog.service.CategoryService;
import lombok.RequiredArgsConstructor;

@RestController 
@RequestMapping("/api/categories")
@RequiredArgsConstructor 
public class CategoryController {

    private final CategoryService categoryService;

    @GetMapping 
    public List<CategoryResponse> getTree() {
        return categoryService.getTree();
    }
}
