--looking at total cases vs total deaths
select country, date, total_cases, total_deaths, CASE WHEN COALESCE(total_cases, 0) = 0 THEN 0 ELSE (total_deaths/total_cases)*100 END AS DeathPercentage
from PortfolioProjectCovid..CovidDeaths
where country like 'united states'
order by country, date

--looking at total cases vs population
select country, date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
from PortfolioProjectCovid..CovidDeaths
where country like 'united states'
order by country, date

--looking at countries with highest infection rate compared to population
select country, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS InfectedPopulationPercentage
from PortfolioProjectCovid..CovidDeaths
--where country like 'united states'
group by country, population
order by InfectedPopulationPercentage desc

--showing countries with the highest death count per population
select country, MAX(total_deaths) AS TotalDeathCount--, MAX((total_deaths/population)*100) AS InfectedPopulationPercentage
from PortfolioProjectCovid..CovidDeaths
where continent is not null
group by country
order by TotalDeathCount desc

--showing continents with the highest death count per population
select continent, MAX(total_deaths) AS TotalDeathCount, MAX((total_deaths/population)*100) AS InfectedPopulationPercentage
from PortfolioProjectCovid..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--continents with the highest death count
select continent, MAX(total_deaths) AS TotalDeathCount
from PortfolioProjectCovid..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers
select sum(new_cases) AS TotalNewCases, sum(new_deaths) AS TotalNewDeaths, CASE WHEN COALESCE(new_cases, 0) = 0 THEN 0 ELSE sum(new_deaths)/sum(new_cases)*100 END AS DeathPercentage
from PortfolioProjectCovid..CovidDeaths
where continent is not null
AND new_cases IS NOT NULL
group by new_cases
order by date

--Loooking at total population vs vaccinations
select top 10000 cd.continent, cd.country, cd.date, cd.population, cv.new_vaccinations, sum(convert(bigint, cv.new_vaccinations)) over (partition by cd.country order by cd.date) as RollingVaccinated
from PortfolioProjectCovid..CovidDeaths cd
join PortfolioProjectCovid..CovidVaccinations cv
on cd.country = cv.country
and cd.date = cv.date
where cd.continent is not null
--group by cd.continent, cd.country, cd.date, cd.population, cv.new_vaccinations
order by 2,3

--CTE
;WITH PopvsVac (Continent, Country, Date, Population, NewVaccinations, RollingVaccinated)
AS
(
select cd.continent, cd.country, cd.date, cd.population, cv.new_vaccinations, sum(convert(float, cv.new_vaccinations)) over (partition by cd.country order by cd.date) as RollingVaccinated
from PortfolioProjectCovid..CovidDeaths cd
join PortfolioProjectCovid..CovidVaccinations cv
on cd.country = cv.country
and cd.date = cv.date
where cd.continent is not null
--group by cd.continent, cd.country, cd.date, cd.population, cv.new_vaccinations
)
select *, (RollingVaccinated/Population)*100 AS Percentage
from PopvsVac
order by Country, Date

--Create temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255), Country nvarchar(255), Date datetime, Population float, NewVaccinations float, RollingVaccinated float
)

insert into #PercentPopulationVaccinated
select cd.continent, cd.country, cd.date, cd.population, cv.new_vaccinations, sum(convert(float, cv.new_vaccinations)) over (partition by cd.country order by cd.date) as RollingVaccinated
from PortfolioProjectCovid..CovidDeaths cd
join PortfolioProjectCovid..CovidVaccinations cv
on cd.country = cv.country
and cd.date = cv.date
where cd.continent is not null

select * from #PercentPopulationVaccinated
order by Country, date

--Create views
;
create or alter view v_PercentPopulationVaccinated as
select cd.continent, cd.country, cd.date, cd.population, cv.new_vaccinations, sum(convert(float, cv.new_vaccinations)) over (partition by cd.country order by cd.date) as RollingVaccinated
from PortfolioProjectCovid..CovidDeaths cd
join PortfolioProjectCovid..CovidVaccinations cv
on cd.country = cv.country
and cd.date = cv.date
where cd.continent is not null

select * from v_PercentPopulationVaccinated