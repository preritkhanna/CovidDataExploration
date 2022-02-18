SELECT *
FROM CovidExploration..CovidDeaths
where continent is not null  -- Because after looking at data, I realized that continent is null in those places where location is not a country
ORDER BY 3,4;

SELECT *
FROM CovidExploration..CovidVaccinations 
ORDER BY 3,4;

-- Select data that to be used

Select Location, date, total_cases, new_cases, total_deaths, population
FROM CovidExploration..CovidDeaths
where continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths for India

Select Location, date, total_cases, total_deaths, (Total_Deaths/Total_Cases)*100 as DeathPercentage
FROM CovidExploration..CovidDeaths
where location= 'India' and continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got infected

Select Location, date, total_cases, population, (Total_cases/population)*100 as InfectedPercentage
FROM CovidExploration..CovidDeaths
where continent is not null


-- Looking at highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((Total_Cases/Population))*100 as HighestPercentPopulationInfected
FROM CovidExploration..CovidDeaths
where continent is not null
GROUP BY location, Population
ORDER BY HighestPercentPopulationInfected DESC


-- Looking at highest death rate compared to population
-- Total_deaths currently is varchar data type. We need to cast it as integer datatype

Select Location, MAX(cast(total_deaths as int)) as HighestDeathCount --MAX((total_deaths/Population))*100 as HighestPercentDeath
FROM CovidExploration..CovidDeaths
where continent is not null
GROUP BY location
ORDER BY HighestDeathCount DESC;



-- GOING BY CONTINENTS NOW

-- Showing the continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount --MAX((total_deaths/Population))*100 as HighestPercentDeath
FROM CovidExploration..CovidDeaths
where continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC;


-- EVERYTHING FOR GLOBAL

-- Per day stats for world
Select date, sum(new_cases) as DayWiseCases, sum(cast(new_deaths as int)) as DayWiseDeaths, sum(cast(new_Deaths as int))/sum(new_Cases)*100 as DayWiseDeathPercentage
FROM CovidExploration..CovidDeaths
where continent is not null
group by date
ORDER BY 1

-- Total Percentage

Select sum(new_cases) as DayWiseCases, sum(cast(new_deaths as int)) as DayWiseDeaths, sum(cast(new_Deaths as int))/sum(new_Cases)*100 as DayWiseDeathPercentage
FROM CovidExploration..CovidDeaths
where continent is not null
-- group by date
ORDER BY 1



-- Looking at Total Population vs Vaccinations

-- Rolling Vaccinated || Used Partition, OVER, convert, Rolling Count, Temporary table
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (
FROM CovidExploration..CovidDeaths dea
JOIN CovidExploration..CovidVaccinations vac
	ON 
	dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3






-- Use CTE; Creating a temporary
With PopvsVac (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (
FROM CovidExploration..CovidDeaths dea
JOIN CovidExploration..CovidVaccinations vac
	ON 
	dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE


DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent varchar(255),
location varchar(255),
date datetime,
Population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (
FROM CovidExploration..CovidDeaths dea
JOIN CovidExploration..CovidVaccinations vac
	ON 
	dea.location=vac.location and dea.date=vac.date
-- where dea.continent is not null
-- order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

DROP VIEW if exists PercentPopulationVaccinated

CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (
FROM CovidExploration..CovidDeaths dea
JOIN CovidExploration..CovidVaccinations vac
	ON 
	dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3

SELECT * FROM PercentPopulationVaccinated