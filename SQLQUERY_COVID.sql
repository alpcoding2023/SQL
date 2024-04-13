--SELECT * 
--FROM PortfolioProject1..CovidDeaths
--WHERE continent is NOT NULL
--ORDER by 3,4

--SELECT *
--FROM PortfolioProject1..CovidVaccinations
--ORDER by 3,4

-- Select Data to be used

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject1..CovidDeaths
ORDER by 1,2

--Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE '%States%'
ORDER by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 as CasePerCentage
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE '%States%'
ORDER by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HishestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
Group by location, population
ORDER by PercentPopulationInfected DESC

-- Let's break things down by Continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is NOT NULL
Group by continent
ORDER by TotalDeathCount DESC


SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is  NULL
Group by location
ORDER by TotalDeathCount DESC

--- Showing countries with Highest Death Rate per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is NOT NULL
Group by location
ORDER by TotalDeathCount DESC


-- GLOBAL NUMBERS
-- using agregate functions

SELECT  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER by 1,2


SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent is not NULL
--GROUP BY date
ORDER by 1,2

-- JOINING 2 tables
-- To look at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths as dea
JOIN PortfolioProject1..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

-- USING CTE TO aggregaite 


WITH PopVsVac (continent, locate, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths as dea
JOIN PortfolioProject1..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL

)

Select *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac

-- USING TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Conttinent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths as dea
JOIN PortfolioProject1..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PercentPopulationVaccinated as 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths as dea
JOIN PortfolioProject1..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL

