select *
From PortfolioProjectAug.dbo.coviddeath$
Where continent is not null
Order by 3,4

--select *
--From PortfolioProjectAug.dbo.covidvaccination$
--Order by 3,4

Location Numbers

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectAug.dbo.coviddeath$
Order by 1,2

Analysis of total death out of total cases= total_cases vs total_deaths

This shows the likelihood of one dying when one contracts Covid-19 in a particular country like USA.
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From PortfolioProjectAug.dbo.coviddeath$
Where location like '%states%'
Order by 1,2

Analyzing percentage of population that got Covid-19
Select location, date,population, total_cases, (total_cases/population)*100 as covidcases_percentage
From PortfolioProjectAug.dbo.coviddeath$
Where location like '%states%'
Order by 1,2

Analysing percentage of country with the highest infection rate per population
Select location, population, MAX(total_cases) as HighestInfectionCount, 
MAX(total_cases/population)*100 as PercentPopulationInfected 
From PortfolioProjectAug..coviddeath$
Group by location, population
Order by PercentPopulationInfected desc

Showing percentage of country with highest death count per population
Select location, MAX(Cast(total_deaths as Int)) as TotalDeathCount
From PortfolioProjectAug..coviddeath$
Where continent is not null
Group by location
Order by TotalDeathCount desc

--Let's break things down by continent

Total deaths by continent
--Select continent, MAX(Cast(total_deaths as Int)) as TotalDeathCount
--From PortfolioProjectAug..coviddeath$
--Where continent is not null
--Group by continent
--Order by TotalDeathCount desc

Continent with highest death count
----Select continent, MAX(Cast(total_deaths as Int)) as TotalDeathCount
----From PortfolioProjectAug..coviddeath$
----Where continent is null
----Group by continent
----Order by TotalDeathCount desc

Global Numbers

Select continent, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectAug.dbo.coviddeath$
Order by 1,2

Analysis of total death out of total cases= total_cases vs total_deaths by continent

This shows the likelihood of one dying when one contracts Covid-19 in a particular continent 
Select continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From PortfolioProjectAug.dbo.coviddeath$
Where location like '%states%'
Order by 1,2

Analyzing percentage of population that got Covid-19 by continent
Select continent, date,population, total_cases, (total_cases/population)*100 as covidcases_percentage
From PortfolioProjectAug.dbo.coviddeath$
--Where location like '%states%'
Order by 1,2

Analysing percentage of continent with the highest infection rate
Select continent, population, MAX(total_cases) as HighestInfectionCount, 
MAX(total_cases/population)*100 as PercentPopulationInfected 
From PortfolioProjectAug..coviddeath$
Group by continent, population
Order by PercentPopulationInfected desc

Showing percentage of deathcount by continent
Select continent, MAX(Cast(total_deaths as Int))/SUM(population)*100 as TotalDeathCountpercentage
From PortfolioProjectAug..coviddeath$
Where continent is not null
Group by continent, population
Order by TotalDeathCountpercentage desc


--Global death percentage
--Select date, SUM(new_cases), SUM(cast(new_deaths as Int)) as deathpercentage
--From PortfolioProjectAug.dbo.coviddeath$
--Where continent is not null
--Group by date
--Order by 1,2

--Global death percentage

Select date, SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as Int)) as TotalNewDeath,
SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProjectAug.dbo.coviddeath$
Where continent is not null
Group by date
Order by 1,2

Select *
FROM PortfolioProjectAug..covidvaccination$






--Looking at total population vs vaccination

View joined table coviddeath and covidvaccination
Select *
FROM PortfolioProjectAug..coviddeath$ death
JOIN PortfolioProjectAug..covidvaccination$ vacc
    on death.location=vacc.location
	and death.date=vacc.date
Where death.continent is not null


Total number of people vaccinated in the world
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
FROM PortfolioProjectAug..coviddeath$ death
JOIN PortfolioProjectAug..covidvaccination$ vacc
    on death.location=vacc.location
	and death.date=vacc.date
Where death.continent is not null
order by 1,2,3


Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations 
, SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by death.location)
FROM PortfolioProjectAug..coviddeath$ death
JOIN PortfolioProjectAug..covidvaccination$ vacc
    on death.location=vacc.location
	and death.date=vacc.date
Where death.continent is not null
order by 2,3

Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations 
, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as RollingPeoplevaccinated
, (RollingPeoplevaccinated/population)*100
FROM PortfolioProjectAug..coviddeath$ death
JOIN PortfolioProjectAug..covidvaccination$ vacc
    on death.location=vacc.location
	and death.date=vacc.date
Where death.continent is not null
order by 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccination, RollingPeoplevaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by death.location Order by death.location, 
 death.date) as RollingPeoplevaccinated
