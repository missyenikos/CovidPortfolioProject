 -- CREAT DATABASE FOR THE DATA
DROP DATABASE IF EXISTS `covid`;
CREATE DATABASE `covid`;
USE covid;
 
 -- CHECK TABLES ON THE DATABASE THAT JUST BEEN CREATED
SELECT *
FROM covid_death
WHERE continent IS NOT NULL;  -- PREVIOUSLY IT IS AN EMPTY STRING, SO WHEN WE TYPED IS NOT NULL, STILL SHOWING THE EMPTY ROWS

SELECT *
FROM covid_vaccine
WHERE continent IS NOT NULL;

UPDATE covid_death
SET continent = NULL
WHERE continent = '';

-- Looking at Total Cases to Total Death
-- Shows likelihood of dying if we contract covid in your country
SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)* 100 AS death_percentage
FROM covid_death
WHERE location = 'Indonesia';

-- Looking at total cases vs population
-- shows percentage of population got covid
SELECT location, date, population,total_cases,(total_cases/population)* 100 AS PercentPopulationAffected
FROM covid_death
where location = 'Indonesia'
ORDER BY PercentPopulationAffected desc;

-- Looking at countries with highest infection rate compared to population
SELECT location, population,max(total_cases) as max_total_cases, 
max((total_cases/ population))*100 HighestPopulationAffected
FROM covid_death
WHERE continent is not null and population >= 250000000
group by location, population
order by HighestPopulationAffected desc;


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing CONTINENT with Highest Death count per population
SELECT  continent,max(total_deaths) as TotalDeaths 
FROM covid_death
where continent is not null 
group by continent
ORDER BY TotalDeaths DESC ;


-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From covid_death
-- Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2;

--------------------------

-- Total Population vs Vaccinations

-- FURTHER INFORMATION CAN BE OBTAINED BY JOINING TABLES
 SELECT * 
 FROM covid_death dea
 JOIN covid_vaccine vac
 ON dea.location = vac.location 
	and dea.date = vac.date;
    

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (partition by location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM covid_death dea 
JOIN covid_vaccine vac ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

- TOTAL POPULATION THAT HAS BEEN VACCINATED IN COMPARISON TO THE WORLD POPULATION
-- APPLYING CTE AND PARTITION BY 
WITH PopvsVac (Continent, location, date,population, new_vaccination, RollingPeopleVaccinated) as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (partition by location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM covid_death dea 
JOIN covid_vaccine vac ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null)
SELECT *, (RollingPeopleVaccinated/population) *100 FROM PopvsVac;
USE covid;


-- UTILISING TEMP TABLE;

DROP TABLE IF EXISTS 'PercentPopulationVaccinated';
CREATE TEMPORARY TABLE PercentPopulationVaccinated(
continent VARCHAR(200),
location VARCHAR (200),
date DATE,
population BIGINT,
new_vaccination int,
RollingPeopleVaccinate BIGINT
);
INSERT INTO PercentPopulationVaccinated (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (partition by location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM covid_death dea 
JOIN covid_vaccine vac ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
);

SELECT * FROM percentpopulationvaccinated;


-- Creating View to store data for later visualizations

CREATE VIEW percentpopulationvaccinated AS 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (partition by location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM covid_death dea 
JOIN covid_vaccine vac ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null)

