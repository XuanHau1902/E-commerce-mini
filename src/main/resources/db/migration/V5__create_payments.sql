CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL,
    method VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    amount NUMERIC(15, 0) NOT NULL,
    transaction_ref VARCHAR(100) NOT NULL,
    gateway_transaction_no VARCHAR(100),
    response_code VARCHAR(20),
    raw_payload JSONB,
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE RESTRICT,
    CONSTRAINT uq_payments_transaction_ref UNIQUE (transaction_ref),
    CONSTRAINT uq_payments_gateway_transaction_no UNIQUE (gateway_transaction_no),
    CONSTRAINT chk_payments_status CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED')),
    CONSTRAINT chk_payments_method CHECK (method IN ('CREDIT_CARD', 'PAYPAL', 'BANK_TRANSFER', 'CASH_ON_DELIVERY', 'VNPAY', 'MOMO', 'ZALO_PAY')),
    CONSTRAINT chk_payments_amount CHECK (amount > 0)
);

CREATE INDEX idx_payments_order_id ON payments (order_id);
CREATE UNIQUE INDEX uq_payments_one_success_per_order ON payments (order_id) WHERE status = 'SUCCESS';  