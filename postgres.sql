CREATE TABLE percentile_test (
numbers integer
);

-- Check the created table
SELECT * FROM percentile_test;

-- Insert values into the table
INSERT INTO percentile_test (numbers) VALUES
(1), (2), (3), (4), (5), (6);

-- Calculate the percentiles
SELECT numbers,
	percentile_cont(0.5) WITHIN GROUP (ORDER BY numbers) AS percentile_cont,
	percentile_disc(0.5) WITHIN GROUP (ORDER BY numbers) AS percentile_disc
FROM percentile_test;


CREATE TABLE us_counties_2010 (
geo_name varchar(90),
state_us_abbreviation varchar(2),
summary_level varchar(3),
region smallint,
division smallint,
state_fips varchar(2),
county_fips varchar(3),
area_land numeric,
area_water bigint,
population_count_100_percent integer,
housing_unit_count_100_percent integer,
internal_point_lat numeric(10,7),
internal_point_lon numeric(10,7),
p0010001 integer,
p0010002 integer,
p0010003 integer,
p0010004 integer,
p0010005 integer,
p0010006 integer,
p0010007 integer,
p0010008 integer,
p0010009 integer,
p0010010 integer,
p0010011 integer,
p0010012 integer,
p0010013 integer,
p0010014 integer,
p0010015 integer,
p0010016 integer,
p0010017 integer,
p0010018 integer,
p0010019 integer,
p0010020 integer,
p0010021 integer,
p0010022 integer,
p0010023 integer,
p0010024 integer,
p0010025 integer,
p0010026 integer,
p0010047 integer,
p0040063 integer,
p0040070 integer,
p0020001 integer,
p0020002 integer,
p0020003 integer,
p0020004 integer,
p0020005 integer,
p0020006 integer,
p0020007 integer,
p0020008 integer,
p0020009 integer,
p0020010 integer,
p0020011 integer,
p0020012 integer,
p0020028 integer,
p0020049 integer,
p0020065 integer,
p0020072 integer,
p0030001 integer,
p0030002 integer,
p0030003 integer,
p0030004 integer,
p0030005 integer,
p0030006 integer,
p0030007 integer,
p0030008 integer,
p0030009 integer,
p0030010 integer,
p0030026 integer,
p0030047 integer,
p0030063 integer,
p0030070 integer,
p0040001 integer,
p0040002 integer,
p0040003 integer,
p0040004 integer,
p0040005 integer,
p0040006 integer,
p0040007 integer,
p0040008 integer,
p0040009 integer,
p0040010 integer,
p0040011 integer,
p0040012 integer,
p0040028 integer,
p0040049 integer,
p0040065 integer,
p0040072 integer,
h0010001 integer,
h0010002 integer,
h0010003 integer
);

COPY us_counties_2010
FROM 'C:\us_counties_2010.csv'
WITH (FORMAT CSV, HEADER);

SELECT sum(p0010001) AS "County Sum",
round(avg(p0010001), 0) AS "County Average",
percentile_cont(.5)
WITHIN GROUP (ORDER BY p0010001) AS "County Median"
FROM us_counties_2010;

SELECT percentile_cont(array[.25,.5,.75])
WITHIN GROUP (ORDER BY p0010001) AS "quartiles"
FROM us_counties_2010;


SELECT unnest(
percentile_cont(array[.25,.5,.75])
WITHIN GROUP (ORDER BY p0010001)
) AS "quartiles"
FROM us_counties_2010;


CREATE OR REPLACE FUNCTION _final_median(numeric[])
   RETURNS numeric AS
$$
   SELECT AVG(val)
   FROM (
     SELECT val
     FROM unnest($1) val
     ORDER BY 1
     LIMIT  2 - MOD(array_upper($1, 1), 2)
     OFFSET CEIL(array_upper($1, 1) / 2.0) - 1
   ) sub;
$$
LANGUAGE 'sql' IMMUTABLE;

CREATE AGGREGATE median(numeric) (
  SFUNC=array_append,
  STYPE=numeric[],
  FINALFUNC=_final_median,
  INITCOND='{}'
);

SELECT sum(p0010001) AS "County Sum",
round(AVG(p0010001), 0) AS "County Average",
median(p0010001) AS "County Median",
percentile_cont(.5)
WITHIN GROUP (ORDER BY p0010001) AS "50th Percentile"
FROM us_counties_2010;
