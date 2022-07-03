--Select *
--From CovidVaccinations
--Order by 3, 4

--Select *
--From CovidDeaths
--Order by 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order by 1, 2

--Total Cases vs Total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 PercentageDeath
From CovidDeaths
Where location like '%philippines%'
Order by 1, 2

--Total Cases vs Population
Select Location, date, total_cases, population, (total_cases / population)*100 CasePercentage
From CovidDeaths
Where location like '%philippines%'
Order by 1, 2

-- Countries with highest infection percentage
Select Location, population, MAX(total_cases) MaxInfectionCount, MAX((total_cases / population))*100 CasePercentage
From CovidDeaths
--Where population >= '10000000'
Group By location, population
Order by CasePercentage desc

--Countries with the highest Death count per population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group By location
Order by TotalDeathCount desc

-- Highest Deathcount per population by Continent
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group By continent
Order by TotalDeathCount desc

-- looking at Continents already provided by the table (since the TotalDeathCount looked small above^)
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is null 
Group By location
Order by TotalDeathCount desc

-- Continents with the highest death count
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group By continent
Order by TotalDeathCount desc

-- Global numbers
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as CasePercentage
From CovidDeaths
Where continent is not null
--Group by date
Order by 1, 2

--Total Population vs Vaccination (Showing Vaccination Progress per day by location)
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as VaccinationProgress
From CovidDeaths deaths
Join CovidVaccinations vac
	On deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null 
order by 1,2,3


DROP Table if exists #PercentPopulationVacinated
Create Table #PercentPopulationVacinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
VaccinationProgress numeric
)

Insert Into #PercentPopulationVacinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as VaccinationProgress
From CovidDeaths deaths
Join CovidVaccinations vac
	On deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null 

Select *, (VaccinationProgress/population)*100 PercentageProgress
From #PercentPopulationVacinated

-- View for Visualizations

Create View PercentPopulationVaccinated as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as VaccinationProgress
From CovidDeaths deaths
Join CovidVaccinations vac
	On deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null 

Create View PercentageDeathPH as
Select Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 PercentageDeath
From CovidDeaths
Where location like '%philippines%'

Create View CasePercentagePH as
Select Location, date, total_cases, population, (total_cases / population)*100 CasePercentage
From CovidDeaths
Where location like '%philippines%'

Create View HighestCountryInfectionPercentage as
Select Location, population, MAX(total_cases) MaxInfectionCount, MAX((total_cases / population))*100 CasePercentage
From CovidDeaths
--Where population >= '10000000'
Group By location, population

Create View ContinentDeathCount as 
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is null 
Group By location

Create View GlobalNumbers as
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as CasePercentage
From CovidDeaths
Where continent is not null