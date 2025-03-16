gold_holdings (Customer Gold Balance)

```sql
CREATE TABLE gold_holdings (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    gold_grams NUMERIC(10,4) DEFAULT 0.0000,
    last_updated TIMESTAMP DEFAULT now()
);
```

✅ Stores total gold accumulated by a user
✅ Updates after each payment