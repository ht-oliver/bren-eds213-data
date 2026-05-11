-- Check observers at nome site between 1998 and 2000
SELECT DISTINCT Observer FROM Bird_nests N WHERE
((N.Year >= 1998 AND N.Year <= 2008) AND
Nest_ID LIKE '%nome%');

-- Get the count of measurements by each observer
SELECT N.Observer, COUNT (*) as Num_floated_nests FROM Bird_nests N WHERE
((N.Year >= 1998 AND N.Year <= 2008)
 AND (Nest_ID LIKE '%nome%') 
 AND (ageMethod = 'float'))
GROUP BY Observer
;


-- Join that table to Personnel, pick from Personnel
SELECT P.Name, COUNT(*) AS Num_floated_nests
FROM Bird_nests N
JOIN Personnel P ON N.Observer = P.Abbreviation
 WHERE
((N.Year >= 1998 AND N.Year <= 2008)
 AND (Nest_ID LIKE '%nome%') 
 AND (ageMethod = 'float'))
GROUP BY P.Name
HAVING COUNT(*) = 36; --Aggregate value, use HAVING


