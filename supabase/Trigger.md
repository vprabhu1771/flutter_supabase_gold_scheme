You need a **PostgreSQL trigger function** to automatically update the **gold_holdings** table whenever a new **payment** is inserted. Below is the **trigger function** and its corresponding **trigger**.

---

### **Trigger Function: Auto-Update Gold Holdings**
```sql
CREATE OR REPLACE FUNCTION update_gold_holdings()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the total gold holdings of the user
    UPDATE gold_holdings
    SET total_gold_grams = total_gold_grams + NEW.gold_grams,
        last_updated = CURRENT_TIMESTAMP
    WHERE user_id = (
        SELECT customer_id FROM customer_subscriptions WHERE id = NEW.subscription_id
    );

    -- If no record exists, insert a new row for the user
    IF NOT FOUND THEN
        INSERT INTO gold_holdings (user_id, total_gold_grams, last_updated)
        VALUES (
            (SELECT customer_id FROM customer_subscriptions WHERE id = NEW.subscription_id),
            NEW.gold_grams,
            CURRENT_TIMESTAMP
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

---

### **Trigger: Call Function on Payment Insertion**
```sql
CREATE TRIGGER trigger_update_gold_holdings
AFTER INSERT ON payments
FOR EACH ROW
EXECUTE FUNCTION update_gold_holdings();
```

---

### **How It Works**
1. Whenever a **new payment** is inserted:
    - The **gold grams** are calculated from **amount / gold_price**.
    - The function **updates** the **gold_holdings** table for that user.
    - If the user has no previous record in **gold_holdings**, a new row is **inserted**.

---

### **Example Scenario**
#### **1. User Makes a Payment**
```sql
INSERT INTO payments (subscription_id, amount, payment_mode, gold_price)
VALUES (1, 5000, 'UPI', 5500);
```
- `gold_grams = 5000 / 5500 = 0.9091 gm`
- **gold_holdings** will be updated automatically!

#### **2. Check User's Gold Holdings**
```sql
SELECT * FROM gold_holdings WHERE user_id = 'USER_UUID';
```

---

### **Benefits**
✅ **Automatic gold balance update**  
✅ **Handles first-time users (inserts if not exists)**  
✅ **Ensures consistency in gold holdings**

Let me know if you need modifications! 🚀