payments (Track Individual Installments)

```sql
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    subscription_id INT NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    payment_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    payment_mode VARCHAR(20) CHECK (payment_mode IN ('Cash', 'UPI', 'Card', 'Bank Transfer')),
    gold_price NUMERIC(10,2) NOT NULL, -- Store gold price at the time of payment
    gold_grams NUMERIC(10,4) GENERATED ALWAYS AS (amount / gold_price) STORED, -- Auto calculate gold received
    FOREIGN KEY (subscription_id) REFERENCES customer_subscriptions(id) ON DELETE CASCADE
);
```

✅ Tracks each installment with the gold price at that time
✅ Auto-calculates the gold grams based on the payment amount