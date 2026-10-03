-- ========== 1. Danh muc (3 cap) ==========
INSERT INTO categories (name, slug, sort_order) VALUES
    ('Thoi trang nam', 'thoi-trang-nam', 1),
    ('Thoi trang nu', 'thoi-trang-nu', 2),
    ('Phu kien', 'phu-kien', 3);

INSERT INTO categories (parent_id, name, slug, sort_order)
SELECT p.id, v.name, v.slug, v.sort_order
FROM (VALUES
    ('thoi-trang-nam', 'Ao nam', 'ao-nam', 1),
    ('thoi-trang-nam', 'Quan nam', 'quan-nam', 2),
    ('thoi-trang-nam', 'Giay nam', 'giay-nam', 3),
    ('thoi-trang-nu', 'Ao nu', 'ao-nu', 1),
    ('thoi-trang-nu', 'Quan nu', 'quan-nu', 2),
    ('thoi-trang-nu', 'Giay nu', 'giay-nu', 3),
    ('phu-kien', 'Tui xach', 'tui-xach', 1),
    ('phu-kien', 'Dong ho', 'dong-ho', 2),
    ('phu-kien', 'Kinh mat', 'kinh-mat', 3)
) AS v(parent_slug, name, slug, sort_order)
JOIN categories p ON p.slug = v.parent_slug;

INSERT INTO categories (parent_id, name, slug, sort_order)
SELECT p.id, v.name, v.slug, v.sort_order
FROM (VALUES
    ('ao-nam', 'Ao thun', 'ao-thun', 1),
    ('ao-nam', 'Ao so mi', 'ao-so-mi', 2),
    ('quan-nam', 'Quan jeans', 'quan-jeans', 1),
    ('quan-nam', 'Quan kaki', 'quan-kaki', 2),
    ('giay-nam', 'Giay the thao', 'giay-the-thao', 1),
    ('giay-nam', 'Giay da', 'giay-da', 2),
    ('ao-nu', 'Ao thun nu', 'ao-thun-nu', 1),
    ('ao-nu', 'Ao so mi nu', 'ao-so-mi-nu', 2),
    ('quan-nu', 'Quan jeans nu', 'quan-jeans-nu', 1),
    ('quan-nu', 'Quan kaki nu', 'quan-kaki-nu', 2),
    ('giay-nu', 'Giay the thao nu', 'giay-the-thao-nu', 1),
    ('giay-nu', 'Giay da nu', 'giay-da-nu', 2)
) AS v(parent_slug, name, slug, sort_order)
JOIN categories p ON p.slug = v.parent_slug;

-- ========== 2. Thuoc tinh ==========
INSERT INTO attributes (name) VALUES ('size'), ('color');

INSERT INTO attribute_values (attribute_id, value, sort_order)
SELECT a.id, v.value, v.sort_order
FROM (VALUES
    ('size', 'S', 0),
    ('size', 'M', 1),
    ('size', 'L', 2),
    ('size', 'XL', 3),
    ('color', 'Red', 0),
    ('color', 'Blue', 1),
    ('color', 'Green', 2),
    ('color', 'Black', 3)
) AS v(attribute_name, value, sort_order)
JOIN attributes a ON a.name = v.attribute_name;

-- ========== 3. San pham (70 san pham, chia deu vao cac danh muc la) ==========
WITH leaf AS (
    SELECT c.id, c.name, c.slug,
        ROW_NUMBER() OVER (ORDER BY c.slug) -1 AS idx
    FROM categories c
    WHERE NOT EXISTS (SELECT 1 FROM categories ch WHERE ch.parent_id = c.id)
)
INSERT INTO products (category_id, name, slug, description, brand, status)
SELECT l.id,
       l.name || ' ' || n,
       l.slug || '-' || n,
       'Mô tả cho sản phẩm ' || l.name || ' so ' || n,
       (ARRAY['Aurora', 'Nike', 'Adidas', 'Puma'])[1 + (n % 4)],
       CASE WHEN n % 25 = 0 THEN 'DRAFT' ELSE 'ACTIVE' END
FROM generate_series(1, 70) AS n
JOIN leaf l ON l.idx = (n - 1) % (SELECT COUNT(*) FROM leaf);

-- ========== 4. Variant: 2-6 variant moi san pham ==========
-- SKU co dang SKU-<so thu tu>-<size>-<3 chu dau cua mau>, vi du SKU-001-S-BLA
INSERT INTO product_variants (product_id, sku, price, compare_at_price, stock_quantity)
SELECT p.id,
       'SKU-' || LPAD(p.pn::text, 3, '0') || '-' || s.value || '-' || UPPER(LEFT(c.value, 3)),
       base.price + CASE WHEN s.value = 'XL' THEN 10000 ELSE 0 END,
       CASE WHEN p.pn % 5 = 0 THEN round(base.price *1.2 / 1000) *1000 END,
       (p.pn * 7 + s.sort_order * 3 + c.sort_order * 5) % 30 + 5
FROM (SELECT id, row_number() OVER (ORDER BY slug) AS pn FROM products) p
CROSS JOIN LATERAL (SELECT ((100 + (p.pn * 37) % 400) * 1000):: numeric AS price) base
JOIN attribute_values s ON s.attribute_id = (SELECT id FROM attributes WHERE name = 'size')
                       AND s.sort_order < 2 + p.pn % 2
JOIN attribute_values c ON c.attribute_id = (SELECT id FROM attributes WHERE name = 'color')
                       AND c.sort_order < 1 + (p.pn / 2) % 2;


-- Moi variant co dung 2 dong thuoc tinh (Size va Color), suy ra tu SKU
INSERT INTO variant_attribute_values (variant_id, attribute_id, attribute_value_id)
SELECT pv.id, av.attribute_id, av.id
FROM product_variants pv
JOIN attribute_values av
    ON (av.attribute_id = (SELECT id FROM attributes WHERE name = 'size') AND av.value = split_part(pv.sku, '-', 3));

INSERT INTO variant_attribute_values (variant_id, attribute_id, attribute_value_id)
SELECT pv.id, av.attribute_id, av.id
FROM product_variants pv
JOIN attribute_values av
    ON (av.attribute_id = (SELECT id FROM attributes WHERE name = 'color') AND UPPER(LEFT(av.value, 3)) = split_part(pv.sku, '-', 4));

-- ========== 5. Anh: 1-3 anh moi san pham, anh dau tien la anh chinh ==========
INSERT INTO product_images (product_id, url, alt_text, sort_order, is_primary)
SELECT p.id,
       'https://picsum.photos/seed/' || p.slug || '-' || i || '/600/600',
       p.name || ' - anh ' || i,
       i - 1,
       (i = 1)
FROM (SELECT id, name, slug, row_number() OVER (ORDER BY slug) AS pn FROM products) p
CROSS JOIN LATERAL generate_series(1,1 + p.pn % 3) AS i;

-- ========== 6. Du lieu dac biet cho cac bai test sau ==========
UPDATE product_variants SET stock_quantity = 1 WHERE sku = 'SKU-001-S-RED'; -- còn đúng 1 cái
UPDATE product_variants SET stock_quantity = 0 WHERE sku = 'SKU-002-M-BLU'; -- hết hàng