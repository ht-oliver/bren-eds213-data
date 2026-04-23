----- Part 1 -----
SELECT Site_name, MAX(Area) FROM Site;

-- The MAX() function, or any similar mathematical function, asks SQL to collapse data from all rows into a single value
-- I'm basically asking for the Max of all rows from Site_name, then it's specifying the column I'm interested in
-- It can calculate the max Area from Site and isolating it, but it then doesn't know which Site_name to pair it with

----- Part 2 -----
SELECT Site_name, Area FROM Site ORDER BY Area DESC -- Arrange from largest to smallest
LIMIT 1;


----- Part 3 -----
SELECT Site_name, Area FROM Site WHERE Area = (SELECT Max(Area) FROM Site);