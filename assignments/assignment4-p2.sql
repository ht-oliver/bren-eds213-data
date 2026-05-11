-- Step 1. To the above join, add an ON clause that selects only those
-- rows where the two people (the “A” person and the “B” person) worked 
-- at the same site: ON A.Site = .... You should wind up with a table with 15521 rows.

SELECT * FROM Camp_assignment A JOIN Camp_assignment B 
ON A.Site = B.Site;



-- Step 2.
SELECT * FROM Camp_assignment A JOIN Camp_assignment B 
ON A.Site = B.Site WHERE
    (A.Start <= B.End) AND 
    (A.End >= B.Start);


-- Step 3.
SELECT * FROM Camp_assignment A JOIN Camp_assignment B 
ON A.Site = B.Site WHERE
    (A.Start <= B.End) AND 
    (A.End >= B.Start) AND
    (A.Site  = 'lkri') AND
    A.Observer < B.Observer;

-- Step 4.
SELECT A.Site,
A.Observer AS Observer_1,
B.Observer AS Observer_2
FROM Camp_assignment A JOIN Camp_assignment B 
ON A.Site = B.Site WHERE
    (A.Start <= B.End) AND 
    (A.End >= B.Start) AND
    (A.Site  = 'lkri') AND
    A.Observer < B.Observer;

-- Bonus problem!
-- Step 4.
SELECT A.Site,
    P1.Name AS Name_1,
    P2.Name AS Name_2
FROM Camp_assignment A JOIN Camp_assignment B 
    ON A.Site = B.Site
JOIN Personnel P1 ON A.Observer = P1.Abbreviation
JOIN Personnel P2 ON B.Observer = P2.Abbreviation
WHERE
    (A.Start <= B.End) AND 
    (A.End >= B.Start) AND
    (A.Site = 'lkri') AND
    (A.Observer < B.Observer);
    