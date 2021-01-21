/*1) What country (or countries) has more confirmed cases in total?*/

WITH sums AS(
             SELECT country, state, MAX(ncases) as maximo
             FROM cases
             GROUP by country, state
             ORDER BY 1
             )
SELECT country, SUM(maximo)as somas
FROM sums
GROUP by country
Having SUM(maximo) in (SELECT SUM(maximo) FROM sums GROUP BY country ORDER BY 1 DESC LIMIT 1)


/*2) What country (or countries) has more confirmed cases per 100k people?*/

WITH sums AS(
             SELECT cases.country, state, MAX(ncases) as maximo, pop.population 
             FROM cases left join pop on cases.country = pop.country
             GROUP by cases.country, state, pop.population
             ORDER BY 1
             )
SELECT country,population, SUM(maximo)as maxCasos, round(SUM(maximo)*100000/population,2) as CasesPer100k
FROM sums
GROUP by country, population
Having SUM(maximo)*100000/population in (SELECT SUM(maximo)*100000/population FROM sums GROUP BY country, population ORDER BY 1 DESC LIMIT 1)


/*3)What are the top 10 countries with more cases reported in the last day?*/

with ultimodia as (
                  SELECT  day,country, state, MAX(ncases) as maximo
                  FROM cases
                  GROUP by day,country, state
                  HAVING day in (SELECT MAX(day) from cases)
                  ORDER BY 4 desc
             ),
penultimodia as (
                 SELECT  day,country, state, MAX(ncases) as maximo
                  FROM cases
                  GROUP by day,country, state
                  HAVING day in (SELECT MAX(day) from cases where day<(select MAX(day) from cases))
                  ORDER BY 4 desc
             )
SELECT  ultimodia.country,SUM(ultimodia.maximo)-SUM(penultimodia.maximo) as LastDayCases
FROM ultimodia INNER JOIN penultimodia ON ultimodia.country = penultimodia.country
GROUP BY ultimodia.country
ORDER BY 2 DESC
LIMIT 10


/*4)  What are the top 10 countries with more cases per 100k people reported in the last day?*/

with ultimodia as (
                  SELECT  day,country, state, MAX(ncases) as maximo
                  FROM cases
                  GROUP by day,country, state
                  HAVING day in (SELECT MAX(day) from cases)
                  ORDER BY 4 desc
             ),
penultimodia as (
                 SELECT  day,country, state, MAX(ncases) as maximo
                  FROM cases
                  GROUP by day,country, state
                  HAVING day in (SELECT MAX(day) from cases where day<(select MAX(day) from cases))
                  ORDER BY 4 desc
             )
SELECT  ultimodia.country, round((SUM(ultimodia.maximo)-SUM(penultimodia.maximo))*100000/population,2) as LastDayPer100k
FROM ultimodia INNER JOIN penultimodia ON ultimodia.country = penultimodia.country
LEFT JOIN pop on ultimodia.country = pop.country
GROUP BY ultimodia.country, population
ORDER BY 2 DESC
LIMIT 10

/* ALL RESULTS IN "questionsResults.txt" FILE */