CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT,
    brand VARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_products_slug UNIQUE (slug),
    CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE RESTRICT,
    CONSTRAINT chk_products_status CHECK (status IN ('DRAFT', 'ACTIVE', 'ARCHIVED')),
    CONSTRAINT chk_products_name_not_blank CHECK (length(trim(name)) > 0)
);

CREATE INDEX idx_products_category_status ON products (category_id, status);

CREATE TABLE attributes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_attributes_name UNIQUE (name)
);

CREATE TABLE attribute_values (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attribute_id UUID NOT NULL,
    value VARCHAR(100) NOT NULL,
    sort_order INT NOT NULL DEFAULT 0,

    CONSTRAINT fk_attribute_values_attribute FOREIGN KEY (attribute_id) REFERENCES attributes (id) ON DELETE CASCADE,
    CONSTRAINT uq_attribute_values_attr_value UNIQUE (attribute_id, value),
    CONSTRAINT chk_attribute_values_sort_order CHECK (sort_order >= 0),
    CONSTRAINT uq_attribute_values_id_attr UNIQUE (id, attribute_id)
);

CREATE TABLE product_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL,
    sku VARCHAR(100) NOT NULL,
    price numeric(15, 0) NOT NULL,
    compare_at_price numeric(15, 0),
    stock_quantity INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    version INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_variants_product FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
    CONSTRAINT uq_variants_sku UNIQUE (sku),
    CONSTRAINT uq_variants_id_product UNIQUE (id, product_id),
    CONSTRAINT chk_variants_price CHECK (price >= 0),
    CONSTRAINT chk_variants_stock CHECK (stock_quantity >= 0),
    CONSTRAINT chk_variants_compare_price CHECK (compare_at_price IS NULL OR compare_at_price >= price)
);

CREATE INDEX idx_variants_product_id ON product_variants (product_id);

CREATE TABLE variant_attribute_values (
    variant_id UUID NOT NULL,
    attribute_id UUID NOT NULL,
    attribute_value_id UUID NOT NULL,

    CONSTRAINT pk_variant_attribute_values PRIMARY KEY (variant_id, attribute_id),
    CONSTRAINT fk_vav_variant FOREIGN KEY (variant_id) REFERENCES product_variants (id) ON DELETE CASCADE,
    CONSTRAINT fk_vav_attribute_value FOREIGN KEY (attribute_value_id, attribute_id) REFERENCES attribute_values (id, attribute_id) ON DELETE RESTRICT
);

CREATE INDEX idx_vav_attribute_value_id ON variant_attribute_values (attribute_value_id);

CREATE TABLE product_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL,
    variant_id UUID,
    url VARCHAR(255) NOT NULL,
    alt_text VARCHAR(255),
    sort_order INT NOT NULL DEFAULT 0,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_images_product FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
    CONSTRAINT fk_images_variant FOREIGN KEY (variant_id, product_id) REFERENCES product_variants (id, product_id) ON DELETE CASCADE,
    CONSTRAINT chk_images_sort_order CHECK (sort_order >= 0)
);

CREATE INDEX idx_images_product_id ON product_images (product_id);
CREATE INDEX idx_images_variant_id ON product_images (variant_id);
CREATE UNIQUE INDEX uq_images_one_primary_per_product ON product_images (product_id) WHERE is_primary = TRUE;