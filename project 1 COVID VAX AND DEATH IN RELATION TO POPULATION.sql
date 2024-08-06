Select *
from portpro..['coviddeath$']
where continent is not null
order by 3,4

--Select *
--from portpro..['covidvax$']
--order by 3,4
--looking at total cases vs total deaths
select location,date,total_cases,new_cases,total_deaths, (total_deaths/ NULLIF(total_cases, 0))*100 AS death_percentage
from portpro..['coviddeath$']
where location like '%nigeria%'
order by 1,2

--Looking at total cases vs population

select location,date,total_cases,new_cases,population, (NULLIF(total_cases, 0)/population)*100 AS death_percentage
from portpro..['coviddeath$']
where location like '%nigeria%'
order by 1,2

--counting highest infection rate with respect to population
 
SELECT 
  location,
  MAX(new_cases) AS max_new_cases,
  population, 
  MAX ((total_cases / population)) * 100 AS percentage_of_population_infected
FROM 
  portpro..['coviddeath$']
--WHERE 
--  location LIKE '%United states%'
GROUP BY 
  location, population
ORDER BY percentage_of_population_infected desc

--Showing countries with highest death count per population

SELECT 
  location,
  MAX(Cast(total_deaths as int)) AS total_death_count
FROM 
  portpro..['coviddeath$']
--WHERE 
--  location LIKE '%United states%'
where continent is not null
GROUP BY 
  location
ORDER BY total_death_count desc


--Showing Contintent with highest death counts

SELECT 
  continent,
  MAX(Cast(total_deaths as int)) AS total_death_count
FROM 
  portpro..['coviddeath$']
--WHERE 
--  location LIKE '%United states%'
where continent is not null
GROUP BY 
 continent 
ORDER BY total_death_count desc


--Global
SELECT 
  date,
  SUM(new_cases) AS total_cases, 
  SUM(new_deaths) AS total_deaths, 
  (SUM(new_deaths) / NULLIF(SUM(new_cases), 0)) * 100 AS death_rate_percentage
FROM 
  portpro..['coviddeath$']
--WHERE location LIKE '%nigeria%'
--WHERE continent IS NOT NULL
GROUP BY 
  date
ORDER BY 
  date, total_cases;


select*
from portpro..['coviddeath$'] dea
join portpro..['covidvax$'] vac
on dea. location=vac.location
and dea.date=vac.date


--looking at total population vs vaccination

SELECT 
  dea.continent, 
  dea.location, 
  dea.population, 
  dea.date, 
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated

FROM 
  portpro..['coviddeath$'] dea
JOIN 
  portpro..['covidvax$'] vac
ON 
  dea.location = vac.location
AND 
  dea.date = vac.date
WHERE 
  dea.continent IS NOT NULL
ORDER BY 
  2,3

  --use a CTE
  WITH popvsvax AS
(
  SELECT 
    dea.continent, 
    dea.location, 
    dea.population, 
    dea.date, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
  FROM 
    portpro..['coviddeath$'] dea
  JOIN 
    portpro..['covidvax$'] vac
  ON 
    dea.location = vac.location
  AND 
    dea.date = vac.date
  WHERE 
    dea.continent IS NOT NULL
)
SELECT 
  *, 
  (CAST(rolling_people_vaccinated AS float) / CAST(population AS float)) * 100 AS vaccination_rate_percentage
FROM 
  popvsvax
ORDER BY 
  location, date;

--TEMP TABLE

-- Create the temporary table
CREATE TABLE #percentpopulationvaccinated
(
  continent NVARCHAR(255),
  location NVARCHAR(255),
  date DATETIME,
  population float,
  new_vaccinations NVARCHAR(255),  
  rolling_people_vaccinated NUMERIC
);

-- Insert data into the temporary table
INSERT INTO #percentpopulationvaccinated
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  CAST(dea.population AS NUMERIC), 
  CAST(vac.new_vaccinations AS NUMERIC),
  SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM 
  portpro..['coviddeath$'] dea
JOIN 
  portpro..['covidvax$'] vac
ON 
  dea.location = vac.location
AND 
  dea.date = vac.date
WHERE 
  dea.continent IS NOT NULL;

-- Select data from the temporary table and calculate the vaccination rate percentage
SELECT 
  *, 
  (CAST(rolling_people_vaccinated AS FLOAT) / CAST(population AS FLOAT)) * 100 AS vaccination_rate_percentage
FROM 
  #percentpopulationvaccinated
ORDER BY 
  location, date;


CREATE VIEW percentagepopulationvaccinated AS
SELECT 
  dea.continent, 
  dea.location, 
  dea.population, 
  dea.date, 
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS bigint)) 
    OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM 
  portpro..['coviddeath$'] dea
JOIN 
  portpro..['covidvax$'] vac
ON 
  dea.location = vac.location
  AND dea.date = vac.date
WHERE 
  dea.continent IS NOT NULL;;

  SELECT * FROM sys.objects WHERE name = 'percentagepopulationvaccinated';
  SELECT * FROM percentagepopulationvaccinated;

