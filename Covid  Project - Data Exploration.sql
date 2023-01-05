/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

select *
from PortfolioProject1..CovidDeaths
Where continent is not null
order by 3,4

--select *
--from PortfolioProject1..CovidVaccinations
--order by 3,4


-- Selecting Data

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject1..CovidDeaths
where continent is not null
order by 1,2



-- Total Cases vs Total Deaths

---- Shows likelihood of death if contracted in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
order by 1,2

---- Shows likelihood of death if contracted in the US
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2



-- Total Cases vs Population 
----Shows what percentage of population contracted Covid

select location, date, Population,total_cases, (total_cases/population)*100 as InfectionPercentage
from PortfolioProject1..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2



-- Countries with highest infection rate compared to population 

select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject1..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by location, population, continent
order by PercentPopulationInfected desc



-- Countries with Highest Death Count per Population

select location, MAX(cast(Total_deaths as int)) as  TotalDeathCount
from PortfolioProject1..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location, continent
order by TotalDeathCount desc



-- BREAKING IT DOWN BY CONTINENT

---- Showing contintents with the highest death count per population

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent 
order by TotalDeathCount desc


 
 -- GLOBAL NUMBERS

 ---- By Date
select date, SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
--Where location like '%states%'
where continent is not null
group by date
order by 1,2

---- Full Total
select SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
--Where location like '%states%'
where continent is not null
--group by date
order by 1,2



-- Total Population vs Vaccinations
---- Shows Percentage of Population that has recieved at least one Covid Vaccine

select death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
-- SUM(cast(bigint,vax.new_vaccinations as int)) OVER (Partition by death.location)
--, (RollingPeopleVaccinated/population)*100
from portfolioproject1..CovidDeaths death
join PortfolioProject1..CovidVaccinations vax
	on death.location = vax.location
	and death.date = vax.date
where death.continent is not null
order by 2,3




-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVax (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
-- SUM(cast(bigint,vax.new_vaccinations as int)) OVER (Partition by death.location)
--, (RollingPeopleVaccinated/population)*100
from portfolioproject1..CovidDeaths death
join PortfolioProject1..CovidVaccinations vax
	on death.location = vax.location
	and death.date = vax.date
where death.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVax





-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinated numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
-- SUM(cast(bigint,vax.new_vaccinations as int)) OVER (Partition by death.location)
--, (RollingPeopleVaccinated/population)*100
from portfolioproject1..CovidDeaths death
join PortfolioProject1..CovidVaccinations vax
	on death.location = vax.location
	and death.date = vax.date
where death.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



-- Creating View to store data for later visualization 

Create View PercentPopulationVaccinated as
select death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
-- SUM(cast(bigint,vax.new_vaccinations as int)) OVER (Partition by death.location)
--, (RollingPeopleVaccinated/population)*100
from portfolioproject1..CovidDeaths death
join PortfolioProject1..CovidVaccinations vax
	on death.location = vax.location
	and death.date = vax.date
where death.continent is not null
--order by 2,3   
