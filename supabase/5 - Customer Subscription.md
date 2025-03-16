```sql
CREATE TABLE customer_subscriptions (
    id SERIAL PRIMARY KEY,
    customer_id uuid NOT NULL,
    scheme_id INT NOT NULL,
    start_date DATE NOT NULL,
    status VARCHAR(20) CHECK (status IN ('Active', 'Completed', 'Cancelled')) DEFAULT 'Active',
    total_paid NUMERIC(10,2) DEFAULT 0.00, -- Tracks total payments
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES auth.users(id) ON DELETE SET NULL,
    FOREIGN KEY (scheme_id) REFERENCES gold_schemes(id) ON DELETE SET NULL
);
```

```sql
ALTER TABLE customer_subscriptions
ADD CONSTRAINT fk_customer FOREIGN KEY (customer_id)
REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE customer_subscriptions
ADD CONSTRAINT fk_scheme FOREIGN KEY (scheme_id)
REFERENCES gold_schemes(id) ON DELETE  SET NULL;
```