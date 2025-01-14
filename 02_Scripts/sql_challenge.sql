/*   As a Data Analyst, it is essential to ensure the reliability of your data. 
 * The actual_elapsed_time column in the flights table shows the current data on the time from departure 
 * to arrival. Since it's unlikely there is a timer running for each flight, the value is probably 
 * calculated afterward. We might want to double-check this to ensure our analysis and recommendations are 
 * accurate. Verifying it will give us a solid basis for making decisions.
 */SELECT * FROM flights;



/* 1.Using the data in the remaining columns in the flights table, can you think of a way to verify our assumption?
 *   Please provide a text answer below.
 */

-- The comparison between actual_elapsed_time column with dep_time & arr_time to identify the  descrepencies.
SELECT FLIGHT_DATE, airline, tail_number, dep_time, arr_time, actual_elapsed_time,
	TO_char (dep_time, 'fm0000'):: time DEP_TIME_act,
	flight_date + TO_char (dep_time, 'fm0000'):: time date_TIME_dep,
	TO_char (arr_time, 'fm0000'):: time arr_TIME_act,
	flight_date + TO_char (arr_time, 'fm0000'):: time date_TIME_arr
FROM flights
WHERE CANCELLED != 1 
  AND DEP_TIME IS NOT NULL 
  AND ARR_TIME IS NOT NULL;

/* 2.1 The first step is to become familiar with the dep_time, arr_time and actual_elapsed_time columns.
 *   Based on the column names and what you already know from previous exercises about the information 
 * that is stored in these three columns, what are your assumptions about the data types of the values?
 * Check the source documentation.
 */

-- According to the documentation:
-- arr_time is Actual Arrival Time (local time: hhmm) represent in integer.
-- dep_time isActual Departure Time (local time: hhmm)represent in integer.
-- actual_elapsed_time is Elapsed Time of Flight, in Minutes represent in integer.

/* 2.2 Retrieve all unique values from these columns in three separate queries and switch between ascending/descending order.
 *     Did your assumptions turn out to be correct?
 * 	   Please provide the queries and observations as text below.
 */


-- arr_time column is there is the flight arrive in every minute from 00.01 to midnight and there is also Null
SELECT DISTINCT (arr_time)
FROM FLIGHTS
ORDER BY arr_time ASC;

SELECT DISTINCT (arr_time)
FROM FLIGHTS
ORDER BY arr_time DESC ;

-- dep_time is column is there is the flight depart in every minute from 00.01 to midnight and there is also Null
SELECT DISTINCT (dep_time)
FROM FLIGHTS
ORDER BY dep_time ASC;

SELECT DISTINCT (dep_time)
FROM FLIGHTS
ORDER BY dep_time DESC ;

-- actual_elapsed_time column is the minute of each flight, the shortest one is 15min, and liongest is 792min + there is also Null.
SELECT DISTINCT (actual_elapsed_time)
FROM FLIGHTS
ORDER BY actual_elapsed_time ASC;

SELECT DISTINCT (actual_elapsed_time)
FROM FLIGHTS
ORDER BY actual_elapsed_time DESC ;



/* 3.1 Next, calculate the difference of dep_time and arr_time and call it flight_duration.
 * 	   Please provide the query below.
 */

SELECT FLIGHT_DATE, airline, tail_number, dep_time, arr_time,
       (arr_time - dep_time) AS flight_duration
FROM flights
WHERE CANCELLED = 0 
  AND DEP_TIME IS NOT NULL 
  AND ARR_TIME IS NOT NULL;



/* 3.2 Are the calculated flight duration values correct? Compare it with the actual_elapsed_time column.
 *  If not, what's the problem and how can we solve it?
 *     Please provide the query and a text answer below.
 */
SELECT FLIGHT_DATE, airline, tail_number, dep_time, arr_time, actual_elapsed_time,
       (arr_time - dep_time) AS flight_duration
