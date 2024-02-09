--Select * 
--From PortfolioProject..CovidVaccinations
--Order by 3, 4

Select * 
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3, 4

--not null used to get rid of the mistake in data where continent is null and location has continent


--Selecting data that we are using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Looking at Total cases vs Total Deaths (probability of dying if you get covid in the UK)

Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/Cast(total_cases as float))*100 as Deathpercentage 
From PortfolioProject..CovidDeaths
Where location like '%kingdom%'
and continent is not null
order by 1,2

--Used cast to convert data type from nvarchar to float to avoid error


--Total case vs population (covid cases percentage of population)
Select Location, date, population, total_cases, (cast(total_cases as float)/population)*100 as PopulationPercentage 
From PortfolioProject..CovidDeaths
--Where location like '%kingdom%'
where continent is not null
order by 1,2



--looking at countries with highest infection rate compared to population 

Select location, population, max(total_cases) as HighestInfectionCount, Max(cast(total_cases as float)/population)*100 as HighestPopulationPercentage 
From PortfolioProject..CovidDeaths
--Where location like '%kingdom%'
Where continent is not null
Group by location, population
order by 4 desc



--Showing countries with highest death count per population 

Select location, MAX(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
--where location like '%kingdom%'
Group by location
order by TotalDeathCount desc


--Covid deaths as per continent

Select location , MAX(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
--where location like '%kingdom%'
Group by location
order by TotalDeathCount desc



-- Global Numbers by date

Select date, sum(new_cases) as TotalCases, Sum(new_deaths) as TotalDeaths, 
sum(new_deaths)/nullif(sum(new_cases),0) *100 as Deathpercentage
From PortfolioProject..CovidDeaths
--Where location like '%kingdom%'
where continent is not null
Group by date
order by 1,2

-- Global Numbers total

Select sum(new_cases) as TotalCases, Sum(new_deaths) as TotalDeaths, 
sum(new_deaths)/nullif(sum(new_cases),0) *100 as Deathpercentage
From PortfolioProject..CovidDeaths
--Where location like '%kingdom%'
where continent is not null
--Group by date
order by 1,2


-- total population vs vaccination-cumulative vaccination count

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float, nullif(vac.new_vaccinations, 0))) 
over(partition by dea.location Order by dea.location, dea.date) as CumulativeVaccineCount, --(CumulativeVaccineCount/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--used nullif to avoid  the error message 'Null value is eliminated by an aggregate or other SET operation.'


--Select location, date, new_vaccinations
--From PortfolioProject..CovidVaccinations
--where continent is not null
--order by 1,2



--use CTE
with PopvsVac (continent, location, date, population, new_vaccination, CumulativeVaccineCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float, nullif(vac.new_vaccinations, 0))) 
over(partition by dea.location Order by dea.location, dea.date) as CumulativeVaccineCount --(CumulativeVaccineCount/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select continent, location, population, new_vaccination, CumulativeVaccineCount, (CumulativeVaccineCount/population)* 100 as VaccinePercentperPopulation
from PopvsVac


--Temp Table

Drop table if exists #PopulationPercentVaccinated
Create table #PopulationPercentVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
CumulativeVaccineCount numeric,
)
Insert into #PopulationPercentVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float, nullif(vac.new_vaccinations, 0))) 
over(partition by dea.location Order by dea.location, dea.date) as CumulativeVaccineCount --(CumulativeVaccineCount/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *, (CumulativeVaccineCount/population)*100 as PopulationPercentVaccinated
From #PopulationPercentVaccinated


--Creating view to store data for later visualization 

Create View PopulationPercentVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float, nullif(vac.new_vaccinations, 0))) 
over(partition by dea.location Order by dea.location, dea.date) as CumulativeVaccineCount --(CumulativeVaccineCount/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
from PopulationPercentVaccinated