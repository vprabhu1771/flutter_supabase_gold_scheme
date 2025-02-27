```sql
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    subscription_id INT NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    payment_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    payment_mode VARCHAR(20) CHECK (payment_mode IN ('Cash', 'UPI', 'Card', 'Bank Transfer')),
    FOREIGN KEY (subscription_id) REFERENCES customer_subscriptions(id) ON DELETE CASCADE
);
```