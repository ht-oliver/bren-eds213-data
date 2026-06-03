-- Load extensions for geometry and reading remote files
-- INSTALL spatial;
-- INSTALL httpfs;
LOAD spatial;
LOAD httpfs;

-- Create Fips table
CREATE TABLE Fips AS
SELECT * FROM read_csv('https://apps.bren.ucsb.edu/eds213-data/walkability/fips_state_county.csv');

-- Create walkability view for New Mexico
CREATE VIEW Walkability_nm AS
SELECT GEOID10, STATEFP, COUNTYFP, TRACTCE, BLKGRPCE,
        CBSA, CBSA_Name, TotPop, NatWalkInd, geom_wgs84
FROM read_parquet('https://apps.bren.ucsb.edu/eds213-data/walkability/walkability_wgs84.parquet')
WHERE STATEFP = '35';

-- Join tables on STATE FP and COUNTY FP
CREATE VIEW Walkind_nm AS
SELECT nm.*, f.State_name, f.County_name
FROM Walkability_nm nm
JOIN Fips f ON nm.STATEFP = f.STATEFP AND nm.COUNTYFP = f.COUNTYFP;

-- Find walkability for 35.092904, -106.614237
SELECT * FROM Walkind_nm
WHERE ST_Within(ST_point(-106.614, 35.092), geom_wgs84);
-- NatWalkInd = 12.3333333
-- This indicatest that the area is above average for walkability, but not necessarily exceptional
-- This does align with my expections, this area is near a university so there's a lot of foot traffic
-- but the area is still primarily designed for cars.

-- Average Walkability index at Census Tract
SELECT TRACTCE, COUNT(*) AS Block_count, AVG(NatWalkInd) AS Walkind_tract_avg
FROM Walkind_nm
WHERE TRACTCE = '000300'
  AND COUNTYFP = '001'
  AND STATEFP = '35'
GROUP BY TRACTCE;

-- Average walkability at County level
SELECT COUNTYFP, County_name, COUNT(*) AS Block_count, AVG(NatWalkInd) AS Walkind_county_avg
FROM Walkind_nm
WHERE COUNTYFP = '001'
  AND STATEFP = '35'
GROUP BY COUNTYFP, County_name;
-- The walkability index at my favorite location is very close but slightly lower than
-- the walkability index of the county. This is surprising, given that my favorite
-- area seemed to me like one of the more walkable areas in the city of Albuquerque
-- Finding out that it's slightly below average is surprising, this area is in a neighborhood
-- next to the University of New Mexico - I used to walk there all the time.

-- Export results
COPY ( -- export to file with COPY
    SELECT nm.*, -- select results and averages
           tract_avg.Walkind_tract_avg,
           county_avg.Walkind_county_avg
    FROM Walkind_nm nm
    JOIN (
        SELECT AVG(NatWalkInd) AS Walkind_tract_avg
        FROM Walkind_nm
        WHERE TRACTCE = '000300' -- get average for the tract
          AND COUNTYFP = '001'
          AND STATEFP = '35'
    ) AS tract_avg ON true
    JOIN (
        SELECT AVG(NatWalkInd) AS Walkind_county_avg -- average for the county
        FROM Walkind_nm
        WHERE COUNTYFP = '001'
          AND STATEFP = '35'
    ) AS county_avg ON true
    WHERE nm.TRACTCE = '000300'
      AND nm.COUNTYFP = '001'
      AND nm.STATEFP = '35'
) TO 'walkability_results.csv' (HEADER, DELIMITER ',');

-- The geometry column is NOT saved as a geometry object. It's a character string 
-- A spatial geometry-specific data format like GeoParquet or GeoJSON would preserve
-- the geometry.