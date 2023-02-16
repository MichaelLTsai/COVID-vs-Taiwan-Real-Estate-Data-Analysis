-- Explore the database
SELECT *
FROM owid_covid_data_clean
WHERE continent is not null
ORDER BY 3,4

-- Clean Data
-- Exclude the special category like "Asia", "High Income", "World"
SELECT *
FROM owid_covid_data_clean
WHERE continent is not null
ORDER BY 3,4

-- Select the data that we are going use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM owid_covid_data_clean
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float)/ CAST(total_cases AS float))*100  AS Death_Rate
FROM owid_covid_data_clean
WHERE continent is not null
ORDER BY 1,2

-- Showing Deathrate in my country
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float)/ CAST(total_cases AS float))*100  AS Death_Rate
FROM owid_covid_data_clean
WHERE location='Taiwan'
ORDER BY 2

-- Looking at Total Cases vs population
-- Showing COVID infected rate
SELECT location, date, total_cases, population, (CAST(total_cases AS float)/ CAST(population AS float))*100  AS Infected_Rate
FROM owid_covid_data_clean
WHERE continent is not null
ORDER BY 1,2

-- Looking at Country with highest infection rate compared to population
SELECT location, population, Max(total_cases) as HighestInfection, max(CAST(total_cases AS float)/ CAST(population AS float))*100  AS Highest_Infection_Rate
FROM owid_covid_data_clean
WHERE continent is not null
GROUP BY location, population
ORDER BY Highest_Infection_Rate DESC

-- Showing Countries with Highest Death Count per Population
SELECT location, Max(cast(total_deaths as float)) AS HighestDeathCount
FROM owid_covid_data_clean
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Showing Contients with Highest Death Count per Population
SELECT continent, Max(cast(total_deaths as float)) AS HighestDeathCount
FROM owid_covid_data_clean
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- Showing the global deathrate per day, order by the highest deathrate date.
SELECT date, SUM(new_cases) as DailyNewCases, SUM(CAST(new_deaths as float)) as DailyDeathCount, SUM(CAST(new_deaths as float))/ SUM(new_cases) *100 as DailyDeathRate
FROM owid_covid_data_clean
WHERE continent is not null
GROUP BY date
ORDER BY DailyDeathRate DESC

-- Looking at the realtion between total population vs vaccinations 
SELECT c1.continent, c1.location, c1.date,  c1.population, c2.new_vaccinations,
SUM(CAST(c2.new_vaccinations as bigint)) OVER (partition by c1.location ORDER BY c1.location, c1.date) AS RollingVaccinated
FROM owid_covid_data_clean c1
JOIN owid_covid_data_clean c2
	ON c1.location = c2.location
	AND c1.date = c2.date
WHERE c1.continent is not null
ORDER BY 2, 3

-- USE CTE
With PopvsVac (Continent, location, date , population, New_vaccinations, RollingVaccinated)
as 
(
SELECT c1.continent, c1.location, c1.date,  c1.population, c2.new_vaccinations,
SUM(CAST(c2.new_vaccinations as int)) OVER (partition by c1.location ORDER BY c1.location, c1.date) AS RollingVaccinated
FROM owid_covid_data_clean c1
JOIN owid_covid_data_clean c2
	ON c1.location = c2.location
	AND c1.date = c2.date
WHERE c1.continent is not null
)
SELECT *, (RollingVaccinated/population) * 100 as RollingVaccinatedPersonPersentage
FROM PopvsVac


-- Store in a Temp TABLE
DROP TABLE IF EXISTS VaccinatedPeoplePersentage;
CREATE TABLE VaccinatedPeoplePersentage
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population NUMERIC,
new_vaccinations numeric,
RollingVaccinated numeric,
RollinVaccinatedperPerson NUMERIC
);
INSERT INTO  VaccinatedPeoplePersentage
With PopvsVac (Continent, location, date , population, New_vaccinations, RollingVaccinated)
as 
(
SELECT c1.continent, c1.location, c1.date,  c1.population, c2.new_vaccinations,
SUM(CAST(c2.new_vaccinations as int)) OVER (partition by c1.location ORDER BY c1.location, c1.date) AS RollingVaccinated
FROM owid_covid_data_clean c1
JOIN owid_covid_data_clean c2
	ON c1.location = c2.location
	AND c1.date = c2.date
WHERE c1.continent is not null
)
SELECT *, (RollingVaccinated/population) * 100 as RollingVaccinatedPersonPersentage
FROM PopvsVac


-- Throw the temp table into VIEW to store data for later visulizations
Create View  VaccinatedPeoplePersentageView as
SELECT c1.continent, c1.location, c1.date,  c1.population, c2.new_vaccinations,
SUM(CAST(c2.new_vaccinations as int)) OVER (partition by c1.location ORDER BY c1.location, c1.date) AS RollingVaccinated
FROM owid_covid_data_clean c1 
JOIN owid_covid_data_clean c2
ON c1.location = c2.location
	AND c1.date = c2.date
WHERE c1.continent is not null

-- Looking at Taiwan total death and vaccinated for visualizations
SELECT c1.location, c1.date, c1.new_cases, c2.new_vaccinations,
SUM(CAST(c2.new_vaccinations as bigint)) OVER (partition by c1.location ORDER BY c1.location, c1.date) AS RollingVaccinated
FROM owid_covid_data_clean c1
JOIN owid_covid_data_clean c2
	ON c1.location = c2.location
	AND c1.date = c2.date
WHERE c1.continent is not null and c1.location = 'taiwan'
ORDER BY 2, 3


With TaiwanStatus (location, date , New_case, New_vaccinations, RollingVaccinated)
as 
(
SELECT c1.location, c1.date, c1.new_cases, c2.new_vaccinations,
SUM(CAST(c2.new_vaccinations as bigint)) OVER (partition by c1.location ORDER BY c1.location, c1.date) AS RollingVaccinated
FROM owid_covid_data_clean c1
JOIN owid_covid_data_clean c2
	ON c1.location = c2.location
	AND c1.date = c2.date
WHERE c1.continent is not null and c1.location = 'taiwan'
)
SELECT CAST(CAST(year(date) AS VARCHAR(4)) + '-' + CAST(month(date) AS VARCHAR(4)) AS DATE) as MonthStatus,  AVG(New_case) as AvgMonthNewCase, SUM(RollingVaccinated) as SumMonthRolloingVaccinated
FROM TaiwanStatus
GROUP BY CAST(CAST(year(date) AS VARCHAR(4)) + '-' + CAST(month(date) AS VARCHAR(4)) AS DATE)
ORDER BY 1



With TaiwanStatus (location, date , New_case, New_vaccinations, RollingVaccinated)
as 
(
SELECT c1.location, c1.date, c1.new_cases, c2.new_vaccinations,
SUM(CAST(c2.new_vaccinations as bigint)) OVER (partition by c1.location ORDER BY c1.location, c1.date) AS RollingVaccinated
FROM owid_covid_data_clean c1
JOIN owid_covid_data_clean c2
	ON c1.location = c2.location
	AND c1.date = c2.date
WHERE c1.continent is not null and c1.location = 'taiwan'
)
SELECT DATEPART(YEAR, date) as TaiwanYear, DATEPART(MONTH, date) as TaiwanMonth,  SUM(New_case) as MonthNewCase, SUM(RollingVaccinated) as MonthRolloingVaccinated
FROM TaiwanStatus
GROUP BY DATEPART(YEAR, date), DATEPART(MONTH, date)
ORDER BY 1, 2