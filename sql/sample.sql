with
oregon_blockgroups as (
  select
    geoid_data,
    namelsad as name,
    wkb_geometry as geom
  from
    acs_2013_5yr_bg_nation
  where
    statefp = '12'
),
oregon_congressional_districts as (
  select
    geom,
    geoid,
    namelsad as name
  from
    congressional_districts_114
  where
    statefp = '12'
)

-- ogc_fid | short_name |                                                                                      full_name
-- ---------+------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--     165 | b02001e1   | RACE:  Total:  Total population -- (Estimate)
--     166 | b02001m1   | RACE:  Total:  Total population -- (Margin of Error)
--     167 | b02001e2   | RACE:  White alone:  Total population -- (Estimate)
--     168 | b02001m2   | RACE:  White alone:  Total population -- (Margin of Error)
--     169 | b02001e3   | RACE:  Black or African American alone:  Total population -- (Estimate)
--     170 | b02001m3   | RACE:  Black or African American alone:  Total population -- (Margin of Error)
--     171 | b02001e4   | RACE:  American Indian and Alaska Native alone:  Total population -- (Estimate)
--     172 | b02001m4   | RACE:  American Indian and Alaska Native alone:  Total population -- (Margin of Error)
--     173 | b02001e5   | RACE:  Asian alone:  Total population -- (Estimate)
--     174 | b02001m5   | RACE:  Asian alone:  Total population -- (Margin of Error)
--     175 | b02001e6   | RACE:  Native Hawaiian and Other Pacific Islander alone:  Total population -- (Estimate)
--     176 | b02001m6   | RACE:  Native Hawaiian and Other Pacific Islander alone:  Total population -- (Margin of Error)
--     177 | b02001e7   | RACE:  Some other race alone:  Total population -- (Estimate)
--     178 | b02001m7   | RACE:  Some other race alone:  Total population -- (Margin of Error)
--     179 | b02001e8   | RACE:  Two or more races:  Total population -- (Estimate)
--     180 | b02001m8   | RACE:  Two or more races:  Total population -- (Margin of Error)
--     181 | b02001e9   | RACE:  Two or more races:  Two races including Some other race:  Total population -- (Estimate)
--     182 | b02001m9   | RACE:  Two or more races:  Two races including Some other race:  Total population -- (Margin of Error)
--     183 | b02001e10  | RACE:  Two or more races:  Two races excluding Some other race, and three or more races:  Total population -- (Estimate)
--     184 | b02001m10  | RACE:  Two or more races:  Two races excluding Some other race, and three or more races:  Total population -- (Margin of Error)
--     185 | b02008e1   | WHITE ALONE OR IN COMBINATION WITH ONE OR MORE OTHER RACES:  Total:  White alone or in combination with one or more other races -- (Estimate)
select
  cd.name,
  min(b02001e3) as min,
  max(b02001e3) as max,
  stddev(b02001e3) as stddev,
  median(b02001e3) as median,
  avg(b02001e3) as mean,
  percentile_cont(array_agg(b02001e3), 0.25) as percentile_05,
  percentile_cont(array_agg(b02001e3), 0.95) as percentile_95
from
  oregon_congressional_districts cd
inner join oregon_blockgroups bg on st_intersects(cd.geom, bg.geom)
inner join x02_race x on x.geoid = geoid_data
group by 1
order by 3 desc;
