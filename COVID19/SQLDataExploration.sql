--COVID_DEATH

select *
from PORTOFOLIO..Covid_Deaths
where continent is not null
order by 3,4

select *
from PORTOFOLIO..Covid_Deaths
where continent is not null
and location = 'Indonesia'
order by 4 desc

-------------------------------------------------------------
--Select data to be using
select location,date,total_cases,new_cases,total_deaths,population
from PORTOFOLIO..Covid_Deaths
where continent is not null
order by 1,2

-------------------------------------------------------------
--Rasio Total Cases and Total Deaths
--Shows likelihood
select location,date,total_deaths,total_cases, (total_deaths/total_cases)*100 as DeathPercentage
from PORTOFOLIO..Covid_Deaths
where location like '%states%' and continent is not null
order by 1,2

-------------------------------------------------------------
--Total Cases vs Population
select location,date,total_cases,population, (total_cases/population)*100 as CasePercentage
from PORTOFOLIO..Covid_Deaths
where continent is not null
order by 1,2

-------------------------------------------------------------
--Looking at Countries with highest infection rate compare to population
select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as CasePersentage
from PORTOFOLIO..Covid_Deaths
where continent is not null
group by location,population
order by CasePersentage desc

-------------------------------------------------------------
--Let's Break Things Down By Continent
--Showing continent with highest death count per population
select continent, max(cast(total_deaths as int)) as HighestDeathCount
from PORTOFOLIO..Covid_Deaths
where continent is not null 
group by continent
order by HighestDeathCount desc

-------------------------------------------------------------
--Global Number
select sum(new_cases) as TotalCase,sum(cast(new_deaths as int)) as TotalDeath,sum(cast(new_deaths as int))/sum(new_cases)*100 
as GlobalDeathPercentage
from PORTOFOLIO..Covid_Deaths
where continent is not null
order by 1,2 

-------------------------------------------------------------
--COVID_VACCINATION
select *
from PORTOFOLIO..Covid_Vaccinations
order by 3,4

-------------------------------------------------------------
--Join CovidDeath Table and CovidVaccinationTable
select *
from PORTOFOLIO..Covid_Deaths cd
join PORTOFOLIO..Covid_Vaccinations cv
	on cd.location=cv.location
	and cd.date=cv.date  

-------------------------------------------------------------
--Looking at Total Population vs Vaccination

select cd.continent
, cd.location
, cd.date
, population
, cv.new_vaccinations
, sum(convert(bigint,cv.new_vaccinations)) over (partition by cd.location) as RollingPeopleVaccinated
, (sum(convert(bigint,cv.new_vaccinations)) over (partition by cd.location) /population*100) as RollingPeopleVaccinatedPercentage
from PORTOFOLIO..Covid_Deaths cd
join PORTOFOLIO..Covid_Vaccinations cv
	on cd.location=cv.location
	and cd.date=cv.date 
where cd.continent is not null
order by 2,3

-------------------------------------------------------------
--Looking at Total Population vs Vaccination (Use CTE) 
With PopVac(continent,location,date,population,new_vaccination,RollingPeopleVaccinated)
as
(
select cd.continent
, cd.location
, cd.date
, population
, cv.new_vaccinations
, sum(convert(bigint,cv.new_vaccinations)) over (partition by cd.location) as RollingPeopleVaccinated
--, (sum(convert(bigint,cv.new_vaccinations)) over (partition by cd.location) /population*100) as RollingPeopleVaccinatedPercentage
from PORTOFOLIO..Covid_Deaths cd
join PORTOFOLIO..Covid_Vaccinations cv
	on cd.location=cv.location
	and cd.date=cv.date 
where cd.continent is not null
)
select *
, (RollingPeopleVaccinated/Population)*100 as PercentageRollingPeopleVaccinated
from PopVac

-- --Looking at Total Population vs Vaccination (Temp Table) 

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
select cd.continent
, cd.location
, cd.date
, population
, cv.new_vaccinations
, sum(convert(bigint,cv.new_vaccinations)) over (partition by cd.location) as RollingPeopleVaccinated
--, (sum(convert(bigint,cv.new_vaccinations)) over (partition by cd.location) /population*100) as RollingPeopleVaccinatedPercentage
from PORTOFOLIO..Covid_Deaths cd
join PORTOFOLIO..Covid_Vaccinations cv
	on cd.location=cv.location
	and cd.date=cv.date 

select*
, (RollingPeopleVaccinated/Population)*100 as PercentageRollingPeopleVaccinated
from #PercentPopulationVaccinated


--Create View to store data for later visualizations
Create View PercentagePopulationVaccinated as
select cd.continent
, cd.location
, cd.date
, population
, cv.new_vaccinations
, sum(convert(bigint,cv.new_vaccinations)) over (partition by cd.location) as RollingPeopleVaccinated
--, (sum(convert(bigint,cv.new_vaccinations)) over (partition by cd.location) /population*100) as RollingPeopleVaccinatedPercentage
from PORTOFOLIO..Covid_Deaths cd
join PORTOFOLIO..Covid_Vaccinations cv
	on cd.location=cv.location
	and cd.date=cv.date 
where cd.continent is not null

select *
from PercentagePopulationVaccinated