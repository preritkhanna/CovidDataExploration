/*
Queries used for Tableau Project
*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2;

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc;


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc;




-- Looking at the data, continent is null in places where location is not a country! True for both CovidDeaths and CovidVaccinations
SELECT distinct continent, location
FROM CovidExploration..CovidDeaths
where continent is null
order by 2;


-- Whole data available

SELECT *
FROM CovidDeaths
where continent is not null
ORDER BY 3,4;

SELECT *
FROM CovidExploration..CovidVaccinations 
where continent is not null
ORDER BY 3,4;



-- WORKING ON CovidDeaths
-- Available Columns in CovidDeaths
	--1	iso_code, continent, location, date
	--2	population, total_cases, new_cases, new_cases_smoothed
	--3	total_deaths, new_deaths, new_deaths_smoothed,
	--4	total_cases_per_million, new_cases_per_million, new_cases_smoothed_per_million
	--5	total_deaths_per_million, new_deaths_per_million, new_deaths_smoothed_per_million
	--6	reproduction_rate, icu_patients, icu_patients_per_million, hosp_patients, hosp_patients_per_million
	--7	weekly_icu_admissions, weekly_icu_admissions_per_million, weekly_hosp_admissions, weekly_hosp_admissions_per_million
--	Going to work mainly on 1,2 and 3. Could see reproduction_rate, icu_patients, hosp_patients


--	Select data that to be used

Select Location, date, total_cases, new_cases, total_deaths, new_deaths, population
FROM CovidExploration..CovidDeaths
where continent is not null
ORDER BY 1,2;

--	Total Cases vs Total Deaths for India
--	Getting Death Percentage per day. Meaning Total_deaths per total_cases on that day.

Select Location, date, total_cases as tc, total_deaths as td, (total_deaths/total_cases)*100 as DeathPercent
FROM CovidDeaths
where location='India'
order by 1,2;


-- Looking at Total Cases vs Population
-- Shows what percentage of population got infected

Select Location, date, total_cases, population, (Total_cases/population)*100 as InfectedPercentage
FROM CovidExploration..CovidDeaths
where continent is not null --and location= 'India'
order by 1,2;

-- Looking at highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((Total_Cases/Population))*100 as HighestPercentPopulationInfected
FROM CovidExploration..CovidDeaths
where continent is not null
GROUP BY location, Population
ORDER BY HighestPercentPopulationInfected DESC;


-- Looking at highest death rate compared to population
-- Total_deaths currently is varchar data type. We need to cast it as integer datatype

Select Location, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((cast(total_deaths as int)/Population))*100 as HighestPercentDeath
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
ORDER BY 1;

-- Total Percentage

Select sum(new_cases) as DayWiseCases, sum(cast(new_deaths as int)) as DayWiseDeaths, sum(cast(new_Deaths as int))/sum(new_Cases)*100 as DayWiseDeathPercentage
FROM CovidExploration..CovidDeaths
where continent is not null
-- group by date
ORDER BY 1;



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
order by 2,3;






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
FROM PopvsVac;


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
FROM #PercentPopulationVaccinated;



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

SELECT * FROM PercentPopulationVaccinated;
