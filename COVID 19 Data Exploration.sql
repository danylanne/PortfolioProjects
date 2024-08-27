/*
-- Covid 19 Data Exploration --
Skills used: CASE Statement, Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	Continent IS NOT NULL 
ORDER BY
	3,4;


-- Selecting the Data We’ll Begin With
SELECT 
    Location, 
    Date, 
    Total_cases, 
    New_cases, 
    Total_deaths, 
    Population
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    Continent IS NOT NULL 
ORDER BY
	1,2;


-- Total Cases vs Total Deaths
-- Shows the likelihood of dying from COVID in your country
SELECT 
    Location, 
    Date, 
    Total_cases, 
    Total_deaths, 
    CASE 
        WHEN Total_cases = 0 THEN NULL 
        ELSE (Total_deaths * 1.0 / Total_cases) * 100 
    END AS DeathPercentage
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    Location LIKE '%phil%' 
    AND Continent IS NOT NULL
ORDER BY
	1,2;


-- Total Cases vs Population
-- Shows the percentage of the population that is infected with COVID
SELECT 
    Location, 
    Date, 
    Population, 
    Total_cases,
    CASE 
        WHEN CAST(Population AS bigint) = 0 THEN NULL
        ELSE (CAST(Total_cases AS bigint) * 100.0 / CAST(Population AS bigint))
    END AS PercentPopulationInfected
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    Continent IS NOT NULL 
ORDER BY 
	1, 2;


-- Countries with the Highest Infection Rates Relative to Their Population
SELECT 
    Location, 
    Population, 
    MAX(CAST(Total_cases AS bigint)) AS HighestInfectionCount, 
	CASE
		WHEN CAST(Population as bigint) = 0 THEN NULL
		ELSE (MAX(CAST(Total_cases AS bigint)) * 1.0 / CAST(Population AS bigint)) * 100 
	END AS PercentPopulationInfected
FROM 
    PortfolioProject..CovidDeaths
GROUP BY 
    Location, 
    Population
ORDER BY 
    PercentPopulationInfected DESC;


-- Countries with Highest Death Count per Population
SELECT
	Location,
	MAX(Total_deaths) AS TotalDeathCount
FROM
	PortfolioProject..CovidDeaths
WHERE
	Continent IS NOT NULL
GROUP BY
	Location
ORDER BY 
	TotalDeathCount DESC;


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
SELECT
	Continent,
	MAX(Total_deaths) AS TotalDeathCount
FROM 
	PortfolioProject..CovidDeaths
WHERE
	Continent IS NOT NULL
GROUP BY
	Continent
ORDER BY 
	TotalDeathCount DESC;


-- GLOBAL NUMBERS
SELECT
	SUM(CAST(New_cases AS bigint)) AS Total_Cases,
	SUM(CAST(New_deaths AS bigint)) AS Total_Deaths,
	CASE
	    WHEN SUM(CAST(New_cases AS bigint)) = 0 THEN NULL
        ELSE (SUM(CAST(New_deaths AS bigint)) * 1.0 / SUM(CAST(New_cases AS bigint))) * 100 
	END AS Death_Percentage
FROM
	PortfolioProject..CovidDeaths
WHERE
	Continent IS NOT NULL;


-- Total Population vs Vaccinations
-- Shows Rolling Total per location that has received Covid vaccine
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) 
		OVER (PARTITION BY dea.location 
			  ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
FROM
	PortfolioProject..CovidDeaths dea
JOIN
	PortfolioProject..CovidVaccinations vac
	ON 
		dea.location =vac.location
		AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
ORDER BY
	2,3;
		

-- Using CTE to show Percentage of Population that has received Covid Vaccine
WITH 
	PopVsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
	SELECT
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(bigint,vac.new_vaccinations)) 
			OVER (PARTITION BY dea.location 
				  ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
	FROM
		PortfolioProject..CovidDeaths dea
	JOIN
		PortfolioProject..CovidVaccinations vac
	ON 
		dea.location =vac.location
		AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
)
SELECT *,
    CASE
        WHEN CAST(Population as bigint) = 0 THEN NULL
        ELSE (RollingPeopleVaccinated * 1.0 / Population) * 100
    END AS PercentPopulationVaccinated
FROM 
	PopVsVac;


-- TEMP Table
DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date varchar(50),
	Population bigint,
	New_vaccinations bigint,
	RollingPeopleVaccinated bigint
);

INSERT INTO #PercentPopulationVaccinated
SELECT
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(bigint,vac.new_vaccinations)) 
			OVER (PARTITION BY dea.location 
				  ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
	FROM
		PortfolioProject..CovidDeaths dea
	JOIN
		PortfolioProject..CovidVaccinations vac
	ON 
		dea.location =vac.location
		AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL

SELECT *
FROM 
	#PercentPopulationVaccinated;


-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(bigint,vac.new_vaccinations)) 
			OVER (PARTITION BY dea.location 
				  ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
	FROM
		PortfolioProject..CovidDeaths dea
	JOIN
		PortfolioProject..CovidVaccinations vac
	ON 
		dea.location =vac.location
		AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated;