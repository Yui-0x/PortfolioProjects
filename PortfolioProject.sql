SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Total Cases vs. Total Deaths

SELECT location, date, total_cases, total_deaths,
(CONVERT (float, total_deaths) / NULLIF(CONVERT (float, total_cases), 0 )) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location='Philippines'
ORDER BY 1, 2

-- Shows What Percentage of Population got Covid

SELECT location, date, population, total_cases, 
(CONVERT (float, total_cases) / NULLIF(CONVERT (float, population), 0 )) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location='Philippines'
ORDER BY 1, 2

-- Looking at Countries with Highest Infection Rate Compared to Population

SELECT location, population, MAX (total_cases) as HighestInfectionCount, 
MAX ((CONVERT (float, total_cases) / NULLIF(CONVERT (float, population), 0 ))) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location='Philippines'
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location='Philippines'
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC

-- Break Down by Continent

SELECT location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location='Philippines'
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing the Continents with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location='Philippines'
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global Numbers

SELECT  SUM (new_cases) as total_cases, SUM (CAST(new_deaths as int)) as total_deaths,
--SUM (cast (new_deaths as int)) / SUM (new_cases) * 100 AS DeathPercentage
SUM (new_deaths) / NULLIF(  SUM (new_cases), 0) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location='Philippines'
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1, 2

-- Grouped by Date

SELECT date, SUM (new_cases) as total_cases, SUM (CAST(new_deaths as int)) as total_deaths,
--SUM (cast (new_deaths as int)) / SUM (new_cases) * 100 AS DeathPercentage
SUM (new_deaths) / NULLIF(  SUM (new_cases), 0) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location='Philippines'
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1, 2

-- Covid Vaccination

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CAST (vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 1,2,3

-- CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CAST (vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 1,2,3
)
SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PopvsVac

--Creating View to Store Data for Later Visualizations

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CAST (vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 1,2,3

SELECT *
FROM PercentPopulationVaccinated