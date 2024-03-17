/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

Select *
From PortfolioProject..CovidVaccinations
Where continent is not null
Order by 3,4


-- Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Total Cases vs Total Deaths
-- Shows the liklihood of dying if you contract covid in your counrty

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Europe%'
and continent is not null
Order by 1,2


-- Total cases vs The Population
-- shows what percentage of population got Covid-19

Select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Europe%'
Order by 1,2


-- Countries with Highest Infection Rates compared to Population

Select location, population, Max(total_cases) as Highestinfectioncount, Max((total_cases/population))*100 as PopulationInfectedpercent
From PortfolioProject..CovidDeaths
--where location like '%Europe%'
Group by location, Population
Order by PopulationInfectedpercent desc

-- Countries with the highest Death Count per Population

select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Europe%'
where continent is not null 
Group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Continents with highest death count per Population

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Europe%'
where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLobal NUMBERS
-- With date
Select date, Sum(new_cases) as Total_cases, Sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%Europe%'
Where continent is not null
Group by date
order by 1,2

--Without date

Select  Sum(new_cases) as Total_cases, Sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%Europe%'
Where continent is not null
--Group by date
Order by 1,2



--Total Population VS Vaccinations

Select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location,Dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = vac.location
	and Dea.date = vac.date
where Dea.continent is not null
order by 2,3



--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location,Dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = vac.location
	and Dea.date = vac.date
where Dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
From PopvsVac  



--Using Temp table to perform Calculation on Partition By in previous query 

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert Into #PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location,Dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = vac.location
	and Dea.date = vac.date
--where Dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location,Dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = vac.location
	and Dea.date = vac.date
where Dea.continent is not null
--order by 2,3

