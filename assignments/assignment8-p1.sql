-- 
SELECT *
    FROM Students
    WHERE (name = 'Robert');DROP TABLE Students;--'
    AND year = 2026);

-- The database will interpret this as a command to select 'Robert' from Students
-- then start a new command that deletes the 'Students' table
-- The '--' make it is othe ending quotating that would normally throw a error
-- is interpreted as a comment instead.