package com.projects.ECommerceMini.catalog.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record ProductSummaryResponse(

    UUID id,
    String name,
    String slug,
    String brand,
    BigDecimal minPrice,
    String primaryImageUrl) {

}
