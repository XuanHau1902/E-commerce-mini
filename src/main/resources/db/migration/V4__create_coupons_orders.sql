CREATE TABLE coupons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL,
    discount_type VARCHAR(10) NOT NULL,
    discount_value NUMERIC(15, 0) NOT NULL,
    min_order_amount NUMERIC(15, 0) DEFAULT 0,
    max_discount_amount NUMERIC(15, 0),
    usage_limit INT,
    used_count INT NOT NULL DEFAULT 0,
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_coupons_code UNIQUE (code),
    CONSTRAINT chk_coupons_type CHECK (discount_type IN ('PERCENT', 'FIXED')),
    CONSTRAINT chk_coupons_value_positive CHECK (discount_value > 0),
    CONSTRAINT chk_coupons_percent_max CHECK (discount_type <> 'PERCENT' OR discount_value <= 100),
    CONSTRAINT chk_coupons_min_order CHECK (min_order_amount >= 0),
    CONSTRAINT chk_coupons_max_discount CHECK (max_discount_amount IS NULL OR max_discount_amount > 0),
    CONSTRAINT chk_coupons_usage_limit CHECK (usage_limit IS NULL OR usage_limit > 0),
    CONSTRAINT chk_coupons_used_count CHECK (used_count >= 0 AND (usage_limit IS NULL OR used_count <= usage_limit)),
    CONSTRAINT chk_coupons_period CHECK (starts_at < ends_at)
);

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_code VARCHAR(30) NOT NULL,
    user_id UUID NOT NULL,
    coupon_id UUID,
    coupon_code VARCHAR(50),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    subtotal NUMERIC(15, 0) NOT NULL,
    discount_amount NUMERIC(15, 0) NOT NULL DEFAULT 0,
    shipping_fee NUMERIC(15, 0) NOT NULL DEFAULT 0,
    total_amount NUMERIC(15, 0) NOT NULL,
    recipient_name VARCHAR(100) NOT NULL,
    recipient_phone VARCHAR(20) NOT NULL,
    shipping_address TEXT NOT NULL,
    note VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_orders_order UNIQUE (order_code),
    CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT fk_orders_coupon FOREIGN KEY (coupon_id) REFERENCES coupons (id) ON DELETE SET NULL,
    CONSTRAINT chk_orders_status CHECK (status IN ('PENDING', 'PAID', 'SHIPPED', 'DELIVERED', 'CANCELLED')),
    CONSTRAINT chk_orders_amounts CHECK (subtotal >= 0 AND discount_amount >= 0 AND shipping_fee >= 0 AND total_amount >= 0),
    CONSTRAINT chk_orders_total CHECK (total_amount = subtotal - discount_amount + shipping_fee),
    CONSTRAINT chk_orders_discount_le_subtotal CHECK (discount_amount <= subtotal)
);

CREATE INDEX idx_orders_user_created_at ON orders (user_id, created_at DESC);
CREATE INDEX idx_orders_coupon_id ON orders (coupon_id);
CREATE INDEX idx_orders_status ON orders (status);

CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL,
    variant_id UUID,
    product_name VARCHAR(255) NOT NULL,
    variant_sku VARCHAR(64) NOT NULL,
    variant_attributes VARCHAR(255),
    unit_price NUMERIC(15, 0) NOT NULL,
    quantity INT NOT NULL,
    line_total NUMERIC(15, 0) NOT NULL,

    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
    CONSTRAINT fk_order_items_variant FOREIGN KEY (variant_id) REFERENCES product_variants (id) ON DELETE SET NULL,
    CONSTRAINT chk_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_items_unit_price CHECK (unit_price >= 0),
    CONSTRAINT chk_order_items_line_total CHECK (line_total = unit_price * quantity)
);

CREATE INDEX idx_order_items_order_id ON order_items (order_id);
CREATE INDEX idx_order_items_variant_id ON order_items (variant_id);