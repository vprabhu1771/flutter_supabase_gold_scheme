#### 6. **Gold Prices Table** (`gold_prices`)
Stores daily gold prices.

```sql
CREATE TABLE gold_prices (
    id SERIAL PRIMARY KEY,
    price_per_gram NUMERIC(10,2) NOT NULL,
    recorded_at TIMESTAMP DEFAULT now()
);
```
✅ **Gold prices** are updated regularly to calculate values in transactions.