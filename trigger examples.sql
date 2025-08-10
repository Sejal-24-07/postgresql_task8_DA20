--Add Bonus Marks to Students Who Score High
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    marks INT
);

CREATE OR REPLACE FUNCTION bonus_marks()
RETURNS TRIGGER AS $$
BEGIN
   
    IF NEW.marks > 90 THEN
        NEW.marks = NEW.marks + 5;
        IF NEW.marks > 100 THEN
            NEW.marks = 100;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_bonus_marks
BEFORE INSERT OR UPDATE ON students
FOR EACH ROW
EXECUTE FUNCTION bonus_marks();


--Prevent Negative Balance in Bank Account

CREATE TABLE bank_accounts (
    account_id SERIAL PRIMARY KEY,
    holder_name VARCHAR(50),
    balance NUMERIC(10,2)
);

CREATE OR REPLACE FUNCTION check_balance()
RETURNS TRIGGER AS $$
BEGIN
   
    IF NEW.balance < 0 THEN
        RAISE EXCEPTION 'Balance cannot be negative';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_balance
BEFORE UPDATE ON bank_accounts
FOR EACH ROW
EXECUTE FUNCTION check_balance();


--Save Deleted Product Details in Log

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    price NUMERIC(10,2)
);

CREATE TABLE product_log (
    log_id SERIAL PRIMARY KEY,
    product_id INT,
    name VARCHAR(50),
    price NUMERIC(10,2),
    deleted_at TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_product_deletion()
RETURNS TRIGGER AS $$
BEGIN
    
    INSERT INTO product_log(product_id, name, price, deleted_at)
    VALUES (OLD.product_id, OLD.name, OLD.price, NOW());
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_product_deletion
AFTER DELETE ON products
FOR EACH ROW
EXECUTE FUNCTION log_product_deletion();


--Auto-Set Signup Date for New Customer


CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    signup_date DATE
);

CREATE OR REPLACE FUNCTION set_signup_date()
RETURNS TRIGGER AS $$
BEGIN
   
    IF NEW.signup_date IS NULL THEN
        NEW.signup_date = CURRENT_DATE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_signup_date
BEFORE INSERT ON customers
FOR EACH ROW
EXECUTE FUNCTION set_signup_date();