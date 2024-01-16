use India_census;
select * from DistrictIndiaLitracyRate;
select * from DistrictIndiaCensus;

-- 1. No of Rows into our dataset
select count(*) as Rows_count from DistrictIndiaCensus;
select count(*) as Rows_count from DistrictIndiaLitracyRate;

-- 2. Dataset for Jharkhand and Bihar
select DistrictIndiaLitracyRate.*,DistrictIndiaCensus.Area_km2,DistrictIndiaCensus.Population from DistrictIndiaCensus join DistrictIndiaLitracyRate on DistrictIndiaCensus.State = DistrictIndiaLitracyRate.state 
where DistrictIndiaCensus.state in ('Jharkhand','Bihar');

-- 3. Population of India
select SUM(Population) as Population_of_India from DistrictIndiaCensus;

-- 4. Average Growth of India
select avg(Growth) from DistrictIndiaLitracyRate;

-- 5. Average Growth % State wise
select State, avg(Growth) as Avg_growth from DistrictIndiaLitracyRate group by State order by Avg_growth desc;

-- 6. Average Sex Ratio state wise
select State, round(avg(Sex_Ratio),0) as Avg_sex_ratio from DistrictIndiaLitracyRate group by State order by Avg_sex_ratio desc;

-- 7. Average Litracy Rate state wise
select State, round(avg(Literacy),0) as Avg_literacy_ratio from DistrictIndiaLitracyRate group by State order by Avg_literacy_ratio desc;

-- 8. Top 3 states with highest average growth rate
select State, avg(Growth) as Avg_growth from DistrictIndiaLitracyRate group by State order by Avg_growth desc limit 3;

-- 9. Bottom 3 states with lowest sex ratio
select State, round(avg(Sex_Ratio),0) as Avg_sex_ratio from DistrictIndiaLitracyRate group by State order by Avg_sex_ratio limit 3;

-- 10. Top 3 and bottom 3 states according to litracy rate
select * from
(select State, avg(Literacy) as Avg_literacy_ratio from DistrictIndiaLitracyRate group by State order by Avg_literacy_ratio desc limit 3) as a
union
select * from
(select State, avg(literacy) as Avg_literacy_ratio from DistrictIndiaLitracyRate group by State order by Avg_literacy_ratio limit 3) as b;

-- 11. States starting from 'A' or 'B'
select Distinct State from DistrictIndiaLitracyRate where State like 'a%' or State like 'b%';

-- 12. States starting from 'A' and end with 'M'
select Distinct State from DistrictIndiaLitracyRate where State like 'a%m';

-- 13. No. of males and females in each district
select District, State, round((Population/(1+Sex_Ratio))*10000000,0) as No_of_males, round(((Population*Sex_Ratio)/(1+Sex_Ratio))*10000000,0) as No_of_females from 
(select a.District, a.State, a.Sex_Ratio/1000 as Sex_Ratio, b.Population from DistrictIndiaLitracyRate as a inner join DistrictIndiaCensus as b 
on a.District = b.District) as c;

-- 14. Total no of literate people in each district
select District, State, Literacy_ratio*Population as total_literate_people from
(select a.District, a.State, round(a.Literacy/100,2) as Literacy_ratio, b.Population from DistrictIndiaLitracyRate as a inner join DistrictIndiaCensus as b
on a.District = b.District) as c;

-- 15. Population in previous census
select District, State, round((Population/(1+Growth))*10000000,0) as Previous_census, Population as Current_census from
(select a.District, a.State, round(a.Growth/100,2) as Growth, b.Population from DistrictIndiaLitracyRate as a inner join DistrictIndiaCensus as b
on a.District = b.District) as c;

-- 16. Population vs Area
select Total_area/total_previous_population as area_per_population_previous, Total_area/total_current_population as area_per_current_population from
(select f.keyy, f.total_previous_population, f.total_current_population, g.Total_area from
(select '1' as keyy, sum(Previous_census) as total_previous_population, sum(Current_census) as total_current_population from
(select State, sum(Previous_census) as Previous_census, sum(Current_census) as Current_census from 
(select District, State, round((Population/(1+Growth))*10000000,0) as Previous_census, Population as Current_census from
(select a.District, a.State, round(a.Growth/100,2) as Growth, b.Population from DistrictIndiaLitracyRate as a inner join DistrictIndiaCensus as b
on a.District = b.District) as c) as d
group by State) as e) as f
inner join
(select '1' as keyy, sum(Area_km2) as Total_area from DistrictIndiaCensus) as g
on f.keyy = g.keyy) as h;

-- 17. Top 3 districts from each state with highest literacy rate
select State, District, Literacy from
(select State, District, Literacy, rank() over (partition by State order by Literacy desc) as rnk from DistrictIndiaLitracyRate) as a
where rnk in (1,2,3);