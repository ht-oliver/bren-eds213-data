

-- STEP 1: Load CSV files into tables
CREATE TABLE Nests_big AS SELECT * FROM 'nests_big.csv';

CREATE TABLE Eggs_big AS SELECT * FROM 'eggs_big.csv';

-- Explore the tables (row counts, columns, sample rows, schema)
SELECT COUNT(*) FROM Nests_big;
SELECT COUNT(*) FROM Eggs_big;
DESCRIBE Nests_big;
DESCRIBE Eggs_big;
SELECT * FROM Nests_big LIMIT 5;
SELECT * FROM Eggs_big LIMIT 5;


-- STEP 2: 3-way JOIN — Eggs_big + Nests_big + Species
-- Filter to Calidris alpina only.
-- Expected: 2912 rows, 10 columns.

SELECT *
FROM Eggs_big
    JOIN Nests_big USING (Nest_ID)
    JOIN Species ON Species.Code = Nests_big.Species
WHERE Scientific_name = 'Calidris alpina';



-- STEP 3: Narrow to Site + egg Volume
-- Compute volume using: V = (π/6) * W² * L, where π = 3.14
-- Expected: 2912 rows, 2 columns (Site, Volume).


SELECT
    Site,
    (3.14 / 6) *  Width  *  Width  *  Length AS Volume
FROM Eggs_big
    JOIN Nests_big USING (Nest_ID)
    JOIN Species ON Species.Code = Nests_big.Species
WHERE Scientific_name = 'Calidris alpina';


-- STEP 4: Replace Site with Longitude
-- Join with the Site table. Watch out: both Species and Site
-- have a column named Code — prefix with table name to disambiguate.
-- Expected: 2912 rows, 2 columns (Longitude, Volume).


SELECT
    Site.Longitude,
    (3.14 / 6) *  Width  *  Width  *  Length AS Volume
FROM Eggs_big
    JOIN Nests_big USING (Nest_ID)
    JOIN Species ON Species.Code = Nests_big.Species
    JOIN Site ON Site.Code = Nests_big.Site
WHERE Scientific_name = 'Calidris alpina';



-- STEP 5: Fix longitude values
-- Longitudes range from -164.9 to 170.6 in the Site table.
-- Positive values are actually west of the ±180 meridian,
-- so replace them with: longitude - 360.


SELECT
    CASE
        WHEN Site.Longitude > 0 THEN Site.Longitude - 360
        ELSE Site.Longitude
    END AS Longitude,
    (3.14 / 6) *  Width  *  Width  *  Length AS Volume
FROM Eggs_big
    JOIN Nests_big USING (Nest_ID)
    JOIN Species ON Species.Code = Nests_big.Species
    JOIN Site ON Site.Code = Nests_big.Site
WHERE Scientific_name = 'Calidris alpina';



-- STEP 6: Save as a view or temp table


-- Option A: View (no data copied, always reflects source tables)
CREATE VIEW egg_volumes AS
    SELECT
    CASE
        WHEN Site.Longitude > 0 THEN Site.Longitude - 360
        ELSE Site.Longitude
    END AS Longitude,
    (3.14 / 6) *  Width  *  Width  *  Length AS Volume
FROM Eggs_big
    JOIN Nests_big USING (Nest_ID)
    JOIN Species ON Species.Code = Nests_big.Species
    JOIN Site ON Site.Code = Nests_big.Site
WHERE Scientific_name = 'Calidris alpina';



-- STEP 7: Linear regression — slope and Pearson correlation
-- Volume is the dependent variable, Longitude is independent.
-- Expected: Slope ≈ -4.821, PCC ≈ -0.108


SELECT
    regr_slope(Volume, Longitude) AS Slope,
    corr(Volume, Longitude)       AS PCC
FROM egg_volumes;



-- PART 2: Short-answer questions


-- Q1 (6pts): Does DuckDB automatically guarantee that a Nest_ID
-- in Eggs_big actually exists in Nests_big? If yes, how? If no, why not?
-- Answer: No it does not. DuckDB typically enforces the Foreign Keys correspond
-- to a primary key in the join table, but since we create these tables from
-- a .csv with CREATE TABLE the specific key designations were not made


-- Q2 (2pts): What query did you use to find the min and max
-- longitude values in the Site table?

-- Answer:  SELECT MIN(Longitude), MAX(Longitude) FROM Site;


-- Q3 (2pts): Given PCC ≈ -0.108, how would you characterize
-- the correlation between egg volume and longitude for
-- Calidris alpina in Arctic Canada?
-- Answer: A small but significant negative correlation