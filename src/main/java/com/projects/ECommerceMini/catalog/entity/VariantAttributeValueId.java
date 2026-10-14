package com.projects.ECommerceMini.catalog.entity;

import java.io.Serializable;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Embeddable 
@Getter 
@Setter 
@NoArgsConstructor 
@AllArgsConstructor 
@EqualsAndHashCode 
public class VariantAttributeValueId implements Serializable{

    @Column(name = "variant_id")
    private UUID variantId;

    @Column(name = "attribute_id")
    private UUID attributeId;
}
