-- Which sites have no egg data?

-- NOT IN Method
SELECT Code
FROM Site
WHERE Code NOT IN (SELECT DISTINCT Site FROM Bird_eggs)
ORDER BY Code;

-- OUTER JOIN with IS NULL
SELECT Code
FROM Site
LEFT JOIN Bird_eggs ON Site.Code = Bird_eggs.Site
WHERE Bird_eggs.Site IS NULL
ORDER BY Code;