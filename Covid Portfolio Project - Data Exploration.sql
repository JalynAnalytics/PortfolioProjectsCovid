/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


SELECT *
FROM CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

-- Select Data that we are going to be starting with

select location, date, total_cases,new_cases,total_deaths, population
FROM CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID-19 in your country

select location, date, total_cases,total_deaths,(Total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%japan%'
AND continent is not NULL
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location, date,population, total_cases,(Total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

select location,population, MAX(total_cases) AS HighestInfectionCount,MAX((Total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
GROUP BY Population, location
ORDER BY PercentPopulationInfected desc

-- Countries with highest Death Count Per Population

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS


select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
--WHERE location like '%japan%'
FROM CovidDeaths
where continent is not NULL 
and new_cases is not null and new_cases <>0
--GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query


with PopvsVac (continent, location, Date, Population, New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query


DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

-- Utilize Drop if view has already been created, then rerun Create View to make another view

DROP view if exists PercentPopulationVaccinated


Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null












