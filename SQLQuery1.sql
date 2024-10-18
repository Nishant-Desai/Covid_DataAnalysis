-- Queries on Covid death table
select * from CovidProject..CovidDeaths
order by 3,4;

select location, date, total_cases, total_deaths, (convert(float, total_deaths)/NULLIF(convert(float, total_cases), 0)*100) as death_percent from CovidProject..CovidDeaths
order by 1,2;

select location, population, max(total_cases) as cases, max(total_deaths) as deaths, (convert(float, max(total_deaths))/NULLIF(convert(float, population), 0)*100) as population_deathrate from CovidProject..CovidDeaths
where continent is not null
group by location, population
order by population_deathrate desc;

--Queries on Covid vaccination table
select * from CovidProject..CovidVaccinations
where continent is not null
order by 3,4;

select DISTINCT location, median_age, diabetes_prevalence from CovidProject..CovidVaccinations
--where median_age <25
order by median_age;

--Queries on both tables
select * from CovidProject..CovidDeaths d
join CovidProject..CovidVaccinations v
on d.location = v.location and d.date = v.date;

with populationVaxxed_CTE (continent, location, date, population, new_vaccinations, sum_vax) as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as float)) over (partition by d.location order by d.location, d.date) as sum_vax from CovidProject..CovidDeaths d 
join CovidProject..CovidVaccinations v
on d.location = v.location and d.date = v.date
)
select *, (sum_vax / cast(population as float)) *100 as percent_populationVaxxed
from populationVaxxed_CTE;

--create view VaxxedVsDeath as
--select d.location, d.population, max(convert(int, v.people_vaccinated)) as vaxed_people, max(d.total_deaths) as sum_deaths from CovidProject..CovidDeaths d
--join CovidProject..CovidVaccinations v
--on d.location = v.location
--group by d.location, d.population;

drop view if exists VaxxedVsDeath;

create view VaxxedVsDeath as
select d.location, d.population, max(v.people_vaccinated) as vaxed_people, max(d.total_deaths) as sum_deaths, (max(v.people_vaccinated) / cast(d.population as float)) *100 as percent_vax, (max(d.total_deaths)/ cast(d.population as float))*100 as percent_death from CovidProject..CovidDeaths d
join CovidProject..CovidVaccinations v
on d.location = v.location
group by d.location, d.population;

select * from VaxxedVsDeath
order by location;