-- What is the top 10 interests by the average composition for each month
-- What is the top 10 interests by the average composition for each month?
with ranking_avg as (
		select month_year, interest_id, interest_name, 
			round(composition/index_value, 2) as average_composition,
            row_number() over(partition by month_year 
					order by round(composition/index_value, 2) desc) as rank2
		from interest_metrics_clean_6
        inner join interest_map on interest_id = id)
select month_year, interest_id, interest_name, average_composition
from ranking_avg
where rank2 <= 10;

-- For all of these top 10 interests - which interest appears the most often?
with ranking_avg as (
		select month_year, interest_id, interest_name, 
			round(composition/index_value, 2) as average_composition,
            row_number() over(partition by month_year 
					order by round(composition/index_value, 2) desc) as rank2
		from interest_metrics_clean_6
        inner join interest_map on interest_id = id),
top_10_avg_comp as (
		select month_year, interest_id, interest_name, average_composition
		from ranking_avg
		where rank2 <= 10)
select interest_id, interest_name, count(*) as num_of_appearance
from top_10_avg_comp
group by interest_id, interest_name
order by num_of_appearance desc
limit 3;

-- What is the average of the average composition for the top 10 interests for each month?
with ranking_avg as (
		select month_year, interest_id, interest_name, 
			round(composition/index_value, 2) as average_composition,
            row_number() over(partition by month_year 
					order by round(composition/index_value, 2) desc) as rank2
		from interest_metrics_clean_6
        inner join interest_map on interest_id = id),
top_10_avg_comp as (
	select month_year, interest_id, interest_name, average_composition
	from ranking_avg
	where rank2 <= 10)
select month_year, round(avg(average_composition), 2) as top_10_monthly_avg
from top_10_avg_comp
group by month_year;

-- What is the 3 month rolling average of the max average composition value from
-- September 2018 to August 2019
with max_avg_composition as (
			select month_year, round(max(composition/index_value), 2) as max_index_composition
			from interest_metrics_clean_6
			group by month_year),
rolling_avg as (
			select c.month_year, interest_name, max_index_composition, 
				round(avg(max_index_composition) 
					over(order by month_year rows between 2 preceding and current row),2) as 3_month_moving_avg
			from interest_metrics_clean_6 as m
			join max_avg_composition as c on m.month_year = c.month_year 
			join interest_map on m.interest_id = id
			where round(composition/index_value, 2) = max_index_composition),
rolling_avg_1 as (
			select month_year, interest_name,
					max_index_composition, 3_month_moving_avg, 
                    concat(lag(interest_name) over(), ': ', lag(max_index_composition) over()) as 1_months_ago
			from rolling_avg),
rolling_avg_2 as (
			select month_year, interest_name,
					max_index_composition, 3_month_moving_avg,
					lag(1_months_ago) over() as 2_months_ago
			from rolling_avg_1)
select *
from rolling_avg_2
where month_year between '2018-09-01' and '2019-08-01';