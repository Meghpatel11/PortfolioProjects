-- Displaying needed columns
select location,date,total_cases,total_deaths,population
from ['CovidDeathsfinal']
order by 1,2;

-- Death rate by country
select location,date,total_cases,total_deaths,ROUND((total_deaths/total_cases)*100,2) as death_rate
from ['CovidDeathsfinal']
where location like '%India%'
order by 1,2;

-- Infaction rate by country
select location,date,total_cases,population,ROUND((total_cases/population)*100,2) as infaction_rate
from ['CovidDeathsfinal']
where location like '%India%'
order by 1,2;

-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected
from ['CovidDeathsfinal']
Group by Location, Population
order by PercentPopulationInfected desc;

-- Heighest deaths by location groups
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ['CovidDeathsfinal']
Where continent is  null 
Group by location
order by TotalDeathCount desc

-- Heighest deaths by countries
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ['CovidDeathsfinal']
Where continent is not null 
Group by location
order by TotalDeathCount desc

--cases arount the world day by day
select date,SUM(new_cases) as totalCases, SUM(CAST(new_deaths as int)) as totalDeaths,
SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as deathRate
from ['CovidDeathsfinal']
where continent is not null
group by date
order by deathRate desc;

-- Contry population and vaccinated people
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as totaPeopleVaccinated
From ['CovidDeathsfinal'] dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- using CTE table to perform Calculation on Partition By in previous query
with peopleVaccinated(continent,location,date,population,new_vaccinations, totaPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as totaPeopleVaccinated
From ['CovidDeathsfinal'] dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
select *,(totaPeopleVaccinated/population)*100 as vaccinationRate
from peopleVaccinated 

-- Using Temp Table to perform Calculation on Partition By in previous query
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
totaPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as totaPeopleVaccinated
From ['CovidDeathsfinal'] dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date

select *,(totaPeopleVaccinated/population)*100 as vaccinationRate
from #PercentPopulationVaccinated

-- making views for later use
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From ['CovidDeathsfinal'] dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

-- Heighest deaths by location groups
Create View deathsbylocationgroup as
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ['CovidDeathsfinal']
Where continent is  null 
Group by location

-- Heighest deaths by countries
Create View deathsbycountries as
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ['CovidDeathsfinal']
Where continent is not null 
Group by location

-- Heighest deaths by location groups view
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ['CovidDeathsfinal']
Where continent is  null 
Group by location
order by TotalDeathCount desc

-- Heighest deaths by countries view
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ['CovidDeathsfinal']
Where continent is not null 
Group by location
order by TotalDeathCount desc