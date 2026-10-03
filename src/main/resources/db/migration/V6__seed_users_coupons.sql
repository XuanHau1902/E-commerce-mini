CREATE EXTENSION IF NOT EXISTS pgcrypto;

--Mật khẩu dev:Admin@123 và User@123 (hash bằng bcrypt, Spring Security đọc được)
INSERT INTO users (email, password_hash, full_name, phone, role, status) VALUES
('admin@example.com', crypt('Admin@123', gen_salt('bf')), 'Admin User', '0123456789', 'ADMIN', 'ACTIVE'),
('user@example.com', crypt('User@123', gen_salt('bf')), 'Regular User', '0987654321', 'USER', 'ACTIVE');

INSERT INTO coupons (code, discount_type, discount_value, min_order_amount, max_discount_amount, usage_limit, used_count, starts_at, ends_at, is_active) VALUES
--Còn hiệu lực: giảm 10%, tối đa 50.000đ, đơn từ 100.000đ, 100 lượt
('WELCOME10', 'PERCENT', 10, 100000, 50000, 100, 0, NOW() - INTERVAL '1 day', NOW() + INTERVAL '365 days', TRUE),

--Còn hiệu lực: giảm cố định 50000đ cho đơn từ 300.000đ không giới hạn lượt sử dụng
('GIAM50K', 'FIXED', 50000, 300000, NULL, NULL, 0, NOW() - INTERVAL '1 day', NOW() + INTERVAL '365 days', TRUE),

--Hết hạn (để test báo lỗi mã hết hạn)
('EXPIRED20', 'PERCENT', 20, 0, NULL, NULL, 0, '2025-01-01 00:00:00', '2025-12-31 23:59:59', TRUE),

--Hết lượt sử dụng (để test báo lỗi mã hết lượt used_count = usage_limit)
('SOLDOUT30K', 'FIXED', 30000, 0, NULL, 10, 10, NOW() - INTERVAL '1 day', NOW() + INTERVAL '365 days', TRUE);