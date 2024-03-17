
/*
COVID 19 Data Exploration
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


SELECT *
FROM PortfolioProject..CovidDeaths


-- Selecting data that will be used
SELECT location, date, population, total_cases, total_deaths
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2


-- Total deaths vs total cases in Ireland
-- Shows the percentage of deaths for a particular country if COVID was encountered
SELECT location, date, population, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as percentage_deaths 
FROM PortfolioProject..CovidDeaths
WHERE location like 'Ireland'
ORDER BY date


-- Total deaths vs total cases in United States
SELECT location, date, population, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as percentage_deaths 
FROM PortfolioProject..CovidDeaths
WHERE location like '%States%'
ORDER BY date


-- Total cases vs population
-- Shows the percentage of population infected with COVID
SELECT location, date, population, total_cases, total_deaths, ROUND((total_cases/population)*100,2) as percentage_infected 
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2 


--Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as highestinfectioncount, ROUND(MAX((total_cases/population)*100),2) as percentage_infected 
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC 


--Countries with highest death count
SELECT location, MAX(Cast(total_deaths as int)) as highestdeathcount 
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY 2 DESC


-- Breaking things down by continent
-- Showcasing continents with highest death count
SELECT continent, MAX(CAST(total_deaths as int)) as highestdeathcount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY 2 DESC


--Global Numbers
SELECT date, SUM(new_cases) as totalcases, SUM(CAST(new_deaths as int)) as totaldeaths, SUM(CAST(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2


SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY location,date


-- Vaccinations administered in a country on monthly basis
SELECT continent, location, SUM(CAST(new_vaccinations as int)) as totalvaccination, year(date) as Year, month(date) as Month
FROM PortfolioProject..CovidVaccinations
WHERE new_vaccinations is not NULL
AND continent is not NULL
GROUP BY continent, location, year(date), month(date)
ORDER BY 4, 5, 2


-- Total population vs Vaccinations
-- Shows percentage of population that has recieved at least one COVID vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinationcount
FROM PortfolioProject..CovidVaccinations as vac
FULL JOIN PortfolioProject..CovidDeaths as dea
	ON vac.location = dea.location
	AND vac.date = dea.date
WHERE dea.continent is not NULL
ORDER BY 2,3


--CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinationcount)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinationcount
FROM PortfolioProject..CovidVaccinations as vac
FULL JOIN PortfolioProject..CovidDeaths as dea
	ON vac.location = dea.location
	AND vac.date = dea.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)
Select *, (RollingVaccinationcount/population)*100 as Percentagepopvaccinated
FROM PopvsVac


-- TEMP TABLE
DROP TABLE if exists PercentagePopulationVaccinated

Create Table PercentagePopulationvaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationcount numeric
)

Insert into PercentagePopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinationcount
FROM PortfolioProject..CovidVaccinations as vac
FULL JOIN PortfolioProject..CovidDeaths as dea
	ON vac.location = dea.location
	AND vac.date = dea.date
--WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *, (RollingVaccinationcount/population)*100 as Percentagepopvaccinated
FROM PercentagePopulationvaccinated


-- Creating view to store data for later visualizatoin
Use PortfolioProject
CREATE VIEW PercentagePopulationvac as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinationcount
FROM PortfolioProject..CovidVaccinations as vac
FULL JOIN PortfolioProject..CovidDeaths as dea
	ON vac.location = dea.location
	AND vac.date = dea.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *
FROM PercentagePopulationvac

