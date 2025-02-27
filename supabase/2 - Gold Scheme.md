```sql
CREATE TABLE gold_schemes (
    id SERIAL PRIMARY KEY,
    scheme_name VARCHAR(255) NOT NULL,
    duration_months INT NOT NULL,  -- e.g., 12 months
    total_amount NUMERIC(10,2) NOT NULL,  -- Total amount to be paid
    min_installment NUMERIC(10,2) NOT NULL, -- Minimum installment amount
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
```