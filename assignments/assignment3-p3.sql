--- My task is to list bird species by descending order of maximum egg volumes in each nest
--- First, I will compute the average egg volumes per nest 

CREATE TEMP TABLE Averages AS
    SELECT Nest_ID, AVG((3.14/6)*(Width)^2 * Length) AS Avg_volume
        FROM Bird_eggs
        GROUP BY Nest_ID;

--- Second, I will join these averages to the bird_nests table by Nest_ID, group results by species column of Bird_nests
--- I retroactively made this into a temporary table so I could join it to the species table
CREATE TEMP TABLE species_egg_volume AS
 SELECT Species, MAX(Avg_volume) AS max_avg_volume --change name so we don't have parenthesis in our final table
    FROM Bird_nests JOIN Averages USING (Nest_ID)
    GROUP BY Species;

--- Lastly, I will join this to the species table using the 'code' column
SELECT Scientific_name, max_avg_volume -- I'm only interseted in the scientific name and max avg volume
FROM Species JOIN  species_egg_volume ON Species.code = species_egg_volume.Species
ORDER BY max_avg_volume DESC;

