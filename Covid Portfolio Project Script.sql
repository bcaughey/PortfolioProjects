Select *
From CovidDeaths
Where continent is not null
Order By 3,4

--Select *
--From CovidVaccinations
--Order By 3,4

--Select the data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order By 1,2

--Looking at Total Cases vs Total Deaths
--How many cases are there in this country & how many deaths do they have for all cases
--Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%states%'
Order By 1,2

--Looking at Total Cases vs. Population
--Shows what percentage of the population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentInfected
From CovidDeaths
Where location like '%states%'
Order By 1,2

--Looking at countries with highest infection rate compared to population

Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group By Location, population
Order By PercentPopulationInfected desc


--Showing the countries with the highest death count per population

Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group By Location
Order By TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount desc


--Showing the continents with the highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount desc


--GLOBAL NUMBERS

Select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From CovidDeaths
Where continent is not null
Order By 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations ,RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--TEMP TABLE
Drop Table if Exists #percentpopulationvaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
--Where dea.continent is not null
Select *, (RollingPeopleVaccinated/Population)*100
From #percentpopulationvaccinated


--Creating View to Store Data for Later Visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


Select *
From PercentPopulationVaccinated