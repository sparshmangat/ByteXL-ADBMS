-- Drop table if exists (for re-runs)
DROP TABLE IF EXISTS FeePayments;

-- Create table with constraints
CREATE TABLE FeePayments (
    payment_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    amount DECIMAL(10,2) CHECK (amount > 0),
    payment_date DATE NOT NULL
);

----------------------------------------
-- Part A: Insert Multiple Payments
----------------------------------------
START TRANSACTION;

INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
VALUES (1, 'Ashish', 5000.00, '2024-06-01');

INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
VALUES (2, 'Smaran', 4500.00, '2024-06-02');

INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
VALUES (3, 'Vaibhav', 5500.00, '2024-06-03');

COMMIT;

-- Verify Part A
SELECT * FROM FeePayments;

----------------------------------------
-- Part B: ROLLBACK on Failure
----------------------------------------
START TRANSACTION;

-- Valid insert
INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
VALUES (4, 'Kiran', 6000.00, '2024-06-04');

-- Invalid insert: duplicate ID and negative amount
INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
VALUES (1, 'Ashish', -2000.00, '2024-06-05');

-- Rollback entire transaction
ROLLBACK;

-- Verify rollback (only first 3 records remain)
SELECT * FROM FeePayments;

----------------------------------------
-- Part C: Partial Failure Example
----------------------------------------
START TRANSACTION;

-- Valid insert
INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
VALUES (5, 'Ravi', 4000.00, '2024-06-06');

-- Invalid insert: NULL name not allowed
INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
VALUES (6, NULL, 3000.00, '2024-06-07');

-- Rollback because of failure
ROLLBACK;

-- Verify rollback
SELECT * FROM FeePayments;

----------------------------------------
-- Part D: Verify ACID Properties
----------------------------------------

-- Atomicity + Consistency
START TRANSACTION;
INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
VALUES (7, 'Megha', 7000.00, '2024-06-08');

-- Invalid insert (duplicate ID)
INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
VALUES (1, 'Duplicate', 8000.00, '2024-06-09');
ROLLBACK;

-- Table unchanged
SELECT * FROM FeePayments;

-- Durability
START TRANSACTION;
INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
VALUES (8, 'Pooja', 7500.00, '2024-06-10');
COMMIT;

-- Verify durable insert
SELECT * FROM FeePayments;

-- Isolation (manual check if DB supports sessions):
-- Session 1: START TRANSACTION, insert without COMMIT
-- Session 2: SELECT * FROM FeePayments (should not see uncommitted data).
