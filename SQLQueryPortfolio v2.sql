SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 1,2



-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
Where location like '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population 

SELECT Location, population, MAX(total_cases) as HighestInfectionCount,   Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc



-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



-- Global numbers

SELECT SUM(new_cases) as total_cases, SUM (cast(new_deaths as int)) total_deaths, SUM (cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

--Select * 
--FROM PortfolioProject..CovidDeaths dea
--JOIN PortfolioProject..CovidVaccinations vac
	--ON dea.location = vac.location
	--and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
	dea.Date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3 


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
	dea.Date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 
)
Select *, (RollingPeopleVaccinated/Population)*100 as RollingVaccinationPercent
From PopvsVac



--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
	dea.Date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinatd as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
	dea.Date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 

Select *
From PercentPopulationVaccinatd