## Interest Analysis ##
-- Which interests have been present in all month_year dates in our dataset?
select interest_id, count(month_year) as total_months
from interest_metrics_clean
group by interest_id
having count(month_year) = 14;

-- Using this same total_months measure - calculate the cumulative percentage of all
-- records starting at 14 months - which total_months value passes the 90% cumulative percentage value?
with month_interest as (select interest_id, count(distinct month_year) as month_count
from interest_metrics_clean
where interest_id is not null
group by interest_id),
month_interest_count as (select month_count, count(interest_id) as count_interest
		from month_interest
        group by month_count),
 cumulative  as (select month_count, count_interest, 
		round(sum(count_interest) 
			over(order by month_count desc)* 100 / 
            (select sum(count_interest) from month_interest_count), 2) as cumulative_percentage_90
from month_interest_count
group by month_count)
select *
from cumulative
where cumulative_percentage_90 > 90;

-- If we were to remove all interest_id values which are lower than the
-- total_months value we found in the previous question - how many total data
-- points would we be removing?
with month_interest as (select interest_id, count(distinct month_year) as month_count
from interest_metrics_clean
where interest_id is not null
group by interest_id
having count(month_year) < 6)

select count(interest_id)
from interest_metrics_clean
where interest_id in (select interest_id from month_interest);


-- After removing these interests - how many unique interests are there for each month?
with month_interest as (select interest_id, count(distinct month_year) as month_count
from interest_metrics_clean
where interest_id is not null
group by interest_id
having count(month_year) < 6)
select month_year, count(distinct interest_id) as present_id, removed_id
from interest_metrics_clean
inner join (select month_year, count(interest_id) as removed_id 
			from interest_metrics_clean 
            where interest_id in (
									select interest_id 
										from month_interest) 
										group by month_year) as r
using(month_year)
where interest_id not in (select interest_id from month_interest)
group by month_year
order by month_year;

--