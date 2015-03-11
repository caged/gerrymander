copy (
with aggregates as (
  select
    cd.statefp as agg_state,
    cd114fp as agg_district,
    round(stddev(b03002e1), 2) as stddev_total_population,
    round(avg(b03002e1), 2) as mean_total_population,
    percentile_cont(array_agg(b03002e1), 0.05) as percentile_05,
    percentile_cont(array_agg(b03002e1), 0.95) as percentile_95
  from
    congressional_districts_114 cd
    inner join acs_2013_5yr_bg_nation acs on st_intersects(cd.geom, acs.wkb_geometry)
    inner join x03_hispanic_or_latino_origin x3 on x3.geoid = geoid_data
  group by 1,2
),
totals as (
  select
    acs.statefp as state,
    cd114fp as district,
    geoid_data,

    -- Totals
    b03002e1 as total_population,
    b03002e3 as total_white,
    b03002e4 as total_black,
    b03002e6 as total_asian,
    b03002e12 as total_hispanic,
    b03002e5 + b03002e7 + b03002e8 + b03002e9 as total_other
  from
    congressional_districts_114 cd
  inner join acs_2013_5yr_bg_nation acs on st_intersects(cd.geom, acs.wkb_geometry)
  inner join x03_hispanic_or_latino_origin x3 on x3.geoid = geoid_data
  order by 3 desc
)

select
  distinct on (geoid_data) geoid_data,
  total_population,
  total_white,
  total_black,
  total_asian,
  total_hispanic,
  total_other,

  -- Percentages
  coalesce(round(100 * total_white / nullif(total_population, 0), 2), 0.0) as percent_white,
  coalesce(round(100 * total_black / nullif(total_population, 0), 2), 0.0) as percent_black,
  coalesce(round(100 * total_asian / nullif(total_population, 0), 2), 0.0) as percent_asian,
  coalesce(round(100 * total_hispanic / nullif(total_population, 0), 2), 0.0) as percent_hispanic,
  coalesce(round(100 * total_other / nullif(total_population, 0), 2), 0.0) as percent_other,

  round(total_population - agg.mean_total_population, 2) as mean_diff,
  round(total_population / agg.stddev_total_population, 2) as stddevs
from
  totals
inner join aggregates agg on agg_district = district and agg_state = state
order by 1, 2 desc
) to stdout with csv header
