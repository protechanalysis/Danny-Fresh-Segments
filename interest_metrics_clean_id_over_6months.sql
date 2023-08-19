drop table if exists fresh_segments.interest_metrics_clean_6;
create table fresh_segments.interest_metrics_clean_6  
with month_interest as (select interest_id, count(distinct month_year) as month_count
from interest_metrics_clean
where interest_id is not null
group by interest_id
having count(month_year) < 6)

select *
from interest_metrics_clean
where interest_id not in (select interest_id from month_interest);

-- which are the top 10 and bottom 10 interests which have the largest
-- composition values in any month_year? Only use the maximum composition value
-- for each interest but you must keep the corresponding month_year
## top 10 for each month
with ranking_top as (
select month_year, interest_id, composition, row_number() over(partition by month_year order by composition desc) as rank1
from interest_metrics_clean_6)
select month_year, interest_id, composition
from ranking
where rank1 <= 10;

## bottom 10 fro each month
with ranking_bottom as (
select month_year, interest_id, composition, row_number() over(partition by month_year order by composition asc) as rank1
from interest_metrics_clean_6)
select month_year, interest_id, composition
from ranking_bottom
where rank1 <= 10;

-- Which 5 interests had the lowest average ranking value?
select interest_id, interest_name, avg(ranking) as lowest_avg_ranking
from interest_metrics_clean_6
inner join interest_map on interest_id = id
group by interest_id, interest_name
order by low_avg_ranking desc
limit 5;

-- Which 5 interests had the largest standard deviation in their percentile_ranking value?
select interest_id, interest_name, round(stddev_samp(percentile_ranking), 2) as top_std_percentile
from interest_metrics_clean_6
inner join interest_map on interest_id = id
group by interest_id, interest_name
order by top_std_percentile  desc
limit 5;

--  For the 5 interests found in the previous question - what was minimum and
-- maximum percentile_ranking values for each interest and its corresponding
-- year_month value? Can you describe what is happening for these 5 interests?
## minimum percentile_ranking
with std_ranking as (
select interest_id, interest_name, round(stddev_samp(percentile_ranking), 2) as top_std_percentile
from interest_metrics_clean_6
inner join interest_map on interest_id = id
group by interest_id, interest_name
order by top_std_percentile  desc
limit 5),
min as (select interest_id, min(percentile_ranking) as min_percentile_ranking
from interest_metrics_clean_6
where interest_id in ( select interest_id from std_ranking)
group by interest_id)
select month_year, m.interest_id, min_percentile_ranking
from min as m
inner join interest_metrics_clean_6 as c
on m.interest_id = c.interest_id and min_percentile_ranking = percentile_ranking;

## maximum percentile_ranking
with std_ranking as (
select interest_id, interest_name, round(stddev_samp(percentile_ranking), 2) as top_std_percentile
from interest_metrics_clean_6
inner join interest_map on interest_id = id
group by interest_id, interest_name
order by top_std_percentile  desc
limit 5),
max as (select interest_id, max(percentile_ranking) as min_percentile_ranking
from interest_metrics_clean_6
where interest_id in ( select interest_id from std_ranking)
group by interest_id)
select month_year, m.interest_id, min_percentile_ranking
from max as m
inner join interest_metrics_clean_6 as c
on m.interest_id = c.interest_id and min_percentile_ranking = percentile_ranking;

---- 
