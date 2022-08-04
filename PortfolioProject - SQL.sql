Select * From CovidDeaths;

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order by 1,2;


-- Likelihood of dying due to COVID in Azerbaijan
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location = 'Azerbaijan'
Order by 1,2;


-- Percentage of population caught COVID in Azerbaijan
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
Where location = 'Azerbaijan'
Order by 1,2;


-- The highest infection counts in terms of population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc;


-- The highest death counts by continents
Select location, MAX(cast(total_deaths as int)) as HighestDeathCount
From CovidDeaths
Where continent is null
Group by location
Order by HighestDeathCount desc;


-- Global Numbers by date
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
From CovidDeaths
Where continent is not null
Group by date
Order by 1;


-- Vaccinations through dates (in Azerbaijan)
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, VaccinationsThroughDate) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(new_vaccinations as bigint)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as VaccinationsThroughDate
From CovidDeaths dea
Join CovidVaccinations vac 
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null and dea.location = 'Azerbaijan'
)
Select *, (VaccinationsThroughDate/Population) * 100 as VaccinationByPopulation From PopvsVac;




--------------------------------------------------------
--View 

Create View NewView as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(new_vaccinations as bigint)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as VaccinationsThroughDate
From CovidDeaths dea
Join CovidVaccinations vac 
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null and dea.location = 'Azerbaijan'


