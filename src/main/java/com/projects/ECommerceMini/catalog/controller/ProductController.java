package com.projects.ECommerceMini.catalog.controller;

import java.util.Set;

import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import com.projects.ECommerceMini.catalog.dto.ProductSummaryResponse;
import com.projects.ECommerceMini.catalog.service.ProductService;
import com.projects.ECommerceMini.common.dto.PageResponse;

import lombok.RequiredArgsConstructor;

@RestController 
@RequestMapping("/api/products")
@RequiredArgsConstructor 
public class ProductController {

    private static final int MAX_PAGE_SIZE = 50;
    private static final Set<String> SORTABLE_FIELDS = Set.of("name", "createdAt");

    private final ProductService productService;

    @GetMapping
    public PageResponse<ProductSummaryResponse> list(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "createdAt") String sort,
            @RequestParam(defaultValue = "desc") String direction) {
                if (!SORTABLE_FIELDS.contains(sort)) {
                    throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "sort phải là một trong: " + SORTABLE_FIELDS);
                }

                //đảm bảo trang luôn >=0, ko cho phép trang âm
                int safePage = Math.max(page, 0);
                //đảm bảo size luôn >=1 và <= 50
                int safeSize = Math.min(Math.max(size, 1), MAX_PAGE_SIZE);
                Sort.Direction dir = "asc".equalsIgnoreCase(direction) ? Sort.Direction.ASC : Sort.Direction.DESC;

                //sắp xếp chính theo trường SORTABLE_FIELDS, sắp xếp phụ theo id nếu SORTABLE_FIELDS bằng nhau
                Sort order = Sort.by(dir, sort).and(Sort.by("id"));
                Pageable pageable = PageRequest.of(safePage, safeSize, order);

                return productService.list(pageable);
            }

}
