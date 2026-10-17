package com.projects.ECommerceMini.catalog.repository;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.projects.ECommerceMini.catalog.dto.ProductMinPrice;
import com.projects.ECommerceMini.catalog.entity.ProductVariant;

public interface ProductVariantRepository extends JpaRepository<ProductVariant, UUID>{

    @Query("""
            select new com.projects.ECommerceMini.catalog.dto.ProductMinPrice(v.product.id, min(v.price))
            from ProductVariant v
            where v.product.id in :productIds
                and v.active = true
            group by v.product.id
            """)
    List<ProductMinPrice> findMinPrices(@Param("productIds") Collection<UUID> productIds);
}
