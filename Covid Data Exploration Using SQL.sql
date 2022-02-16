select *
from Project1..CovidDeaths
where continent is not  null
order by 3,4

select *
from Project1..CovidVaccinations
order by 3,4

-- Selecting Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population 
from Project1..CovidDeaths
where continent is not  null
order by 1,2


-- Total Cases Vs Total_death
-- DeathPercentage would tell us the probabilty of death due to corona if one were to be affected by it today.
select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage 
from Project1..CovidDeaths
where continent is not  null
order by 1,2

-- Looking at Total Cases Vs Population
-- Estimating the number of people that have been affected by Covid in India
select location, date, population, total_cases, (total_cases / population) * 100 as percent_population_infected 
from Project1..CovidDeaths
where continent is not  null
order by 1,2

-- Countries that have the highest infection rates compared to the population

select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases / population)) * 100 as percent_population_infected
from Project1..CovidDeaths
where continent is not  null
group by location,population
order by percent_population_infected DESC


-- Showing Countries with Highest Dealth Count per Population

select location, MAX(cast(total_deaths as int)) as total_death_count
from Project1..CovidDeaths
where continent is not  null
group by location
order by total_death_count desc

-- Comparison based on continents
-- Continents with highest death count

select continent, MAX(cast(total_deaths as int)) as total_death_count
from Project1..CovidDeaths
where continent IN ('Asia','Europe','North America','South America', 'Africa', 'Oceania','World')
group by continent
order by total_death_count desc

-- Global numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/ SUM(new_cases) * 100 as DeathPercentage 
from Project1..CovidDeaths
where continent is not  null
--group by date
order by 1,2


-- Looking at total population VS total vaccinations

-- USE CTE

With PopvsVac(continent, location, date,population, new_vaccinations, people_vaccinated)
as
(
select D.continent,D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(bigint, V.new_vaccinations)) OVER (Partition By D.Location order by D.location, d.date) as people_vaccinated
--,(people_vaccinated / population ) *100
from Project1..CovidDeaths D
Join Project1..CovidVaccinations V
on D.location = V.location
and D.date = V.date
where D.continent is not  null
--order by 2,3
)

select *, (people_vaccinated / population ) *100
from PopvsVac



--TEMP TABLE
DROP  TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
people_vaccinated numeric
)
Insert into #PercentPopulationVaccinated
select D.continent,D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(bigint, V.new_vaccinations)) OVER (Partition By D.Location order by D.location, d.date) as people_vaccinated
--,(people_vaccinated / population ) *100
from Project1..CovidDeaths D
Join Project1..CovidVaccinations V
on D.location = V.location
and D.date = V.date
--where D.continent is not  null
--order by 2,3

select *, (people_vaccinated / population ) *100
from #PercentPopulationVaccinated 

-- Creating view to store data for later visualization

DROP  view if exists PercentPopulationVaccinated
create view PercentPopulationVaccinated as
select D.continent,D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(bigint, V.new_vaccinations)) OVER (Partition By D.Location order by D.location, d.date) as people_vaccinated
--,(people_vaccinated / population ) *100
from Project1..CovidDeaths D
Join Project1..CovidVaccinations V
on D.location = V.location
and D.date = V.date
where D.continent is not  null
--order by 2,3

select * from PercentPopulationVaccinated
