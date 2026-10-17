package com.projects.ECommerceMini.catalog.service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.projects.ECommerceMini.catalog.dto.ProductSummaryResponse;
import com.projects.ECommerceMini.catalog.entity.Product;
import com.projects.ECommerceMini.catalog.repository.ProductImageRepository;
import com.projects.ECommerceMini.catalog.repository.ProductRepository;
import com.projects.ECommerceMini.catalog.repository.ProductVariantRepository;
import com.projects.ECommerceMini.common.dto.PageResponse;
import com.projects.ECommerceMini.catalog.dto.ProductMinPrice;
import com.projects.ECommerceMini.catalog.dto.ProductPrimaryImage;

import lombok.RequiredArgsConstructor;

@Service 
@RequiredArgsConstructor 
public class ProductService {

    private static final String STATUS_ACTIVE = "ACTIVE";

    private final ProductRepository productRepository;
    private final ProductImageRepository productImageRepository;
    private final ProductVariantRepository productVariantRepository;

    @Transactional(readOnly = true)
    //hàm liệt kê sản phẩm dưới dạng page
    public PageResponse<ProductSummaryResponse> list(Pageable pageable) {

        //Trang sản phẩm được lọc qua hàm isActive
        Page<Product> products = productRepository.findAll(isActive(),pageable);

        //Transform từng products thành id qua stream().map(Product::getId) rồi trả về danh sách UUID
        List<UUID> ids = products.getContent().stream()
                .map(Product::getId)
                .toList();

        //Map UUID của từng product với giá thấp nhất
        Map<UUID, BigDecimal> minPrices = findMinPrices(ids);
        //Map UUID của từng product với ảnh chính
        Map<UUID, String> primaryImages = findPrimaryImages(ids);

        //Transform từng product thành ProductSummaryResponse rồi thêm trường minprice và primaryimage
        Page<ProductSummaryResponse> result = products.map(product -> new ProductSummaryResponse(
                product.getId(),
                product.getName(),
                product.getSlug(),
                product.getBrand(),
                minPrices.get(product.getId()),
                primaryImages.get(product.getId())
        ));
        return PageResponse.from(result);
    }

    //hàm tìm ảnh chính
    private Map<UUID, String> findPrimaryImages(List<UUID> ids) {
        if (ids.isEmpty()) {
            return Map.of();
        }
        return productImageRepository.findPrimaryImages(ids).stream()
                .collect(Collectors.toMap(ProductPrimaryImage::productId, ProductPrimaryImage::url));
    }

    //hàm tìm giá thấp nhất
    private Map<UUID, BigDecimal> findMinPrices(List<UUID> ids) {
       if (ids.isEmpty()) {
            return Map.of();
       }
       return productVariantRepository.findMinPrices(ids).stream()
                .collect(Collectors.toMap(ProductMinPrice::productId, ProductMinPrice::minPrice));
    }

    //hàm tạo điều kiện lọc
    private static Specification<Product> isActive() {
        return (root, query, cb) -> cb.equal(root.get("status"), STATUS_ACTIVE);
    }

    
}
