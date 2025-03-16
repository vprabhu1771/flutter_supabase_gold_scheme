```sql
CREATE TABLE gold_holdings (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    gold_grams NUMERIC(10,4) DEFAULT 0.0000,
    last_updated TIMESTAMP DEFAULT now()
);

```