--******************************Summary*******************************
-- The following is a SQL exploration project about COVID 19
-- We explore the COVID19 dataset and create breakdowns based on cases, deaths and vaccinations
-- We will also use these queries for a Tableau project. 

-- we also explore the following SQL techiques:
-- Clauses:
	--	with
	--	select
	--	from
	--	where
	--	group by
	--	order by
	--	partition
-- Window Functions:
	--	max
	--	sum
	--	cast
-- Joins
-- Common table expresions
-- Temp Tables
-- Views


--******************************References*******************************
--------------https://ourworldindata.org/covid-deaths
--------------Data was downloaded on 2/12/2022


--*************************************************************************





--1
--select data that we are going to be using

select
--top 10 
location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1, 2

--2
-- total cases vs total deaths, shows likelihood of dying from covid

select
--top 10 
location, date, total_cases, total_deaths, population, total_deaths/total_cases*100 as DeathPercentage
from CovidDeaths
--where location = 'united states'
order by 1, 2

--3
-- total cases vs population, shows what percentage got covid

select
--top 10 
location, date, population, total_cases, total_cases/population*100 as PercentPopulationInfected
from CovidDeaths
--where location = 'united states'
order by 1, 2


--4
-- highest infection rate compared to population, 
-- China has the highest population and lowest percent of population infected
-- United States at 23.3% , percent of population infected

select
--top 10 
location, population, max(total_cases) as HighestInfectionCount, max(total_cases)/population*100 as PercentPopulationInfected
from CovidDeaths
group by location, population
--where location = 'united states'
order by 4 desc

--4.2
-- highest infection rate compared to population, 
-- China has the highest population and lowest percent of population infected
-- United States at 23.3% , percent of population infected

select
--top 10 
location, date, population, max(total_cases) as HighestInfectionCount, max(total_cases)/population*100 as PercentPopulationInfected
from CovidDeaths
group by location, population, date
having location = 'united states'
order by 1, 2 asc

--5
-- total death count by country

select
--top 10 
continent, location, cast(max(total_deaths) as int) as TotalDeathCount
from CovidDeaths
where continent is not null 
group by location, continent
--where location = 'united states'
order by TotalDeathCount desc


--6
--  total death count by continent

select
--top 10 
location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
and location not in (
'Upper middle income',
'High income',
'Lower middle income',
'Low income',
'European Union',
'International')
group by location
order by TotalDeathCount desc

--7
-- continents with highest death count

select
--top 10 
continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
and continent not in (
'Upper middle income',
'High income',
'Lower middle income',
'Low income',
'European Union',
'International')
group by continent
order by TotalDeathCount desc


--8
-- Death Percentage by Date

  select date, sum(total_cases) TotalCases, sum(cast(total_deaths as int)) TotalDeaths, (sum(cast(total_deaths as int))/sum(total_cases)*100) as DeathPercentage
  from CovidDeaths
  where continent is not null
  group by date
  order by 4 desc 


  --9
-- total cases, total deaths, world wide, 2% death rate

 select max(total_cases) TotalCases, max(cast(total_deaths as int)) TotalDeaths, (max(cast(total_deaths as int))/max(total_cases)*100) as DeathPercentage
  from CovidDeaths
  where location = 'world'
 
 
 --10
 -- total population vs total vaccinations by location

select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over (partition by d.location) TotalVaccinationsByLocation
from CovidDeaths d
join CovidVaccinations v on d.location = v.location and d.date = v.date
where d.continent is not null 
order by 2,3

 --11
 -- Total Vaccinations by Location, Vaccination Percentage

select distinct
d.continent, d.location, population, sum(cast(v.new_vaccinations as bigint)) over (partition by d.location) TotalVaccinationsByLocation,
(sum(cast(v.new_vaccinations as bigint)) over (partition by d.location) / population)*100 as VaccinationPercentage
from CovidDeaths d
join CovidVaccinations v on d.location = v.location and d.date = v.date
where d.continent is not null 
--group by population
order by 2,3

--12
 -- total population vs total vaccinations by location and date

select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location, d.date) CumulativeVaccinations
from CovidDeaths d
join CovidVaccinations v on d.location = v.location and d.date = v.date
where d.continent is not null 
order by 2,3


--13
-- common table expression
-- get cumulative vaccinations relative to population percentage

with q1 as (

select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location, d.date) CumulativeVaccinations
from CovidDeaths d
join CovidVaccinations v on d.location = v.location and d.date = v.date
where d.continent is not null 
--order by 2,3

)

select *, q1.CumulativeVaccinations/q1.population*100 as CumulativeVaccinationsPercentage from q1

--14
-- Temp Table, 
-- get cumulative vaccinations relative to population percentage
-- same exact example from above using common table expression, but converted here using temp tables

select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location, d.date) CumulativeVaccinations
into #q1
from CovidDeaths d
join CovidVaccinations v on d.location = v.location and d.date = v.date
where d.continent is not null 
--order by 2,3 
select *, #q1.CumulativeVaccinations/#q1.population*100 as CumulativeVaccinationsPercentage 
from #q1
drop table #q1

--15
-- create view 

create view CumulativeVaccinations as 
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location, d.date) CumulativeVaccinations
from CovidDeaths d
join CovidVaccinations v on d.location = v.location and d.date = v.date
where d.continent is not null;
--order by 2,3;

--16
-- query view we create in previous step

select * from CumulativeVaccinations


Select * from CovidDeaths where location = 'world'
order by date