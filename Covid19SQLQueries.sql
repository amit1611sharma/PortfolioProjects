
Select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

Select * from PortfolioProject..CovidVaccinations
where continent is not null
order by 3, 4

--Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at total cases vs total deaths 
--Shows likeihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where continent is not null and
location like '%india%'
order by 1,2

--Looking at total cases vs population
-- Shows what percentage of population got covid
Select location, date, population,total_cases, (total_cases/population)*100 as CovidPositivePercentage 
from PortfolioProject..CovidDeaths
where continent is not null and
location like '%india%'
order by 1,2

--Looking at countries with highest infection rate compared to population

Select location, population, max(total_cases) as HighestCovidPositiveCount, max((total_cases/population))*100 as CovidPositivePercentage 
from PortfolioProject..CovidDeaths
---where location like '%india%'
where continent is not null
group by location, population
order by CovidPositivePercentage desc

---Showing countries with highest death count per population
Select location, max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
---where location like '%india%'
where continent is not null
group by location
order by TotalDeathCount desc

----LET's break things by continent
------Showing the continents with highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
---where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc

---GLOBAL NUMBERS
Select date, sum(new_cases) as total_cases, SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where continent is not null 
---location like '%india%'
group by date
order by 1,2

---- Total cases vs total deaths

Select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where continent is not null 
---location like '%india%'
---group by date
order by 1,2

----Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as 
RollingPeopleVaccinated ----(RollingPeopleVaccinated/population)*100

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2, 3


---USE CTE

With PopvsVac(continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as 
RollingPeopleVaccinated ----(RollingPeopleVaccinated/population)*100

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2, 3
)

select * , (RollingPeopleVaccinated/population)*100
from PopvsVac



---TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as 
RollingPeopleVaccinated ----(RollingPeopleVaccinated/population)*100

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2, 3

select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

----Creating views to stoe data for later visualizations

create view PercentPopulationVaccinated 
as
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as 
RollingPeopleVaccinated ----(RollingPeopleVaccinated/population)*100

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2, 3

Select *
from PercentPopulationVaccinated
