-- Assignment 3, in toy database
----- Problem 1 -----
-- Create Temporary Table
CREATE TEMP TABLE mytable (
    value REAL
);
-- Populate table with values
INSERT INTO mytable (value)
VALUES (1), (2), (NULL), (4), (5), (6), (7), (8), (NULL), (10);

-- Calculate average
SELECT AVG(value) FROM mytable;

-- Answers
-- If the NULL values are completely ignored, the value should be the sum of the numbers divided by 8 (between 5 and 6)
-- If the AVG() function treated them like zeroes, the result would have been 43/10 = 4.3
-- The actual return was 5.375 like I predicted

SELECT SUM(value)/COUNT(*) FROM mytable;
SELECT SUM(value)/COUNT(value) FROM mytable;

-- The first line (using *) returns 4.3, the second returns 5.375. 
-- The first line is incorrect because it is computing the average based on row #, not values
-- The second line is correct because it ignores NULL values, as it should






