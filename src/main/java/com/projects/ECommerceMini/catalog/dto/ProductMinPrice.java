package com.projects.ECommerceMini.catalog.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record ProductMinPrice(UUID productId, BigDecimal minPrice) {

}