FROM flights
WHERE CANCELLED = 0 
  AND DEP_TIME IS NOT NULL 
  AND ARR_TIME IS NOT NULL;
 
 -- The problem is data type is an interger, so it's not accounting for the day change, leading to incorrect calculations. 


/* 4 In order to calculate correct flight duration values we need to convert dep_time, arr_time and actual_elapsed_time 
 *   into useful data types first.
 *   Change dep_time and arr_time into TIME variables, call them dep_time_f and arr_time_f. 
 *   Change actual_elapsed_time into an INTERVAL variable, call it actual_elapsed_time_f.
 *   Query flight_date, origin, dest, dep_time, dep_time_f, arr_time, arr_time_f, actual_elapsed_time and actual_elapsed_time_f.
 *   Please provide the query below.
 */
SELECT FLIGHT_DATE, origin, dest,
	dep_time,
	TO_char (dep_time, 'fm0000'):: time DEP_TIME_f,
	arr_time,
	TO_char (arr_time, 'fm0000'):: time arr_TIME_f,
	actual_elapsed_time,
	MAKE_INTERVAL(mins => actual_elapsed_time) AS actual_elapsed_time_f
FROM flights
WHERE CANCELLED != 1 
  AND DEP_TIME IS NOT NULL 
  AND ARR_TIME IS NOT NULL;



/* 5.1 Querying the raw columns next to the ones we have transformed, makes it a lot easier to compare the result to the input.
 *     This allows for quick prototyping and debugging and helps to understand how functions work. 
 *     To optimize our query in terms of performance and readability, we can always remove unneccessary columns in the end. 
 *     Use the previous query and calculate the difference of arr_time_f and dep_time_f and call it flight_duration_f.
 * 	   Please provide the query below.
 */
 WITH FIRST_step AS (
 	SELECT FLIGHT_DATE, origin, dest,
		dep_time,
		TO_char (dep_time, 'fm0000'):: time DEP_TIME_f,
		arr_time,
		TO_char (arr_time, 'fm0000'):: time arr_TIME_f,
		actual_elapsed_time,
		MAKE_INTERVAL(mins => actual_elapsed_time) AS actual_elapsed_time_f
	FROM flights
	WHERE CANCELLED != 1 
  	AND DEP_TIME IS NOT NULL 
  	AND ARR_TIME IS NOT NULL
 ),
 SECOND_step AS (
 	SELECT FLIGHT_DATE, origin, dest, DEP_TIME_f, arr_TIME_f, actual_elapsed_time_f,
 	(arr_TIME_f - DEP_TIME_f) AS flight_duration
 	FROM FIRST_step
 	)
SELECT *
FROM SECOND_step
-- ORDER BY actual_elapsed_time_f DESC ;
-- This flight_duration calculation is still not correct, as it does not account for date changes or time zones.

/* 5.2 Compare the calculated flight duration values in flight_duration_f with the values in the actual_elapsed_time_f column:
 * show 
 * 		- total number of "same value" match
 * 		- total count of all values 
 * 		- calculate the percentage of values that are equal in both columns vs total count of all values
 * Please provide the query below.
 */

/* Explanation of the solution: 
 * The output of comparing two numbers, actual_elapsed_time_f and flight_duration_f, results in TRUE/FALSE of type BOOLEAN
 * Casting a BOOLEAN into an INTEGER turns TRUE=1 and FALSE=0, summing up the values gives the total number of equal values
 * In order to calculate the percentage, we can simply divide it by the total number of flights using COUNT(*)
 * Remember: In SQL, dividing two INTEGERS results in an INTEGER. Therefore we need to cast one value as NUMERIC.
 */

