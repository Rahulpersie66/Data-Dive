-- EDA
-- Exploratory DATA ANALYSIS
SELECT * FROM layoffs_stagging2;

-- WHILE EDA --
-- You always have SOME IDEA what you are looking for
-- And sometimes you also have to CLEAN THE DATA AGAIN for EXPLOARTORY.
-- Sometime you have to CLEAN it and EXPLORE it at SAME TIME


-- DOnt have any particular AGENDA but will LOOK for EVERYTHING hwhile Exploratory.
-- We will start with basics

-- We will be working with `total_laid_off` and somewhat 'percenatge_laid_off' but we dont know how much large company is so %_laid_off little less use
SELECT MAX(total_laid_off) FROM layoffs_stagging2;
-- So it means one day total laid_off was 12000

SELECT MAX(total_laid_off), MAX(percentage_laid_off) FROM layoffs_stagging2;
-- so '1' means 100% of employee that one copmany was fully laid off on one day--> thats not great for a Company

-- NOW try to find the company with %laid_off as 1
SELECT *  FROM layoffs_stagging2
WHERE percentage_laid_off = 1;
-- So these are ALL COMPANIES WHOSE ALL EMPLOYREES were LAID off--> SO Copmany went in MAJOR LOSS.--> DISASTER

-- we can order also order by total_laid_off count
SELECT *  FROM layoffs_stagging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;


-- We can also look at %_laid off --> all employee laid off an company raise fund from max to min
SELECT *  FROM layoffs_stagging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Now GROUP by company and SUM of all laid_off according to company _name--> it will give trend which company laid of fmax eployee until
SELECT company, SUM(total_laid_off) 
FROM layoffs_stagging2
GROUP BY company
ORDER BY 2 DESC;

-- FIND the `date` for which data we are looking about -- so MIN(date) and MAX(date)
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_stagging2;

-- We can also find the which `industry` was HIT MOST laid_off
SELECT industry, SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY industry
ORDER BY 2 DESC;
-- so `consumer` induistry is HIT by most LAID OFF 
-- that MAKES sense as COVID approaches so SHOPS getting close and CONSUMER and RETAIL getting LAID off -- we r making assumptions  


-- Now lets find out the COUNTRY with MOST LAID off in these 3 years
SELECT country, SUM(total_laid_off) 
FROM layoffs_stagging2
GROUP BY country
ORDER BY 2 DESC;
-- We found out that USA is most laid _off meployee and India being second

-- Lets LOOK BY `date` that is which date is MOST LAID off
SELECT `date`, SUM(total_laid_off) 
FROM layoffs_stagging2
GROUP BY `date`
ORDER BY 2 DESC;
-- So 1st april is mos LAID off date .. make sense as FINACIAL YEAR ENDS

-- lets make it YEAR basis --> YEAR(`date`)
SELECT YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_stagging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;
-- It shows taht 2022 has MOST LAID off and TREND is much WORSE than previous year 2021 and 2023 it sdecreasing so may be symbol that MARKET is RECOVERING.


-- We can do STAGE group by to find out at WHICH STAGE of the company was HIGHEST LAID_OFF
SELECT stage, SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY stage
ORDER BY 1 DESC;
-- SO we found at POSTIPOi.e AMAZON,google world largest Companies that are INTIAL pUblic offerings stage was the MOST HIGHEST LAID OFF



-- Lets look at %_laid_off, but dont think % is good option as we dont know HARD NUMBERS and how LARGE is the company.
SELECT company, SUM(percentage_laid_off) 
FROM layoffs_stagging2
GROUP BY company
ORDER BY 2 DESC;
-- Sum of percentage is not of ANY USE, as we dont have HARD NUMBER total number of person in company so % laid_off is irrelevant here.

-- SO we try to look at AVG
SELECT company, AVG(percentage_laid_off) 
FROM layoffs_stagging2
GROUP BY company
ORDER BY 2 DESC;
-- But it Turns out it also is not that much irrelvant, after looking value of AVG as 1 for most columns

-- SO lets look at PROGRESSION (rolling sum) of the layoff-- so we called as ROLLING sum starting from a date and until the very end
SELECT SUBSTRING(`date`,6,2) AS `Month`
FROM layoffs_stagging2;
-- it will give `MONTH` from the layoffs_stagging2
-- so now caluclate the ROLLLING SUM for each month 
SELECT SUBSTRING(`date`,6,2) AS `Month`,
SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY `Month`
ORDER BY 1 ASC;
 -- will give 01 month JAN total_laid_off SUM which will be FROM jan 0202, jan2021, jan2022, jan2023,--> all sum together in 1 column
 -- but we want EACH MONTH of EACH YEAR Rolling SUM
 -- so change the SUBSTRING(`date`, 1, 7) it will take `date` as 2023-01 , 2023-02 so each yaer each month is spearted now
