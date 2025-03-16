#### 6. **Silver Prices Table** (`silver_prices`)
Stores daily silver prices.

```sql
CREATE TABLE silver_prices (
    id SERIAL PRIMARY KEY,
    price_per_gram NUMERIC(10,2) NOT NULL,
    recorded_at TIMESTAMP DEFAULT now()
);
```
✅ **Silver prices** are updated regularly to calculate values in transactions.