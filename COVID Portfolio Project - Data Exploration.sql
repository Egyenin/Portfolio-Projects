
Select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4



Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
where location like '%Ghana%'
order by 1,2



--Looking at the Total Cases vs Population
--Shows what percentage of population got covid
Select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
where location like '%Ghana%'
order by 1,2



--Looking at countries with highest infection rate

Select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 1,2



--Showing Countries with Highest Death Count per Population
Select location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc



--LET'S BREAK THINGS DOWN BT CONTINENT


-- Showing continents with highest death count per population
Select continent, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Ghana%'
where continent is not null
group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS

Select date, Sum(new_cases) as total_cases, Sum(new_deaths) as total_deaths
, Sum(new_deaths)/nullif (Sum(new_cases), 0*100) as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


Select Sum(new_cases) as total_cases, Sum(new_deaths) as total_deaths
, Sum(new_deaths)/nullif (Sum(new_cases), 0*100) as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2



--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
Order by 1,2,3



--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date

