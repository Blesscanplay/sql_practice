use portfolio_project;
select * from covid_deaths
where continent is not null
order by 3,4;

-- select * from covid_vaccine
-- order by 3,4

-- select data to use
select location,date,total_cases,new_cases,total_deaths, population
 from covid_deaths
 order by 1,2;
 
 -- finding out how many rows are empty under total deaths
 select count(total_deaths) from covid_deaths
 where nullif(trim(total_deaths),'') is  null;
 
 -- i decided to fill the null values with 0
 update covid_deaths set total_deaths = '0'
 where total_deaths ='';
 
  update covid_vaccine set new_vaccinations = '0'
 where new_vaccinations ='';
 
 -- loking at total cases vs total deaths
 -- shows the likelyhood of dying from covid in a country
 select location,date ,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
 from covid_deaths
 where location like "nigeria"
 order by location, date_format(date,"%d-%m-%y") desc;

-- looking at the total cases vs population
-- shows the percentage of population that has covid
 select location,date ,total_cases,population, (total_cases/population)*100 as case_percentage
 from covid_deaths
 where location like "nigeria"
 order by location, date_format(date,"%d-%m-%y") desc;
 
 -- what location has the highest infection rate compared to population
 select location, population, max(total_cases) as HighestInfectionCount,
 max((total_cases/population))*100 as infection_percentage
 from covid_deaths
 -- where location like "nigeria"
 group by location,population
 order by infection_percentage desc;
 
 -- break down by continent
 select continent,max(total_deaths) as TotalDeathCount
 from covid_deaths
 -- where location like "nigeria"
 where continent is not null
 group by continent
 order by TotalDeathCount desc;
 
 -- showing the locations with the highest death count per population 
select location,max(total_deaths) as TotalDeathCount
 from covid_deaths
 -- where location like "nigeria"
 where continent is not null
 group by location
 order by TotalDeathCount desc;
 
  -- showing the continents with the highest death count per population 
  select continent,max(total_deaths) as TotalDeathCount
 from covid_deaths
 -- where location like "nigeria"
 where continent is not null
 group by continent
 order by TotalDeathCount desc;
 
 
 -- global numbers
 select  sum(new_cases) as total_cases, sum(new_deaths) as total_deaths ,
 sum(new_deaths)/ sum(new_cases)*100 as death_percentage
 from covid_deaths
--  where location like "nigeria"
where continent is not null
-- group by date
 order by location, date_format(date,"%d-%m-%y") ;
 
 -- total population vs vaccination
 select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
 , sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)
 as rollingpeoplevaccinated
 -- (rollingpeoplevaccinated/population)*100
 from covid_deaths dea
 join covid_vaccine vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3;
 
 -- use CTE
 with popvsvac(continent,location, date, population, new_vaccinations, rollingpeoplevaccinated)
 as
 (
 select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
 , sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)
 as rollingpeoplevaccinated
 -- (rollingpeoplevaccinated/population)*100
 from covid_deaths dea
 join covid_vaccine vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 -- order by 2,3
 )
 select * ,(rollingpeoplevaccinated/population)*100
 from popvsvac;
 
 -- temp table
 drop table if exists percentpopulationvaccinated;
 create table percentpopulationvaccinated
(
 continent nvarchar(255),
 location nvarchar(255),
 Date date,
 population numeric,
 new_vaccinations numeric,
 rollingpeoplevaccinated numeric
 );
 
 alter table  percentpopulationvaccinated
 modify column date text;
 
insert into percentpopulationvaccinated
(
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
 , sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)
 as rollingpeoplevaccinated
 -- (rollingpeoplevaccinated/population)*100
 from covid_deaths dea
 join covid_vaccine vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 -- order by 2,3
 );
 select * ,(rollingpeoplevaccinated/population)*100
 from percentpopulationvaccinated;
 

 