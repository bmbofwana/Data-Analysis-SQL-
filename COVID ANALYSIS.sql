
SELECT *
FROM portfolio.dbo.[CovidDeaths ]
 WHERE continent is not null
order by 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio.dbo.[CovidDeaths ]
order by 1,2


-- Look at Total cases vs Total deaths, shows the likelihood of death 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 death_rate
FROM portfolio.dbo.[CovidDeaths ]
WHERE location like '%zambia%'
order by 1,2

-- Total cases vs population 
-- shows the % of the population has covid
SELECT location, date, total_cases,population, (total_cases/population)*100 infection_rate
FROM portfolio.dbo.[CovidDeaths ]
WHERE location like '%zambia%'
order by 1,2

-- Looking at countries with the highest infection rate
SELECT location, MAX(total_cases) highest_count , population, MAX((total_cases/population))*100 infection_rate
FROM portfolio.dbo.[CovidDeaths ] 
-- WHERE location like '%zambia%'
GROUP BY location, population
order by 4 DESC 

--showing countries with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM portfolio.dbo.[CovidDeaths ]
WHERE continent is not null
Group By location 
order by 2 DESC

-- Looking at countries with the highest death rate
SELECT location, MAX(cast(total_deaths as int)) death_count , population, MAX((total_deaths/population))*100 infection_rate
FROM portfolio.dbo.[CovidDeaths ] 
-- WHERE location like '%zambia%'
WHERE continent is not null 
GROUP BY location, population
order by 4 DESC 


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac