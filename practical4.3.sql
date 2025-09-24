-- Drop and recreate table
DROP TABLE IF EXISTS StudentEnrollments;

CREATE TABLE StudentEnrollments (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    course_id VARCHAR(10) NOT NULL,
    enrollment_date DATE NOT NULL
);

-- Insert initial records
INSERT INTO StudentEnrollments (student_id, student_name, course_id, enrollment_date)
VALUES 
(1, 'Ashish', 'CSE101', '2024-06-01'),
(2, 'Smaran', 'CSE102', '2024-06-01'),
(3, 'Vaibhav', 'CSE103', '2024-06-01');

----------------------------------------------------------
-- Part A: Simulating a Deadlock
----------------------------------------------------------
-- Open TWO sessions

-- Session 1:
START TRANSACTION;
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-01'
WHERE student_id = 1;

-- Session 2:
START TRANSACTION;
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-02'
WHERE student_id = 2;

-- Now Session 1 tries to update row 2:
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-03'
WHERE student_id = 2;

-- And Session 2 tries to update row 1:
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-04'
WHERE student_id = 1;

-- ❌ Deadlock occurs: DB detects it and rolls back one transaction automatically.


----------------------------------------------------------
-- Part B: MVCC – Non-blocking Concurrent Read/Write
----------------------------------------------------------
-- Session 1 (User A):
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT * FROM StudentEnrollments
WHERE student_id = 1;
-- User A sees enrollment_date = 2024-06-01
-- Keep transaction open.

-- Session 2 (User B):
START TRANSACTION;
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-10'
WHERE student_id = 1;
COMMIT;

-- Back to Session 1:
SELECT * FROM StudentEnrollments
WHERE student_id = 1;
-- ✅ User A STILL sees old value (2024-06-01) due to MVCC snapshot
-- After Session 1 COMMIT, if they query again, they’ll see the new value (2024-07-10).


----------------------------------------------------------
-- Part C: Comparing Behavior With vs. Without MVCC
----------------------------------------------------------
-- Reset data
UPDATE StudentEnrollments
SET enrollment_date = '2024-06-01'
WHERE student_id = 1;

-- Scenario 1: Locking (without MVCC, use SELECT FOR UPDATE)
-- Session 1:
START TRANSACTION;
SELECT * FROM StudentEnrollments
WHERE student_id = 1
FOR UPDATE;
-- Row is locked

-- Session 2:
START TRANSACTION;
SELECT * FROM StudentEnrollments
WHERE student_id = 1;
-- ❌ This query is BLOCKED until Session 1 COMMITs/ROLLBACKs

-- Scenario 2: MVCC (normal SELECT in REPEATABLE READ or SNAPSHOT)
-- Session 1:
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT * FROM StudentEnrollments
WHERE student_id = 1;
-- Sees 2024-06-01

-- Session 2:
START TRANSACTION;
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-20'
WHERE student_id = 1;
COMMIT;

-- Back to Session 1:
SELECT * FROM StudentEnrollments
WHERE student_id = 1;
-- ✅ Still sees 2024-06-01 until commit (no blocking, consistent snapshot).
