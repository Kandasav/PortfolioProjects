--converting datatypes in columns
--ALTER TABLE PortfolioProject..CovidDeaths$
--ALTER COLUMN total_deaths float

--ALTER TABLE PortfolioProject..CovidDeaths$
--ALTER COLUMN total_cases float


--select *
--from INFORMATION_SCHEMA.COLUMNS

Select * 
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4


-- Select Data that I am going to be using 
Select location, date , total_cases , new_cases , total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2

-- Looking at total cases vs total deaths
-- Shows liklihood of dying if you contract covide in your country

Select location, date , total_cases , total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
From PortfolioProject..CovidDeaths$
Where location like '%united kingdom%'
Order by 1,2

-- Looking at total cases vs population
-- Shows the percentage of population got Covid
Select location, date , total_cases , population, (total_cases/population)*100 AS Percente_of_population_infected
From PortfolioProject..CovidDeaths$
--Where location like '%united kingdom%'
Order by 1,2

-- Looking at countries with highest infection rate compared to population 

Select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 AS Percente_of_population_infected
From PortfolioProject..CovidDeaths$
Group by location, population
--Where location like '%united kingdom%'
Order by Percente_of_population_infected desc

-- Showing countries with highest death count per poulation

Select location, MAX(total_deaths) as Total_Death_Count
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by location
--Where location like '%united kingdom%'
Order by Total_Death_Count desc

-- Showing continent with the highest death count per population

Select continent, MAX(total_deaths) as Total_Death_Count
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
--Where location like '%united kingdom%'
Order by Total_Death_Count desc

-- Global Numbers

Select  date  , sum(new_cases) as Total_Cases, sum(new_deaths) as Total_deaths ,(sum(new_deaths)/sum(nullif(new_cases,0)))*100 AS Death_Percentage
From PortfolioProject..CovidDeaths$
--Where location like '%united kingdom%'
where continent is not null
group by date
Order by 1,2


-- Looking at total population vs vaccinaton

select dea.continent, dea.location , dea.date , dea.population , vac.new_vaccinations,
sum(cast(new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location , dea.date) as Cumulative_vaccination_amount

from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by  2 , 3

--USING a CTE

With PopvsVac (continent, location , date, population,new_vaccinations,Cumulative_vaccination_amount)
as
(
select dea.continent, dea.location , dea.date , dea.population , vac.new_vaccinations,
sum(cast(new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location , dea.date) as Cumulative_vaccination_amount

from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by  2 , 3
)
Select  *, (Cumulative_vaccination_amount/population)*100
From PopvsVac
--where location = 'Albania'

--Using TempTable
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Cumulative_vaccination_amount numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location , dea.date , dea.population , vac.new_vaccinations,
sum(cast(new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location , dea.date) as Cumulative_vaccination_amount

from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by  2 , 3

Select  *, (Cumulative_vaccination_amount/population)*100 as Percentage_of_population_vaccinated
From #PercentPopulationVaccinated


-- Creating View to store date for later visualtiation

Create view PercentPopulationVaccinated as
select dea.continent, dea.location , dea.date , dea.population , vac.new_vaccinations,
sum(cast(new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location , dea.date) as Cumulative_vaccination_amount

from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by  2 , 3

Select * 
from PercentPopulationVaccinated