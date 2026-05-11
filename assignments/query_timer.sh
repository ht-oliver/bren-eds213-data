## Part 1
start=$SECONDS # capture start time
for i in $(seq $2); do  # run query num_reps (1000) times
    duckdb $4 "$3"
done
end=$SECONDS # Capture end time
elapsed=$((end-start)) # Compute elapsed time
per_step=$(echo "scale=7; $elapsed/$2" | bc) # Divide by num_reps to get time per query
echo "$1,$per_step" >> $5 # Append label and result to CSV file

# Run this line to create the csv
## bash query_timer.sh with_index_a 1000 'SELECT COUNT(*) FROM Bird_nests' ../database/database.duckdb timings.csv


## Part 2

## Subquery
# bash query_timer.sh subquery 1000 'SELECT Code FROM Species WHERE Code NOT IN (SELECT DISTINCT Species FROM Bird_nests)' ../database/database.duckdb timings.csv


## Outer Join
# bash query_timer.sh outer_join 1000 'SELECT Code FROM BIrd_nests RIGHT JOIN Species ON Species = Code WHERE Nest_ID IS NULL' ../database/database.duckdb timings.csv

## Except
# bash query_timer.sh except 1000 'SELECT Code FROM Species EXCEPT SELECT DISTINCT Species FROM Bird_nests' ../database/database.duckdb timings.csv

# subquery,.0400000
# outer_join,.0390000
# except,.0410000

# The outer join is fastest!