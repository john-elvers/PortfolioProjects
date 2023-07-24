
select *
from dbo.CovidDeaths
order by 3,4

select *
from dbo.CovidVaccinations
order by 3,4

--Select Data that we are going to be using
Select Location, date,total_cases, new_cases, total_deaths, population
From dbo.CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
--Shows Likelihood of dying if you contract covid in your country
Select Location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From dbo.CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of the population got covid
Select Location, date,total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
From dbo.CovidDeaths
Where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to population

Select Location, population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PerecntPopulationInfected
From dbo.CovidDeaths
--Where location like '%states%'
Group by location, population
order by PerecntPopulationInfected desc

Select location,MAX(Total_Deaths) as TotalDeathCount
From dbo.CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-- Broken down by continent

Select location,MAX(Total_Deaths) as TotalDeathCount
From dbo.CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc


-- Showing continents with the hightest death count per population

Select continent,MAX(Total_Deaths) as TotalDeathCount
From dbo.CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_Cases,SUM(new_deaths) as total_deaths, SUM(New_deaths)/SUM(New_Cases)*100
From dbo.CovidDeaths
--Where location like '%states%'
where continent is not null
and new_cases != 0 and new_deaths != 0
--Group by date
order by 1,2


--Looking at Total Population vs Vaccinations

select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(Cast(cv.new_vaccinations as bigint)) OVER (Partition by  cd.location Order by cd.location,cd.date) 
as RollingPoepleVaccinated
--, (RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths cd
Join dbo.CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 1,2,3

-- USE CTE
With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPoepleVaccinated)
as
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(Cast(cv.new_vaccinations as bigint)) OVER (Partition by  cd.location Order by cd.location,cd.date) 
as RollingPoepleVaccinated
--, (RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths cd
Join dbo.CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
)

select *, (RollingPoepleVaccinated/Population)*100
from PopvsVac

-- TEMP TABLES
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPoepleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(Cast(cv.new_vaccinations as bigint)) OVER (Partition by  cd.location Order by cd.location,cd.date) 
as RollingPoepleVaccinated
--, (RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths cd
Join dbo.CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null

select *, (RollingPoepleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(Cast(cv.new_vaccinations as bigint)) OVER (Partition by  cd.location Order by cd.location,cd.date) 
as RollingPoepleVaccinated
--, (RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths cd
Join dbo.CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null


Select *
from PercentPopulationVaccinated