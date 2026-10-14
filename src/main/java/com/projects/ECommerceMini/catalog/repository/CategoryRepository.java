package com.projects.ECommerceMini.catalog.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.projects.ECommerceMini.catalog.entity.Category;

public interface CategoryRepository extends JpaRepository<Category, UUID>{

    List<Category> findByActiveTrueOrderBySortOrderAsc();
}