WITH FIRST_step AS (
 	SELECT FLIGHT_DATE, origin, dest,
		dep_time,
		TO_char (dep_time, 'fm0000'):: time DEP_TIME_f,
		arr_time,
		TO_char (arr_time, 'fm0000'):: time arr_TIME_f,
		actual_elapsed_time,
		MAKE_INTERVAL(mins => actual_elapsed_time) AS actual_elapsed_time_f
	FROM flights
	WHERE CANCELLED != 1 
  	AND DEP_TIME IS NOT NULL 
  	AND ARR_TIME IS NOT NULL
  	AND actual_elapsed_time IS NOT NULL 
 ),
 SECOND_step AS (
 	SELECT FLIGHT_DATE, origin, dest, DEP_TIME_f, arr_TIME_f, actual_elapsed_time_f,
 	(arr_TIME_f - DEP_TIME_f) AS flight_duration_f
 	FROM FIRST_step
 ),
 Third_step AS (
 	SELECT flight_date, flight_duration_f, actual_elapsed_time_f,
	(CASE 
		WHEN flight_duration_f = actual_elapsed_time_f THEN 1
		ELSE 0
	END) AS comparison
	FROM second_step
),
Forth_step AS (
 	SELECT 
 		COUNT(*) AS total_count,
 		count (DISTINCT comparison =1) AS match_count
 	FROM Third_step
)
SELECT 
	match_count AS "Total Same Value Matches",
	total_count AS "Total Count of All Values",
	ROUND((match_count::decimal / total_count) * 100, 2) AS "Percentage of Matches"
FROM Forth_step;


/* 5.3 Given the percentage of matching values, can you come up with possible explanations for why the rate is so low?
 *     Please provide a text answer below.
 */
-- The rate is so low because it does not account for date changes or time zones.



/* 6.1 Differences due to time zones might be one reason for the low rate of matching values.
 *     To make sure the dep_time and arr_time values are all in the same time zone we need to know in which time zone they are.
 *     Take your query from exercise 5.1 and add the time zone values from the airports table.
 * 	   Make sure to transform them to INTERVAL and change their names to origin_tz and dest_tz.
 *     Please provide the query below.
 */

WITH FIRST_step AS (
 	SELECT FLIGHT_DATE, origin, dest,
		dep_time,
		TO_char (dep_time, 'fm0000'):: time DEP_TIME_f,
		arr_time,
		TO_char (arr_time, 'fm0000'):: time arr_TIME_f,
		actual_elapsed_time,
		MAKE_INTERVAL(mins => actual_elapsed_time) AS actual_elapsed_time_f
	FROM flights
	WHERE CANCELLED != 1 
  	AND DEP_TIME IS NOT NULL 
  	AND ARR_TIME IS NOT NULL
  	AND actual_elapsed_time IS NOT NULL 
 ),
 SECOND_step AS (
 	SELECT 
 	f.FLIGHT_DATE, 
 	f.origin, 
 	f.dest, 
 	f.DEP_TIME_f, 
 	f.arr_TIME_f, 
 	f.actual_elapsed_time_f,
 	(arr_TIME_f - DEP_TIME_f) AS flight_duration,
 	INTERVAL '1 hour' * a1.tz AS origin_tz,  
 	INTERVAL '1 hour' * a2.tz AS dest_tz   
 	FROM FIRST_step f
 	JOIN AIRPORTS a1 
 	ON a1.faa = f.origin
 	JOIN AIRPORTS a2 
 	ON a2.faa = f.dest
 	)
SELECT *
FROM SECOND_step;

/* 6.2 Use the time zone columns to convert dep_time_f and arr_time_f to UTC and call them dep_time_f_utc and arr_time_f_utc.
 * 	   Calculate the difference of both columns and call it flight_duration_f_utc.
 *     Please provide the query below.
 */