SELECT SUBSTRING(`date`,1,7) AS `Month`,
SUM(total_laid_off)
FROM layoffs_stagging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC;
-- this will give much more relevant output but we need rolling sum , so we have to use WINDOW function
-- WHERE `month` will not work as it is defined LATER so we have to use here `SUBSTRING(`date`,1,7)`
 
 -- So we can do is use OVER(partition by month and sum
 SELECT SUBSTRING(`date`,1,7) AS `Month`,
SUM(total_laid_off)  OVER( PARTITION BY SUBSTRING(`date`,1,7)) 
FROM layoffs_stagging2
ORDER BY 1 ASC;
-- We didnot use IVER by direct as ith PARTITION BY SUBSTRING(`date`,1,7) it will RETURN DUPLICATE ENTRIES but SAME ROW AS GROUP BY
-- so either we can do is DISTINCT ROW after saving above in CTE OR can do GROUP BY first and save in CTE and then OVER BY

-- 1st by DISTICT 
WITH rolling_total_distinct AS(
SELECT SUBSTRING(`date`,1,7) AS `Month`,
SUM(total_laid_off)  OVER( PARTITION BY SUBSTRING(`date`,1,7) ORDER BY SUBSTRING(`date`,1,7))  As rolling_total
FROM layoffs_stagging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
ORDER BY 1 ASC
)
SELECT 
DISTINCT(`Month`), rolling_total
FROM rolling_total_distinct;
-- it DIDNOT worked as EXPECTED

-- So try ANOTHER WAY -- by using GROU BY first save in CTE then OVER(ORDER BY) to get ROLLING TOTAL
 WITH CTE_rolling_total AS(
 SELECT SUBSTRING(`date`,1,7) AS `Month`,
SUM(total_laid_off) AS total_off
FROM layoffs_stagging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC
)
SELECT 
`Month`,
total_off,
SUM(total_off) OVER(ORDER BY `Month`) AS rolling_total
FROM CTE_rolling_total;

-- So we can see that from 2020-03 to 2020-12 we have 80998 people laid off
-- and fo 2021 we lost 96851 as rolling sum so that means total job lost was 96851-80998 = 16000 job only, laid off very low compared to last year
-- and in 2022 rolling total was 257000 that means around 150000 lost the job and out of them also NOv 11-2022 has the highest laid off that year i.e 53451
-- these were reported data only
-- there was 383159 laid off from 03-2020 to 03-2022
-- and alos we can break this output by COUNTRY and can see how many per country has been laid off during thius time.
-- ROLLING TOtal are great for ANALZE and VISUALIZATION

-- now lets see in term of country per year laid off the employee
SELECT company,
YEAR(`date`),
SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;
-- this will  give company and their laid off PER YEAR in DESC order of LAID OFF

-- now we want to rank these companies that HIGHEST LAID OFF
-- so we can use RANK() ORDER()
WITH rank_company_laid_off AS(
SELECT company,
YEAR(`date`) AS `year`,
SUM(total_laid_off) AS total_laid_off_by_company
FROM layoffs_stagging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
)
SELECT company, `year`, total_laid_off_by_company,
RANK() OVER(ORDER BY total_laid_off_by_company DESC) AS `rank`
FROM rank_company_laid_off;
-- it is showing GOOGLE is number #1 in laying off people in year 2023 has highest LIAD OFF
-- it is shownh any laid ooff by COMPANY in ANY YEAR OVERALL

-- USECASE::
-- For COMPANY TOTAL_LAID_OFF per YEAR highest in EVERY YEAR is given by
WITH rank_company_laid_off_per_year AS(
SELECT company,
YEAR(`date`) AS `year`,
SUM(total_laid_off) AS total_laid_off_by_company
FROM layoffs_stagging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
)
SELECT company, `year`, total_laid_off_by_company,
RANK() OVER(PARTITION BY `year` ORDER BY total_laid_off_by_company DESC) AS `rank`
FROM rank_company_laid_off_per_year
WHERE `year` IS NOT NULL
ORDER BY 2 ASC;
-- RANK will skip the rank on same level

-- ALL 2020 will be in ONE partition, all 2021 will be in one partition and same for 2022 and 2023 if we partition BY `year`
-- DENSE_RANK() will NOT SKIP the rank so we can use them to PARTITION BY year as in partition 2020 everything will be from rank 1 to os on....
-- then in 2021 it will again rank from 1 to so on... and then in 2022 it will again rank from 1 to so on ... and again in 2023 from rank 1 and 
-- so on and it goe sfor that partition 
WITH rank_company_laid_off_per_year AS(
SELECT company,
YEAR(`date`) AS `year`,
SUM(total_laid_off) AS total_laid_off_by_company
FROM layoffs_stagging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
)
SELECT company, `year`, total_laid_off_by_company,
DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_laid_off_by_company DESC) AS `ranking`
FROM rank_company_laid_off_per_year
WHERE `year` IS NOT NULL
ORDER BY 2 ASC;
-- DENSE _rank will assign a SAME RANK on SAME VALUE and DON'T SKIP the VALUE


--- USE CASE:: -- We want TOP 5 COMPANIES per YEAR that laid off highest 

-- Below is MY WAY
WITH rank_company_laid_off_per_year AS(
SELECT company,
YEAR(`date`) AS `year`,
SUM(total_laid_off) AS total_laid_off_by_company
FROM layoffs_stagging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
)
SELECT company, `year`, total_laid_off_by_company,
RANK() OVER(PARTITION BY `year` ORDER BY total_laid_off_by_company DESC) AS `rank`
FROM rank_company_laid_off_per_year
WHERE `year` IS NOT NULL
ORDER BY 4 ASC
LIMIT 1, 20;


-- ANOTHER WAY To  create this
WITH Company_Year(company, years, total_liad_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY company, years
)
SELECT * FROM Company_Year;
-- Foe here `years` will not work AS it is NOT DEFINED YET and it is define in WITH CTE(`years`) so it can't detect that

WITH Company_Year(company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY company, YEAR(`date`)
)
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
;

-- now GIVE ME TOP 5 companies per YEAR that were HIGHEST LAID OFF
WITH Company_Year(company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY company, YEAR(`date`)
),
Company_Year_Rank AS(
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT * 
FROM Company_Year_Rank
WHERE Ranking <= 5;

-- First CTE to SUM( total_laid_off) and  GROUP BY company, year(date)
-- Second CTE to RANK it by and STORE in CTE i.e RANKING in partition 2020 from 1 and so on and same for partition 2021  from 1 to so on and same for 2022 from 1 and so on..
-- THEN a SELCT statement with WHERE RANKING <= 5.. will give top 5 companies. 