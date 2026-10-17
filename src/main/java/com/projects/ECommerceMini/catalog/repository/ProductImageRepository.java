package com.projects.ECommerceMini.catalog.repository;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.projects.ECommerceMini.catalog.dto.ProductPrimaryImage;
import com.projects.ECommerceMini.catalog.entity.ProductImage;

public interface ProductImageRepository extends JpaRepository<ProductImage, UUID>{

    @Query("""
            select new com.projects.ECommerceMini.catalog.dto.ProductPrimaryImage(i.product.id, i.url)
            from ProductImage i
            where i.product.id in :productIds
                and i.primary = true
            """)
    
    List<ProductPrimaryImage> findPrimaryImages(@Param("productIds") Collection<UUID> productIds);
}