WITH FIRST_step AS (
 	SELECT FLIGHT_DATE, origin, dest,
		dep_time,
		TO_char (dep_time, 'fm0000'):: time DEP_TIME_f,
		arr_time,
		TO_char (arr_time, 'fm0000'):: time arr_TIME_f,
		actual_elapsed_time,
		MAKE_INTERVAL(mins => actual_elapsed_time) AS actual_elapsed_time_f
	FROM flights
	WHERE CANCELLED != 1 
  	AND DEP_TIME IS NOT NULL 
  	AND ARR_TIME IS NOT NULL
  	AND actual_elapsed_time IS NOT NULL
 ),
 SECOND_step AS (
 	SELECT 
 	f.FLIGHT_DATE, 
 	f.origin, 
 	f.dest, 
 	f.DEP_TIME_f, 
 	f.arr_TIME_f, 
 	f.actual_elapsed_time_f,
 	(arr_TIME_f - DEP_TIME_f) AS flight_duration,
 	INTERVAL '1 hour' * a1.tz AS origin_tz,  
 	INTERVAL '1 hour' * a2.tz AS dest_tz   
 	FROM FIRST_step f
 	JOIN AIRPORTS a1 
 	ON a1.faa = f.origin
 	JOIN AIRPORTS a2 
 	ON a2.faa = f.dest
 	),
third_step AS (
SELECT flight_date, origin, dest,
		(dep_time_f - origin_tz) AS dep_time_f_utc,
		(arr_time_f - dest_tz) AS arr_time_f_utc,
		actual_elapsed_time_f
FROM second_step
),
Forth_step as(
SELECT flight_date, origin, dest,
		dep_time_f_utc,
		arr_time_f_utc,
		(arr_time_f_utc - dep_time_f_utc) AS flight_duration_f_utc,
		actual_elapsed_time_f
		FROM third_step
)
SELECT *
FROM Forth_step
ORDER BY flight_date, dep_time_f_utc;



/* 6.3 Again, calculate the percentage of matching records using the new flight_duration_f_utc column.
 *     Try to round the result to two decimals.
 *     Explain the increase in matching records. (Now, the time zone is match on the UTC, the result is 81.41%)
 *     Please provide the query and a text answer below.
 */
WITH FIRST_step AS (
 	SELECT FLIGHT_DATE, origin, dest,
		dep_time,
		TO_char (dep_time, 'fm0000'):: time DEP_TIME_f,
		arr_time,
		TO_char (arr_time, 'fm0000'):: time arr_TIME_f,
		actual_elapsed_time,
		MAKE_INTERVAL(mins => actual_elapsed_time) AS actual_elapsed_time_f
	FROM flights
	WHERE CANCELLED != 1 
  	AND DEP_TIME IS NOT NULL 
  	AND ARR_TIME IS NOT NULL
  	AND actual_elapsed_time IS NOT NULL
 ),
 SECOND_step AS (
 	SELECT 
 	f.FLIGHT_DATE, 
 	f.origin, 
 	f.dest, 
 	f.DEP_TIME_f, 
 	f.arr_TIME_f, 
 	f.actual_elapsed_time_f,
 	(arr_TIME_f - DEP_TIME_f) AS flight_duration,
 	INTERVAL '1 hour' * a1.tz AS origin_tz,  
 	INTERVAL '1 hour' * a2.tz AS dest_tz   
 	FROM FIRST_step f
 	JOIN AIRPORTS a1 
 	ON a1.faa = f.origin
 	JOIN AIRPORTS a2 
 	ON a2.faa = f.dest
 	),
third_step AS (
SELECT flight_date, origin, dest,
		(dep_time_f - origin_tz) AS dep_time_f_utc,
		(arr_time_f - dest_tz) AS arr_time_f_utc,
		actual_elapsed_time_f
FROM second_step
),
Forth_step as(
SELECT flight_date, origin, dest,
		dep_time_f_utc,
		arr_time_f_utc,
		(arr_time_f_utc - dep_time_f_utc) AS flight_duration_f_utc,
		actual_elapsed_time_f
		FROM third_step
),
Fifth_step AS (
 	SELECT flight_date, flight_duration_f_utc, actual_elapsed_time_f,
	(CASE 
		WHEN flight_duration_f_utc = actual_elapsed_time_f  THEN 1
		ELSE 0
	END) AS comparison
	FROM forth_step
),
sixth_step AS (
 	SELECT 
 		COUNT(*) AS total_count,
 		SUM(comparison) AS match_count
 	FROM fifth_step
)
SELECT 
	match_count AS "Total Same Value Matches",
	total_count AS "Total Count of All Values",
	ROUND((match_count::decimal / total_count) * 100, 2) AS "Percentage of Matches"
