-- Data Exploration and Cleansing
-- Update the fresh_segments.interest_metrics table by modifying the
-- month_year column to be a date data type with the start of the month
drop table if exists fresh_segments.interest_metrics_clean;
create table fresh_segments.interest_metrics_clean as 
select str_to_date(concat('01-', month_year), '%d-%m-%Y') as month_year, 
	   interest_id, composition, index_value, ranking, percentile_ranking
from interest_metrics
where month_year is not null;


-- What is count of records in the fresh_segments.interest_metrics for each
-- month_year value sorted in chronological order (earliest to latest) with the null
-- values appearing first?
select month_year , count(*) as counts_of_record
from interest_metrics_clean
group by month_year
order by month_year;

-- What do you think we should do with these null values in the
-- fresh_segments.interest_metrics
-- ## the null value as to be exclude using interest_id column to remove the null
select *
from interest_metrics_clean
where interest_id is not null;

-- How many interest_id values exist in the fresh_segments.interest_metrics
-- table but not in the fresh_segments.interest_map table? What about the other way around?
with check_id as (
	select distinct interest_id, id
	from interest_map
	left join  interest_metrics_clean on id = interest_id)
select (select count(*)
from check_id
where id is null) as interest_id_not_in_map, ( select count(*) 
from check_id
where interest_id is null) as id_not_in_metrics;

--  Summarise the id values in the fresh_segments.interest_map by its total record count in this table
select id, count(*) as n
from interest_map
group by id;

-- What sort of table join should we perform for our analysis and why? Check your
-- logic by checking the rows where interest_id = 21246 in your joined output and
-- include all columns from fresh_segments.interest_metrics and all columns
-- from fresh_segments.interest_map except from the id column.
-- ## inner join to all data in the interest matrics that is present in interest map
select month_year, interest_id, composition, 
	index_value, ranking, percentile_ranking,
	interest_name, interest_summary, created_at, last_modified
from interest_metrics_clean
inner join interest_map on interest_id = id;
-- checking interest_id = 21246
select month_year, interest_id, composition, 
	index_value, ranking, percentile_ranking,
	interest_name, interest_summary, created_at, last_modified
from interest_metrics_clean
inner join interest_map on interest_id = id
where interest_id = 21246;

-- Are there any records in your joined table where the month_year value is before the
-- created_at value from the fresh_segments.interest_map table? Do you think
-- these values are valid and why?
select *
from ( select month_year, interest_id, composition, 
			index_value, ranking, percentile_ranking,
			interest_name, interest_summary, created_at, last_modified
		from interest_metrics_clean
		inner join interest_map on interest_id = id) as subquery
where month_year < created_at
## this values are not certain because we created the month start date 
