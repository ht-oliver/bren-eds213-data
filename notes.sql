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

SELECT Location, MAX(Area) AS Max_area

SELECT * FROM
    (SELECT Location, MAX(Area) AS Max_area
     FROM Site
     WHERE Location LIKE '%Canada'
     GROUP BY Location)
    WHERE Max_area > 200;

-- REVIEWING AND CONTINUING DISCUSSION OF JOINS

-- In some databases, to dod a Cartesian product you would just do a JOIN without a contition, e.g.,
SELECT * FROM A JOIN B;
-- **But** in DUCKdb, you have to say:
SELECT * FROM A CROSS JOIN B;
SELECT * FROM A;
SELECT * FROM B;

-- Here's what the Cartesian product looks like:
SELECT * FROM A CROSS JOIN B;

-- Lets a join cndition, which can be *any* expression!
SELECT * FROM A JOIN B ON acol1 < bcol1;

-- This is what's referred to as an INNER JOIN
SELECT * FROM A INNER JOIN B ON acol1 < bcol1;

-- Outer join: we're adding rows from one table that never got matched.
SELECT * FROM A RIGHT JOIN B ON acol1 < bcol2;

-- Just for completeness (this way more rare that you would want to do this):
SELECT * FROM A FULL OUTER JOIN B ON acol1 < bcol1;

-- Now, joining on a foreign key relationship is way more common

SELECT * FROM House;
SELECT * FROM Student;

    -- Typical thing to do:
SELECT * FROM Student S Join House H ON S.House_ID = H.House_ID;

-- One nice benefit of joining on a column that has the same name (i.e., House_ID here)
-- is you can use USING clause
SELECT * FROM Student JOIN House USING (House_ID);

-- Meanwhile, back in the bird database:
SELECT COUNT(*) FROM Bird_eggs;

-- For better viewing:
.mode line

SELECT * FROM Bird_eggs LIMIT 1;
SELECT * FROM Bird_eggs JOIN Bird_nests USING (Nest_ID) LIMIT 1;
SELECT COUNT(*) FROM Bird_eggs JOIN Bird_nests USING (Nest_ID);
.mode duckbox 

-- Important point!!! Ordering is assuredly lost doing a JOIN. So don't say this:
-- Ordering hsould always and only be the very last thing
SELECT * FROM
    (SELECT * FROM Bird_eggs ORDER BY Width)
    JOIN Bird_nests
    USING (Nest_ID); -- WRONG WRONG WRONG WRONG WRONG

-- Gotcha with DuckDB... it's not as smart as some other databases
SELECT Nest_ID, COUNT(*)
    FROM Bird_nests JOIN Bird_eggs USING (Nest_ID)
    GROUP BY Nest_ID;

-- Some databases allow you to say: 
SELECT Nest_ID, Species, COUNT(*)
    FROM Bird_nests JOIN Bird_eggs USING (Nest_ID)
    GROUP BY Nest_ID; -- This throws an error

-- Workaround
SELECT Nest_ID, ANY_VALUE(Species), COUNT(*)
    FROM Bird_eggs JOIN Bird_nests USING (Nest_ID)
    GROUP BY Nest_ID;

SELECT Nest_ID, ANY_VALUE(Species), COUNT(*)
    FROM Bird_eggs JOIN Bird_nests USING (Nest_ID)
    GROUP BY Nest_ID, Species;

SELECT Nest_ID, Species, Egg_num, Width, Length FROM
    Bird_eggs JOIN Bird_nests USING (Nest_ID)
    ORDER BY Nest_ID, Egg_num
    LIMIT 10;

---- April 22nd, 2026
-- In toy.duckdb

SELECT * FROM A;
SELECT * FROM B;

SELECT * FROM A CROSS JOIN B;

SELECT acol1, acol2 FROM (SELECT * FROM A CROSS JOIN B);

-- A Cross Join combines every row from table a with every row from table B
-- if A has 4 rows and B has 3, A CROSS JOIN B will have 12 
SELECT acol1, ANY_VALUE(acol2), COUNT(*)
    FROM (SELECT * FROM A CROSS JOIN B)
    GROUP BY acol1;

-- 
SELECT acol1, ANY_VALUE(acol2), COUNT(bcol3)
    FROM (SELECT * FROM A CROSS JOIN B)
    GROUP BY acol1;

-- Using a condition
SELECT * FROM A JOIN B ON aco1 < bcol1

-- INNER or OUTER JOINS
SELECT * FROM Student;
SELECT * FROM HOUSE;
-- Both tables have House_ID
--INNER 
SELECT * FROM Student AS S JOIN House AS H ON S.House_ID = H.House_ID;
-- Same thing as above, but compact
SELECT * FROM Student JOIN House USING (House_ID);

SELECT * FROM Student LEFT JOIN House USING (House_ID);

--- Now we're moving to our database database to create a database or something
--- Creating a table
CREATE TABLE Snow_cover (
    Site VARCHAR NOT NULL,
    Year INTEGER NOT NULL CHECK (Year BETWEEN 1990 AND 2018),
    Date DATE NOT NULL,
    Plot VARCHAR NOT NULL,
    Location VARCHAR NOT NULL,
    Snow_cover REAL CHECK (Snow_cover BETWEEN 0 AND 130),
    Water_cover REAL CHECK (Water_cover BETWEEN 0 AND 130),
    Land_cover REAL CHECK (Land_cover BETWEEN 0 AND 130),
    Total_cover REAL CHECK (Total_cover BETWEEN 0 AND 130),
    Observer VARCHAR,
    Notes VARCHAR,
    PRIMARY KEY (Site, Plot, Location, Date),
    FOREIGN KEY (Site) REFERENCES Site (Code)
);

SELECT * FROM  Camp_Assignment LIMIT (5);
SELECT * FROM Personnel LIMIT (5);
--Get me three columns from 

CREATE TEMP TABLE Camp_assignment_copy AS
   SELECT * FROM Camp_assignment; 

SELECT Year, Site, Name 
   FROM Camp_assignment_copy JOIN Personnel ON Observer = Abbreviation;

CREATE TEMP TABLE Camp_personnel_tmp AS
   SELECT Year, Site, Name 
   FROM Camp_assignment_copy JOIN Personnel ON Observer = Abbreviation;

CREATE VIEW Camp_personnel_v AS
   SELECT Year, Site, Name 
   FROM Camp_assignment_copy JOIN Personnel ON Observer = Abbreviation;

SELECT view_name FROM duckdb_views;


---- Missed class
SELECT Camp_assignment.Site FROM Camp_assignment
UNION
SELECT Code FROM Site AS Site;