FROM sixth_step;



/* Extra Challenge
 * For the essential part of the SQL challenge, it's ok if you just read through the SQL query.
 * Queries 7.1 and 7.2 are just there to make you aware of the problem...
 * Query 7.3 actual implements a solution. Pay especially attention to the CASE WHEN statement.
 * this is the statement that fixes the issue for overnight flights
 */

/* 7.1 We managed to increase the rate of matching records to >80%, but it's still not at 100%.
 *     Could overnight flights be an issue?
 *     What is special about values in the flight_duration_f_utc column for overnight flights?
 * 	   Hint: order by flight_duration_f_utc
 *     Please provide the query and a text answer below.
 */




/* 7.2 Calculate the total number of flights that arrived after midnight UTC.
 *     Please provide the query below.
 */




/* 7.3 Use your knowledge from 7.1 and 7.2 to increase the rate of matching records even further.
 *     Please provide the query below.
 */

WITH FIRST_step AS (
 	SELECT FLIGHT_DATE, origin, dest,
		dep_time,
		flight_date + TO_char (dep_time, 'fm0000'):: time DEP_TIME_f,
		arr_time,
		flight_date + TO_char (arr_time, 'fm0000'):: time arr_TIME_f,
		actual_elapsed_time,
		MAKE_INTERVAL(mins => actual_elapsed_time) AS actual_elapsed_time_f
	FROM flights
	WHERE CANCELLED != 1 
  	AND DEP_TIME IS NOT NULL 
  	AND ARR_TIME IS NOT NULL
  	AND actual_elapsed_time IS NOT NULL
 ),
 SECOND_step AS (
 	SELECT 
 	f.FLIGHT_DATE, 
 	f.origin, 
 	f.dest, 
 	f.DEP_TIME_f, 
 	f.arr_TIME_f, 
 	f.actual_elapsed_time_f,
 	(arr_TIME_f - DEP_TIME_f) AS flight_duration,
 	INTERVAL '1 hour' * a1.tz AS origin_tz,  
 	INTERVAL '1 hour' * a2.tz AS dest_tz   
 	FROM FIRST_step f
 	JOIN AIRPORTS a1 
 	ON a1.faa = f.origin
 	JOIN AIRPORTS a2 
 	ON a2.faa = f.dest
 	),
third_step AS (
SELECT flight_date, origin, dest,
		(dep_time_f - origin_tz) AS dep_time_f_utc,
		(arr_time_f - dest_tz) AS arr_time_f_utc,
		actual_elapsed_time_f
FROM second_step
),
Forth_step as(
SELECT flight_date, origin, dest,
		dep_time_f_utc,
		arr_time_f_utc,
		(arr_time_f_utc - dep_time_f_utc) AS flight_duration_f_utc,
		actual_elapsed_time_f
		FROM third_step
),
Fifth_step AS (
 	SELECT flight_date, flight_duration_f_utc, actual_elapsed_time_f,
	(CASE 
		WHEN flight_duration_f_utc = actual_elapsed_time_f  THEN 1
		ELSE 0
	END) AS comparison
	FROM forth_step
),
sixth_step AS (
 	SELECT 
 		COUNT(*) AS total_count,
 		SUM(comparison) AS match_count
 	FROM fifth_step
)
SELECT 
	match_count AS "Total Same Value Matches",
	total_count AS "Total Count of All Values",
	ROUND((match_count::decimal / total_count) * 100, 2) AS "Percentage of Matches"
FROM sixth_step;


/*
 * ok great! we get a match of >90%! We leave it at that for now...
 * After this long part of verifying the column actual_elapsed_time we feel confident
 * to make analysis based on this column and give out business recommendations.
*/

-- DST
https://openflights.org/help/time.php