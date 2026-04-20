# TO ENTER DATABASE
-- navigate to database folder in repo
duckdb database.duckdb

# To see the DuckDB- specific commands, do this
.help
.help mode

# Use .exit to exit, or Ctrl-D

# In SQL, comments are delimited with --

-- .table -- lists tables
-- .schema -- lists whole schema
.schema

-- Getting help on SQL: look at the "railroad" diagrams in SQLite 

-- Our first query
-- The * means all columns; all rows are implied because we didn't specify a WHERE clause
SELECT * FROM Species;

-- A couple of 'gotchas'
-- 1. Don't forget the closing semicolon, DuckDB will wait for it forever
-- 2. Watch for missing closing quotes


-- To see just a few ros:
SELECT * FROM Species LIMIT 5;
-- Can also "page" through the rows
SELECT * FROM Species LIMIT 5 OFFSET 5;

-- Of course, we can slect which columns we want
SELECT  Code, Scientific_name FROM Species;

-- other handy query to explore data:
SELECT  Spcecies FROM Bird_nests;
SELECT DISTINCT Species FROM Bird_nests;

-- Can also get distinct pairs or tuples that occur
SELECT DISTINCT Scientific_name FROM Bird_nests, Species

-- Order, sort by, arrange
-- Can ask that the reuslts be ordered
SELECT Scientific_name FROM Species;
SELECT Scientfic_name FROM Species ORDER BY Scientific_name;

SELECT * FROM Species;

-- The default ordering (which is undefined) can be subtle
SELECT DISTINCT Species FROM Bird_nests;
SELECT DISTINCT Species FROM Bird_nests LIMIT 3;

-- Let's try again, but ask that the results be ordered
SELECT DISTINCT Species FROM Bird_nests ORDER BY Species;
SELECT DISTINCT Species FROM Bird_nests ORDER BY Species LIMIT 3;

-- In class challenge:
-- Select the distinct location from the SIte table; are they in order? If not, order them
SELECT DISTINCT Location FROM Site ORDER BY Location;


-- FILTERING
-- looks just like in R or Python
SELECT * FROM Site WHERE Area < 200;
SELECT * FROM Site WHERE Area < 200 AND Latitude > 60;
-- older-style operators
SELECT * FROM Site WHERE Code != 'iglo';
SELECT * FROM Site WHERE Code <> 'iglo'; -- older style
-- expression: the usual operators, plus lots of functions like regex

## EXPRESSIONS
SELECT Site_name, Area*2.47 FROM Site;
-- Give a name to that column you just made
SELECT Site_name, Area*2.47 AS Area_acres FROM Site;

-- string concatenation
-- old-style operator: ||
SELECT Site_name || ', ' || Location AS Full_name FROM Site;
-- there are probably other operators, 

-- BTW, you have another fancy calculator!
SELECT 2+2; 

-- adding "AS ..." needs to come right after the thing you want to name
SELECT Site_name AS some_other_name FROM  Site LIMIT 1;

## AGGREGATION & GROUPING

--How many rows are in this table?
SELECT COUNT(*) FROM Bird_nests;
SELECT COUNT(DISTINCT Location) FROM Site; -- number of distinct locations
SELECT COUNT(Location) FROM Site: -- number of non-NULL locations
-- reminder
SELECT DISTINCT Location FROM Site;

-- The usual aggregation functions
SELECT AVG(Area) FROM Site;
SELECT MIN(Area) FROM Site;

-- This won't work
SELECT Location, AVG(Area) FROM Site;

-- enter grouping
SELECT Location, AVG(Area) FROM Site GROUP BY Location;
-- similar for counting
SELECT Locaiton, COUNT(*) FROM Site. GROUP BY Location;


-- We can site have WHERE clauses!
SELECT Location, COUNT(*)
    FROM Site
    WHERE Location LIKE '%Canada' -- old-style pattern-matching, NOT full regex, just wildcard (%)
    GROUP BY Location;

-- the order of the clauses reflect the order of the processing
-- What if you want to dom some filtering on your groups, after you've done grouping?
SELECT Location, MAX(Area) AS Max_area
    FROM Site
    WHERE Location LIKE '%Canada'
    GROUP BY Location
    HAVING Max_area > 200 -- Having is "WHERE" After grouping
    ORDER BY Max_area DESC;


