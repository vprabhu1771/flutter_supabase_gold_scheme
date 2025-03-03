Designing a **Gold Scheme** database in **Supabase (PostgreSQL)** requires structuring tables to handle users, transactions, gold holdings, and plan details. Below is a structured approach:

### **Tables and Schema Design**

#### 1. **Users Table** (`users`)
Stores user details.

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT UNIQUE,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT now()
);
```

#### 2. **Gold Plans Table** (`gold_plans`)
Stores different gold investment schemes.

```sql
CREATE TABLE gold_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    min_investment NUMERIC(10,2) NOT NULL,
    duration_months INT NOT NULL,
    interest_rate NUMERIC(5,2) NOT NULL,
    created_at TIMESTAMP DEFAULT now()
);
```

#### 3. **User Gold Holdings** (`gold_holdings`)
Tracks the gold balance of each user.

```sql
CREATE TABLE gold_holdings (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    gold_grams NUMERIC(10,4) DEFAULT 0.0000,
    last_updated TIMESTAMP DEFAULT now()
);
```

#### 4. **Gold Transactions Table** (`gold_transactions`)
Records deposits, withdrawals, and purchases.

```sql
CREATE TABLE gold_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type TEXT CHECK (type IN ('deposit', 'withdrawal', 'purchase', 'sell')),
    amount NUMERIC(10,2) NOT NULL,
    gold_grams NUMERIC(10,4),
    price_per_gram NUMERIC(10,2),
    status TEXT CHECK (status IN ('pending', 'completed', 'failed')),
    created_at TIMESTAMP DEFAULT now()
);
```

#### 5. **User Subscriptions** (`user_subscriptions`)
Tracks which users are subscribed to which gold plans.

```sql
CREATE TABLE user_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    plan_id UUID REFERENCES gold_plans(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status TEXT CHECK (status IN ('active', 'completed', 'cancelled')) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT now()
);
```

#### 6. **Gold Prices Table** (`gold_prices`)
Stores daily gold prices.

```sql
CREATE TABLE gold_prices (
    id SERIAL PRIMARY KEY,
    price_per_gram NUMERIC(10,2) NOT NULL,
    recorded_at TIMESTAMP DEFAULT now()
);
```

### **Relationships and Flow**
1. **Users** can hold gold (`gold_holdings`) and subscribe to investment plans (`user_subscriptions`).
2. **Gold transactions** track purchases, sales, and withdrawals.
3. **Gold prices** are updated regularly to calculate values in transactions.
4. **Gold plans** define investment schemes with interest.

Would you like additional features like referral programs, automatic payments, or gold redemption options?
