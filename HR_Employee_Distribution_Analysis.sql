-- Data Cleaning
SELECT * FROM hr;

-- Renaming Column
ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

-- Stadardizing Dates
DESCRIBE hr;

SELECT birthdate 
FROM hr;

UPDATE hr
SET birthdate = CASE 
	WHEN birthdate LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

SELECT hire_date 
FROM hr;

UPDATE hr
SET hire_date = CASE 
	WHEN hire_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

SELECT termdate 
FROM hr;

UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE TRUE;

SET sql_mode = 'ALLOW_INVALID_DATES';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

--  Creating age column
ALTER TABLE hr
ADD COLUMN age INT;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT birthdate, age 
FROM hr;

SELECT min(age) AS youngest, max(age) AS oldest
FROM hr;

SELECT count(*) 
FROM hr 
WHERE age < 18;


-- Analysis

-- gender breakdown of employees
SELECT gender, count(*) AS count 
FROM hr
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY gender;


-- race/ethnicity breakdown of employees 
SELECT race, count(*) AS count
FROM hr
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY race
ORDER BY count(*) DESC;


-- age distribution of employees 
SELECT min(age) AS youngest, max(age) AS oldest
FROM hr
WHERE age >=18 AND termdate = '0000-00-00';

SELECT 
	CASE
		WHEN age >= 18 AND age <= 24 THEN '18-24'
        WHEN age >= 25 AND age <= 34 THEN '25-34'
        WHEN age >= 35 AND age <= 44 THEN '35-44'
        WHEN age >= 45 AND age <= 54 THEN '45-54'
        WHEN age >= 55 AND age <= 64 THEN '55-64'
        ELSE '65+'
	END AS age_group,
    count(*) AS count
FROM hr
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY age_group
ORDER BY age_group;


SELECT 
	CASE
		WHEN age >= 18 AND age <= 24 THEN '18-24'
        WHEN age >= 25 AND age <= 34 THEN '25-34'
        WHEN age >= 35 AND age <= 44 THEN '35-44'
        WHEN age >= 45 AND age <= 54 THEN '45-54'
        WHEN age >= 55 AND age <= 64 THEN '55-64'
        ELSE '65+'
	END AS age_group,
    gender,
    count(*) AS count
FROM hr
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY age_group, gender
ORDER BY age_group, gender;


-- employees work at headquarters versus remote locations
SELECT location, count(*) 
FROM hr
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY location;


-- average length of employment for employees who have been terminated
SELECT round(avg(datediff(termdate, hire_date))/365,2) AS avg_length_employment
FROM hr
WHERE termdate <= curdate() AND termdate <> '0000-00-00' AND age >= 18;


-- gender distribution across departments and job titles
SELECT department, gender, count(*) AS count 
FROM hr
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY department, gender
ORDER BY department;


-- distribution of job titles
SELECT jobtitle, count(*) AS count 
FROM hr
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle;


-- department with the highest turnover rate
SELECT department, 
	total_count, 
    terminated_count, 
	terminated_count/total_count AS termination_rate
FROM (
	SELECT department, 
		count(*) AS total_count,
        SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
	FROM hr
	WHERE age >=18
    GROUP BY department
    ) AS  subquery
ORDER BY termination_rate DESC;


-- distribution of employees across locations by city and state
SELECT location_state, count(*) AS count
FROM hr
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY location_state
ORDER BY count DESC;


-- company's employee count changed over time based on hire and term dates
SELECT year,
    hires,
    terminations,
    hires - terminations AS net_change,
    round((hires - terminations)/hires * 100,2) AS net_change_percent
FROM (
	SELECT year(hire_date) AS year,
		count(*) AS hires,
        SUM(CASE WHEN termdate<> '0000-00-00' and termdate <= curdate() THEN 1 ELSE 0 END) AS terminations
	FROM hr
    WHERE age >=18 
    GROUP BY year(hire_date)
    ) AS subquery
ORDER BY year ASC;


-- tenure distribution for each department
SELECT department, round(avg(datediff(termdate, hire_date)/365),2) AS acg_tenure 
FROM hr
WHERE age >=18 AND termdate <= curdate() AND termdate <> '0000-00-00'
GROUP BY department;

