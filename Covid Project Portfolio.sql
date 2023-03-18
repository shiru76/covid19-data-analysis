-- Covid Deaths
SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Total Cases vs Total Deaths
-- Likelihood of dying if you contract covid in your country
SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	(cast(total_deaths as float)/cast(total_cases as float))*100 AS DeathPercentage
FROM 
	PortfolioProject..CovidDeaths
WHERE
	location = 'Philippines'
ORDER BY 
	1, 2

-- Total Cases vs Population
-- Percentage of population who got covid
SELECT 
	location, 
	date, 
	population, 
	total_cases, 
	(cast(total_cases as float)/population)*100 AS TotalCasesPercentage
FROM 
	PortfolioProject..CovidDeaths
WHERE
	location = 'Philippines'
ORDER BY 
	1, 2

-- Country with the highest infection rate
SELECT 
	location, 
	population, 
	MAX(cast(total_cases as int)) as InfectionCount, 
	MAX((cast(total_cases as float)/population)*100) AS TotalCasesPercentage
FROM 
	PortfolioProject..CovidDeaths
GROUP BY
	location, population
ORDER BY 
	TotalCasesPercentage DESC

-- Country with the highest covid deaths
SELECT 
	location, 
	MAX(cast(total_deaths as int)) as DeathCount
FROM 
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	location
ORDER BY 
	DeathCount DESC

-- Continent with the highest covid deaths
SELECT 
	continent, 
	MAX(cast(total_deaths as int)) as DeathCount
FROM 
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	continent
ORDER BY 
	DeathCount DESC

--SELECT 
--	location, 
--	MAX(cast(total_deaths as int)) as DeathCount
--FROM 
--	PortfolioProject..CovidDeaths
--WHERE
--	continent IS NULL
--GROUP BY
--	location
--ORDER BY 
--	DeathCount DESC

-- Number of total cases across the world
SELECT 
	location, 
	MAX(cast(total_deaths as int)) as DeathCount
FROM 
	PortfolioProject..CovidDeaths
WHERE
	location = 'world'
GROUP BY
	location
	
-- Number of total cases accross the world per day
SELECT
	date,
	SUM(CAST(new_cases as float)) AS TotalCases,
	SUM(CAST(new_deaths as float)) AS TotalDeaths,
	CASE
		WHEN SUM(CAST(new_cases as float)) = 0
		THEN 0
		ELSE (SUM(CAST(new_deaths as float))/SUM(CAST(new_cases as float)))*100
	END AS DeathPercentage
FROM 
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	date
ORDER BY 
	1, 2

-- Covid Vaccinations
SELECT *
FROM PortfolioProject.dbo.CovidVaccinations

-- Joining two tables
SELECT *
FROM 
	PortfolioProject..CovidDeaths AS cde
JOIN	
	PortfolioProject..CovidVaccinations AS cva
	ON cde.location = cva.location
	AND cde.date = cva.date

-- Total Population vs Vaccinations
SELECT 
	cde.continent, cde.location, cde.date, cde.population, cva.new_vaccinations,
	SUM(CAST(cva.new_vaccinations AS BIGINT)) OVER (PARTITION BY cde.location ORDER BY cde.location, cde.date) AS RollingPeopleVaccinate
FROM 
	PortfolioProject..CovidDeaths AS cde
JOIN	
	PortfolioProject..CovidVaccinations AS cva
	ON cde.location = cva.location
	AND cde.date = cva.date

WHERE
	cde.continent IS NOT NULL
ORDER BY
	cde.location, cde.date

-- CTE
WITH PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
AS
(
	SELECT 
		cde.continent, cde.location, cde.date, cde.population, cva.new_vaccinations,
		SUM(CAST(cva.new_vaccinations AS BIGINT)) OVER (PARTITION BY cde.location ORDER BY cde.location, cde.date) AS RollingPeopleVaccinated
	FROM 
		PortfolioProject..CovidDeaths AS cde
	JOIN	
		PortfolioProject..CovidVaccinations AS cva
		ON cde.location = cva.location
		AND cde.date = cva.date

	WHERE
		cde.continent IS NOT NULL
	--ORDER BY
	--	cde.location, cde.date
)
SELECT 
	*, ((RollingPeopleVaccinated/Population)*100) AS PercentageofPeopleVaccinated
FROM 
	PopvsVac

-- Creating view to store data for visualizations
CREATE VIEW PercentPopulationVaccinated 
AS
SELECT 
		cde.continent, cde.location, cde.date, cde.population, cva.new_vaccinations,
		SUM(CAST(cva.new_vaccinations AS BIGINT)) OVER (PARTITION BY cde.location ORDER BY cde.location, cde.date) AS RollingPeopleVaccinated
FROM 
		PortfolioProject..CovidDeaths AS cde
JOIN	
	PortfolioProject..CovidVaccinations AS cva
	ON cde.location = cva.location
	AND cde.date = cva.date

WHERE
	cde.continent IS NOT NULL		

SELECT *
FROM
	PercentPopulationVaccinated