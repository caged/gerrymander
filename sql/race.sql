with aggregates as (
  select
    cd114fp as district,
    stddev(b03002e1) as stddev_total_population,
    avg(b03002e1) as mean_total_population
  from
    congressional_districts_114 cd
    inner join acs_2013_5yr_bg_nation acs on st_intersects(cd.geom, acs.wkb_geometry)
    inner join x03_hispanic_or_latino_origin x3 on x3.geoid = geoid_data
  where
    cd.statefp = '12'
  group by 1
)

select
  acs.statefp as state,
  cd114fp as district,
  -- geoid_data,
  b03002e1 as total_population,
  b03002e3 as total_white,
  b03002e4 as total_black,
  b03002e6 as total_asian,
  b03002e12 as total_hispanic,
  b03002e5 + b03002e7 + b03002e8 + b03002e9 as total_other,
  round(b03002e1 - mean_total_population, 2) as mean_diff,
  b03002e1 / stddev_total_population as stddevs,
  agg.mean_total_population
from
  congressional_districts_114 cd
inner join acs_2013_5yr_bg_nation acs on st_intersects(cd.geom, acs.wkb_geometry)
inner join x03_hispanic_or_latino_origin x3 on x3.geoid = geoid_data
inner join aggregates agg on agg.district = cd114fp
where
  acs.statefp = '12' and
  b03002e1 > 0
order by 10 asc