## RELATIONAL ALGEBRAL
-- Everything is a table
-- Every query, every statement actually, returns a table
SELECT COUNT(*) FROM Site;
-- you can save tables, you can nest queries
SELECT COUNT(*) FROM (SELECT COUNT (*) FROM SITE);

-- you can nest queries

## NULL processing
-- NLL is infectious
-- In a table, NULL means no data, the absenece of a value
-- In an expression, NULL means unknown
SELECT COUNT(*) FROM Bird_nests WHERE ageMethod = 'float';
SELECT COUNT(*) FROM Bird_nests WHERE ageMethod <> 'float';

-- This won't work, but you will try it by accident anyway
SELECT COUNT(*) FROM Bird_nests WHERE ageMethod = NULL;
-- THE ONLY WAY
SELECT COUNT(*) FROM Bird_nests WHERE ageMethod IS NULL;
SELECT COUNT(*) FROM Bird_nests WEHRE ageMethod IS NOT NULL;

-- JOINS 
-- 90% of time, we join tables on foreign key relationship 
SELECT * FROM Camp_assignment;
SELECT * FROM Camp_assignment JOIN Personnel
    ON Observer = Abbreviation
    LIMIT 10;

-- Join is general operation, can be applied to any tables, with any expression joining them 
-- Fundamentally binds all objects
SELECT * FROM Site CROSS JOIN Species;

-- Lets see if this makes sense 
SELECT COUNT(*) FROM Site;
SELECT COUNT(*) FROM Species;
SELECT 99*16;

-- Any condition can be expression, we have complete freedom here
-- But when there *is* a foreign key relationship, then what happens?
-- the result is the same as the table wit hthe foreign, but augmented with additional columns
SELECT * FROM Bird_nests BN JOIN Species S
    ON BN.SPecies = S.Code
    LIMIT 5;
SELECT COUNT(*) FROM Bird_nests BN JOIN Species S
    ON BN.Species = S.Code;

-- Table aliases
-- Sometimes, if column names are ambiguous where they're coming from,
-- you need to qualify them
SELECT * FROM Bird_nests JOIN Species
    ON Bird_nests.SPecies = Species.Code;
-- same, using a table alias
SELECT * FROM Bird_nests AS BN JOIN Species AS S
    ON BN.Species = S.Code;
-- You can also leave out the AS if you want
SELECT * FROM Bird_nests BN JOIN Species S
    ON BN.Speices = S.Code;

--- April 20th, 2026 ---
-- First review item: tri-value logic
-- Expression can have a value (if Boolean, TRUE or JALSE), but they can also be NULL
-- In selecting rows, NULL doesn't cut it, NULL doesn't count as TRUE

SELECT COUNT(*) FROM Bird_nests
    WHERE floatAge < 7 OR FloatAge >= 7; -- We'd think this would give us every row, but it didn't give us the NULLs

SELECT COUNT(*) FROM Bird_nests
    WHERE floatAge = NULL; -- WRONG WRONG WRONG WRONG WRONG

SELECT COUNT(*) FROM Bird_nests
    WHERE floatAge IS NULL; -- RIGHT RIGHT RIGHT RIGHT RIGHT

-- Everything is a table!
SELECT COUNT(*) FROM Bird_nests;
-- We looked at one example of nesting SELECTs

SELECT Scientific_name
    FROM Species
    WHERE Code NOT IN ( SELECT DISTINCT Species FROM Bird_nests);

-- Let's pretend that SQL didn't have a HAVING clause.  Could we somehow get the same functionality?
-- Let's go back to the example where we used a HAVING clause

SELECT Location, MAX(Area) AS Max_area
    FROM Site
    WHERE Location LIKE '%Canada'
    GROUP BY Location
    HAVING Max_area > 200;

-- Conceptually, WHERE and HAVING do the same exact thing - WHERE is for rows, HAVING is for groups

-- As a reminder, the Site table:
SELECT * FROM Site LIMIT 5;

___