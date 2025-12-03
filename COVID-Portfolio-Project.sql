SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- SELECT *
-- FROM CovidVaccinations
-- ORDER BY 3,4;

-- Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2;

-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS FLOAT) / total_cases * 100 AS death_percentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

-- Looking at the total cases vs the population
-- Shows what percentage of population got covid
SELECT location, date, total_cases, population, CAST(total_cases AS FLOAT) / population * 100 AS percent_population_infected
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as highest_infection_count, MAX(CAST(total_cases AS FLOAT) / population) * 100 AS percent_population_infected
FROM CovidDeaths
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- Showing the countries with the highest death count per population
SELECT location, MAX(total_deaths) as total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;


-- LETS BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count per population
SELECT continent, MAX(total_deaths) as total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

-- GLOBAL NUMBERS

-- Percentage of deaths in the entire world
SELECT SUM(new_cases)  as total_cases, SUM(new_deaths) as total_deaths, SUM(CAST(new_deaths AS float))/SUM(new_cases) * 100 AS death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at total population vs vaccinations
-- USING CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, cummulative_vaccinations)
AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cummulative_vaccinations
    FROM CovidDeaths dea
    JOIN CovidVaccinations vac 
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (cummulative_vaccinations / population) * 100 
FROM PopvsVac;

-- TEMP TABLE
 CREATE TABLE #PercentPopulationVaccinated (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME, 
    population INT,
    new_vaccinations INT, 
    cummulative_vaccinations INT;
 )
 INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cummulative_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (cummulative_vaccinations / population) * 100 
FROM #PercentPopulationVaccinated;

-- Creating view to store data for later visualizations

-- CREATE VIEW PercentPopulationVaccinated AS 
-- SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cummulative_vaccinations
-- FROM CovidDeaths dea
-- JOIN CovidVaccinations vac 
--     ON dea.location = vac.location
--     AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL
