-- Creating table for fetching the corona virus data
DROP TABLE corona;
SET datestyle = 'DMY';

CREATE TABLE corona (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    province VARCHAR(120) NOT NULL,
    country_or_region VARCHAR(200) NOT NULL,
    latitude NUMERIC(20, 5) NOT NULL,
    longitude NUMERIC(20, 6) NOT NULL,
    date DATE NOT NULL,
    confirmed_cases BIGINT NOT NULL,
    deaths BIGINT NOT NULL,
    recovered_cases BIGINT NOT NULL
);

-- fetching the data in the table
\copy corona(province, country_or_region, latitude, longitude, date, confirmed_cases, deaths, recovered_cases) FROM 'C:\Users\ELCOT\Desktop\Internship\Projects\DA - 1 Corona Virus Analysis with SQL\Corona Virus Dataset.csv' WITH (FORMAT csv, HEADER);

-- Analysis

-- Q1. Write a code to check NULL values
SELECT 'No NULL values in all columns' AS basic_info;
SELECT 'I created the table, where each column has not-nullable property. While fetching the data it shows no errors, so there is no null values in the dataset.' AS reason;
-- Q2. If NULL values are present, update them with zeros for all columns.

-- I created the table, where each column has not-nullable property.  
-- While fetching the data it shows no errors, so there is no null values in the dataset.


-- Q3. Check total number of rows
SELECT COUNT(*) FROM corona;


-- Q4. Check what is start_date and end_date
SELECT MIN(date) as start_date, MAX(date) as end_date FROM corona;


-- Q5. Number of month present in dataset
SELECT 
    t.start_date,
    t.end_date,
    (DATE_PART('year', AGE(t.end_date, t.start_date)) * 12 + DATE_PART('month', AGE(t.end_date, t.start_date))) AS no_of_months
FROM (SELECT MIN(date) as start_date, MAX(date) as end_date FROM corona) t;


-- Q6. Find monthly average for confirmed, deaths, recovered
SELECT
    TO_CHAR(DATE_TRUNC('month', date), 'Month YYYY') AS months,
    ROUND(AVG(t.total_confirmed_cases), 2) AS average_confirmed_cases,
    ROUND(AVG(t.total_deaths), 2) AS average_deaths,
    ROUND(AVG(t.total_recovered_cases), 2) AS average_recovered_cases
FROM
    (SELECT
    date,
    SUM(confirmed_cases) AS total_confirmed_cases,
    SUM(deaths) AS total_deaths,
    SUM(recovered_cases) AS total_recovered_cases
FROM
    corona
GROUP BY
    date) t
GROUP BY
    DATE_TRUNC('month', date)
ORDER BY
    DATE_TRUNC('month', date);


-- Q7. Find most frequent value for confirmed, deaths, recovered each month
-- confirmed_cases
WITH confirmed_freq AS (
SELECT 
    DATE_TRUNC('month', t.date) as months, 
    t.confirmed_cases, 
    COUNT(t.confirmed_cases) AS freq 
FROM (SELECT
    date AS date,
    SUM(confirmed_cases) AS confirmed_cases
FROM    
    corona
GROUP BY
    date) t
GROUP BY DATE_TRUNC('month', t.date), confirmed_cases
),
ranked_confirmed_freq AS (
    SELECT 
        months, 
        confirmed_cases, 
        freq, 
        ROW_NUMBER() OVER (PARTITION BY months ORDER BY freq DESC, confirmed_cases DESC) AS rank
    FROM confirmed_freq
)
SELECT 
    TO_CHAR(months, 'Month YYYY') AS months, 
    confirmed_cases
FROM ranked_confirmed_freq 
WHERE rank = 1
ORDER BY ranked_confirmed_freq.months;

-- deaths
WITH death_freq AS (
SELECT 
    DATE_TRUNC('month', t.date) as months, 
    t.deaths, 
    COUNT(t.deaths) AS freq 
FROM (SELECT
    date AS date,
    SUM(deaths) AS deaths
FROM    
    corona
GROUP BY
   date) t
GROUP BY DATE_TRUNC('month', t.date), deaths
),
ranked_death_freq AS (
    SELECT 
        months, 
        deaths, 
        freq, 
        ROW_NUMBER() OVER (PARTITION BY months ORDER BY freq DESC, deaths DESC) AS rank
    FROM death_freq
)
SELECT 
    TO_CHAR(months, 'Month YYYY') AS months, 
    deaths
FROM ranked_death_freq 
WHERE rank = 1
ORDER BY ranked_death_freq.months;

-- recovered cases
WITH recovered_freq AS (
SELECT 
    DATE_TRUNC('month', t.date) as months, 
    t.recovered_cases, 
    COUNT(t.recovered_cases) AS freq 
FROM (SELECT
    date AS date,
    SUM(recovered_cases) AS recovered_cases
FROM    
    corona
GROUP BY
    date) t
GROUP BY DATE_TRUNC('month', t.date), recovered_cases
),
ranked_recovered_freq AS (
    SELECT 
        months, 
        recovered_cases, 
        freq, 
        ROW_NUMBER() OVER (PARTITION BY months ORDER BY freq DESC, recovered_cases DESC) AS rank
    FROM recovered_freq
)
SELECT 
    TO_CHAR(months, 'Month YYYY') AS months, 
    recovered_cases
FROM ranked_recovered_freq 
WHERE rank = 1
ORDER BY ranked_recovered_freq.months;


-- Q8. Find minimum values for confirmed, deaths, recovered per year
SELECT 
    TO_CHAR(DATE_TRUNC('year', t.date), 'YYYY') AS years, 
    MIN(t.total_confirmed_cases) AS minimum_confirmed_cases,
    MIN(t.total_deaths) AS minimum_deaths,
    MIN(t.total_recovered_cases) AS minimum_recovered_cases
FROM
(SELECT
    date,
    SUM(confirmed_cases) AS total_confirmed_cases,
    SUM(deaths) AS total_deaths,
    SUM(recovered_cases) AS total_recovered_cases
FROM
    corona
GROUP BY
    date) t
GROUP BY years;


-- Q9. Find maximum values of confirmed, deaths, recovered per year
SELECT 
    TO_CHAR(DATE_TRUNC('year', t.date), 'YYYY') AS years, 
    MAX(t.total_confirmed_cases) AS maximum_confirmed_cases,
    MAX(t.total_deaths) AS maximum_deaths,
    MAX(t.total_recovered_cases) AS maximum_recovered_cases
FROM
(SELECT
    date,
    SUM(confirmed_cases) AS total_confirmed_cases,
    SUM(deaths) AS total_deaths,
    SUM(recovered_cases) AS total_recovered_cases
FROM
    corona
GROUP BY
    date) t
GROUP BY years;


-- Q10. The total number of case of confirmed, deaths, recovered each month
SELECT
    TO_CHAR(DATE_TRUNC('month', date), 'Month YYYY') AS months,
    SUM(confirmed_cases) AS total_confirmed_cases,
    SUM(deaths) AS total_deaths,
    SUM(recovered_cases) AS total_recovered_cases
FROM 
    corona
GROUP BY
    DATE_TRUNC('month', date)
ORDER BY
    DATE_TRUNC('month', date);


-- Q11. Check how corona virus spread out with respect to confirmed case
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT 
    sum(t.total_confirmed_cases) AS total_confirmed_cases,
    ROUND(AVG(t.total_confirmed_cases), 2) AS average, 
    ROUND(VARIANCE(t.total_confirmed_cases), 2) AS variance, 
    ROUND(STDDEV(t.total_confirmed_cases), 2) AS standard_deviation
FROM 
(SELECT
    date,
    SUM(confirmed_cases) AS total_confirmed_cases
FROM
    corona
GROUP BY
    date) t;

-- Q12. Check how corona virus spread out with respect to death case per month
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT
    TO_CHAR(DATE_TRUNC('month', t.date), 'Month YYYY') AS months,
    sum(t.total_deaths) AS total_deaths,
    ROUND(AVG(t.total_deaths), 2) AS average, 
    ROUND(VARIANCE(t.total_deaths), 2) AS variance, 
    ROUND(STDDEV(t.total_deaths), 2) AS standard_deviation
FROM 
(SELECT
    date AS date,
    SUM(deaths) AS total_deaths
FROM
    corona
GROUP BY
    date) t
GROUP BY
    DATE_TRUNC('month', t.date)
ORDER BY
    DATE_TRUNC('month', t.date);


-- Q13. Check how corona virus spread out with respect to recovered case
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT 
    sum(t.total_recovered_cases) AS total_recovered_cases,
    ROUND(AVG(t.total_recovered_cases), 2) AS average, 
    ROUND(VARIANCE(t.total_recovered_cases), 2) AS variance, 
    ROUND(STDDEV(t.total_recovered_cases), 2) AS standard_deviation
FROM 
(SELECT
    date,
    SUM(recovered_cases) AS total_recovered_cases
FROM
    corona
GROUP BY
    date) t;


-- Q14. Find Country having highest number of the Confirmed case
SELECT 
    country_or_region, sum(confirmed_cases) AS highest_confirmed_cases
FROM 
    corona 
GROUP BY 
    country_or_region 
ORDER BY 
    highest_confirmed_cases DESC
FETCH FIRST ROW ONLY;

-- Q15. Find Country having lowest number of the death case
SELECT 
    country_or_region, sum(deaths) AS lowest_deaths
FROM 
    corona 
GROUP BY 
    country_or_region 
ORDER BY 
    lowest_deaths
FETCH FIRST ROW ONLY;


-- Q16. Find top 5 countries having highest recovered case
SELECT 
    country_or_region, sum(recovered_cases) AS highest_recovered_cases
FROM 
    corona 
GROUP BY 
    country_or_region 
ORDER BY 
    highest_recovered_cases DESC
FETCH FIRST 5 ROWS ONLY;