--, (RollingPeoplevaccinated/population)*100 
FROM PortfolioProjectAug..coviddeath$ death
JOIN PortfolioProjectAug..covidvaccination$ vacc
    on death.location=vacc.location
	and death.date=vacc.date
Where death.continent is not null
)
Select *,  (RollingPeoplevaccinated/population)*100 as PercentageVaccinated
From PopvsVac


-----Temp Table

--DROP Table if exists #PercentagePopulationvaccinated
--Create Table #PercentagePopulationvaccinated
--(
--Continent nvarchar(255),
--Location nvarchar (255),
--Date datetime,
--Population int,
--New_vaccinations int,
--RollingPeoplevaccinate int
--)

--Insert into #PercentagePopulationvaccinated
--Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations 
--, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by death.location order by death.location,
--death.date) as RollingPeoplevaccinated
----, (RollingPeoplevaccinated/population)*100
--From PortfolioProjectAug..coviddeath$ death
--JOIN PortfolioProjectAug..covidvaccination$ vacc
--    on death.location=vacc.location
--	and death.date=vacc.date
--Where death.continent is not null
----order by 2,3

--Select *, (RollingPeoplevaccinated/population)*100
--From #PercentagePopulationvaccinated


--Creating View to store for later visualization

Location Numbers

Create View Percentagevaccinated AS
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by death.location Order by death.location, 
 death.date) as RollingPeoplevaccinated
--, (RollingPeoplevaccinated/population)*100 
FROM PortfolioProjectAug..coviddeath$ death
JOIN PortfolioProjectAug..covidvaccination$ vacc
    on death.location=vacc.location
	and death.date=vacc.date
Where death.continent is not null

Select*
From Percentagevaccinated

Create View DeathPercentagePerTotalCases as
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From PortfolioProjectAug.dbo.coviddeath$
Where location like '%states%'
--Order by 1,2

Create View PercentagePopulationgettingcovid as
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From PortfolioProjectAug.dbo.coviddeath$
Where location like '%states%'
--Order by 1,2

Create View PercentageCountrywithHighestInfectionRate as
Select location, population, MAX(total_cases) as HighestInfectionCount, 
MAX(total_cases/population)*100 as PercentPopulationInfected 
From PortfolioProjectAug..coviddeath$
Group by location, population
--Order by PercentPopulationInfected desc

Create View PercentageCountrywithHighestDeathCount as
Select location, MAX(Cast(total_deaths as Int)) as TotalDeathCount
From PortfolioProjectAug..coviddeath$
Where continent is not null
Group by location
--Order by TotalDeathCount desc

--Global Numbers

Create View TotalContinentDeathCount as
Select continent, MAX(Cast(total_deaths as Int)) as TotalDeathCount
From PortfolioProjectAug..coviddeath$
Where continent is not null
Group by continent
--Order by TotalDeathCount desc

Create View ContinentwithHighestDeath as
Select continent, MAX(Cast(total_deaths as Int)) as TotalDeathCount
From PortfolioProjectAug..coviddeath$
Where continent is null
Group by continent
----Order by TotalDeathCount desc

Create View PercentageDeathcountbyContinentPandpopulation as
Select continent, MAX(Cast(total_deaths as Int))/SUM(population)*100 as TotalDeathCountpercentage
From PortfolioProjectAug..coviddeath$
Where continent is not null
Group by continent, population
--Order by TotalDeathCountpercentage desc


Global Numbers

Create View CoviddeathTable as
Select continent, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectAug.dbo.coviddeath$

Create View Covidvaccinations as
Select *
FROM PortfolioProjectAug..covidvaccination$


--Looking at total population vs vaccination

--Create View Coviddeathvaccination as
--Select *
--FROM PortfolioProjectAug..coviddeath$ death
--JOIN PortfolioProjectAug..covidvaccination$ vacc
--    on death.location=vacc.location
--	and death.date=vacc.date
--Where death.continent is not null

Create View TotalPeopleVaccinatedWorld as
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
FROM PortfolioProjectAug..coviddeath$ death
JOIN PortfolioProjectAug..covidvaccination$ vacc
    on death.location=vacc.location
	and death.date=vacc.date
Where death.continent is not null
--order by 1,2,3


--Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations 
--, SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by death.location)
--FROM PortfolioProjectAug..coviddeath$ death
--JOIN PortfolioProjectAug..covidvaccination$ vacc
--    on death.location=vacc.location
--	and death.date=vacc.date
--Where death.continent is not null
--order by 2,3

--Create View RollingTotalNewVaccination as
--Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations 
--, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as RollingPeoplevaccinated
--, (RollingPeoplevaccinated/population)*100
--FROM PortfolioProjectAug..coviddeath$ death
--JOIN PortfolioProjectAug..covidvaccination$ vacc
--    on death.location=vacc.location
--	and death.date=vacc.date
--Where death.continent is not null
----order by 2,3



