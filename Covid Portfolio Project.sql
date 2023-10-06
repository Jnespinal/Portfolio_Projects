SELECT *
FROM
	PortfolioProject.dbo.CovidDeaths
WHERE
	continent is not null
ORDER BY 3,4


SELECT
	Location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM
	PortfolioProject.dbo.CovidDeaths
WHERE
	continent is not null
ORDER BY 1,2


-- Total Cases VS Total Deaths
-- Shows likelihood of dying if you contract covid in your country 

SELECT
	Location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS death_percentage
FROM
	PortfolioProject.dbo.CovidDeaths
WHERE 
	Location like '%states%' AND continent is not null
ORDER BY 1,2

-- Total Cases VS Population
-- Shows what percentage of population infected with Covid

SELECT
	Location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 AS percent_population_infected
FROM
	PortfolioProject.dbo.CovidDeaths
WHERE
	continent is not null
--WHERE 
--	Location like '%states%'
ORDER BY 1,2


--Countries with Highest Infection Rate compared to Population

SELECT
	Location,
	population,
	MAX(total_cases) AS highest_infection_count,
	MAX((total_cases/population))*100 AS percent_population_infected
FROM
	PortfolioProject.dbo.CovidDeaths
--WHERE 
--	Location like '%states%'
GROUP BY 
	Location, 
	Population
ORDER BY percent_population_infected desc

-- Countries with Highest Death Count per Population

SELECT
	Location,
	MAX(cast(total_deaths AS int)) AS total_death_count
FROM
	PortfolioProject.dbo.CovidDeaths
WHERE
	continent is not null
--WHERE 
--	Location like '%states%'
GROUP BY 
	Location
ORDER BY total_death_count desc

--Break down by Continent


-- Continents with the highest death count per population

SELECT
	continent,
	MAX(cast(total_deaths AS int)) AS total_death_count
FROM
	PortfolioProject.dbo.CovidDeaths
--WHERE 
--	Location like '%states%'
WHERE
	continent is not null
GROUP BY continent
ORDER BY total_death_count desc


-- Global numbers

SELECT
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM
	PortfolioProject.dbo.CovidDeaths
-- WHERE Location like '%states%'
WHERE 
	continent is not null
--GROUP BY date
ORDER BY 1,2

-- Total Population VS Vaccinations
-- Percentage of Population that has received at leaset one Covid Vaccine

SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated,
	--(rolling_people_vaccinated/population)*100
FROM
	PortfolioProject.dbo.CovidDeaths dea 
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent is not null
ORDER BY
	2,3


	
-- Using CTE to perform Calculation on Partition By in previous query



WITH 
	PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
	--(rolling_people_vaccinated/population)*100
FROM
	PortfolioProject.dbo.CovidDeaths dea 
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent is not null
--ORDER BY
--	2,3
)
SELECT *,
	(rolling_people_vaccinated/population)*100
FROM PopvsVac


-- Using Tempt table to perform calculation on partition by in previous query

DROP Table if exists #Percent_population_vaccinated
Create Table #Percent_population_vaccinated
(
continent nvarchar(255),
Location nvarchar (255),
Date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #Percent_population_vaccinated
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
	--, (rolling_people_vaccinated/population)*100
FROM
	PortfolioProject.dbo.CovidDeaths dea 
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent is not null
--ORDER BY
--	2,3

SELECT *,
	(rolling_people_vaccinated/population)*100
FROM #Percent_population_vaccinated


-- Creating view to store data for later visualizations

USE PortfolioProject
GO
CREATE VIEW Percent_population_vaccinated AS
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
	--, (rolling_people_vaccinated/population)*100
FROM
	PortfolioProject.dbo.CovidDeaths dea 
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent is not null

