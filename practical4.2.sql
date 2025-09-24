-- Drop table if exists
DROP TABLE IF EXISTS StudentEnrollments;

-- Create table with constraints
CREATE TABLE StudentEnrollments (
    enrollment_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    course_id VARCHAR(10) NOT NULL,
    enrollment_date DATE NOT NULL,
    CONSTRAINT unique_enrollment UNIQUE (student_name, course_id) -- Prevent duplicate enrollment
);

----------------------------------------
-- Part A: Prevent Duplicate Enrollments
----------------------------------------
-- Insert initial data
INSERT INTO StudentEnrollments (enrollment_id, student_name, course_id, enrollment_date)
VALUES 
(1, 'Ashish', 'CSE101', '2024-07-01'),
(2, 'Smaran', 'CSE102', '2024-07-01'),
(3, 'Vaibhav', 'CSE101', '2024-07-01');

-- Transaction Example (User A)
START TRANSACTION;
INSERT INTO StudentEnrollments (enrollment_id, student_name, course_id, enrollment_date)
VALUES (4, 'Ashish', 'CSE101', '2024-07-02'); -- This will FAIL (duplicate student + course)
COMMIT;

-- ✅ Output: Only the first Ashish→CSE101 stays. Duplicate prevented.

----------------------------------------
-- Part B: SELECT FOR UPDATE (Row Locking)
----------------------------------------
-- User A:
START TRANSACTION;
SELECT * FROM StudentEnrollments
WHERE student_name = 'Ashish' AND course_id = 'CSE101'
FOR UPDATE;
-- Row is now locked. Keep this transaction open.

-- User B (in another session, at the same time):
START TRANSACTION;
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-05'
WHERE student_name = 'Ashish' AND course_id = 'CSE101';
-- ❌ This will be BLOCKED until User A COMMITs/ROLLBACKs.

-- User A:
COMMIT; -- Unlocks the row

-- User B:
-- Now User B’s update will execute.

----------------------------------------
-- Part C: Locking Preserves Consistency
----------------------------------------
-- Reset Ashish's enrollment date
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-01'
WHERE student_name = 'Ashish' AND course_id = 'CSE101';

-- User A (Session 1):
START TRANSACTION;
SELECT * FROM StudentEnrollments
WHERE student_name = 'Ashish' AND course_id = 'CSE101'
FOR UPDATE;
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-10'
WHERE student_name = 'Ashish' AND course_id = 'CSE101';
-- Don’t commit yet.

-- User B (Session 2 at the same time):
START TRANSACTION;
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-15'
WHERE student_name = 'Ashish' AND course_id = 'CSE101';
-- ❌ This will be BLOCKED until User A finishes.

-- User A:
COMMIT;

-- User B:
-- Update now applies, final date = 2024-07-15

-- ✅ Output: No race condition. Last committed transaction wins, consistency preserved.

----------------------------------------
-- Verify Final State
----------------------------------------
SELECT * FROM StudentEnrollments;
