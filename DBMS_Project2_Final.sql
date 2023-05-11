-- create extension

Create extension postgis;
create extension hstore;

-- create taable

CREATE TABLE earth_test (time TIMESTAMP,latitude DOUBLE PRECISION,longitude DOUBLE PRECISION,
						 depth DOUBLE PRECISION, mag DOUBLE PRECISION,magType VARCHAR(10),
						 nst INTEGER,gap DOUBLE PRECISION,dmin DOUBLE PRECISION,rms DOUBLE PRECISION,
						 net Varchar(10),id VARCHAR(255) PRIMARY KEY,updated TIMESTAMP,place VARCHAR(255),
						 type VARCHAR(50),horizontal DOUBLE PRECISION,depthError DOUBLE PRECISION,
						 magError DOUBLE PRECISION,magNst INTEGER,status varchar(50),
						 locationSource VARCHAR(50),magSource VARCHAR(50));
						 
--view data						 
select* from earth_test


-- Get a count of rows
SELECT COUNT(*) FROM earth_test;


-- count of status
--automatic mean that computer system detection
-- review mean that analyst review
-- more incidents was reviewed buy analyst

SELECT status, COUNT(*) FROM earth_test GROUP BY status;

-- count of place

SELECT place,count(*)
FROM earth_test
group by place

--create index

CREATE INDEX idx_automatic on earth_test ( status, locationsource);
explain select*
from earth_test
where status = ' automatic'

-- get distinct count of locationsource
select  distinct locationsource , AVG(mag), min(mag), max(mag)
from earth_test
group by locationsource 
order by AVG(mag) desc;

-- rank by mag, dept and gap
SELECT mag,depth,gap,
Rank() over (partition by depth order by mag desc)
from earth_test

-- select location where mag > 7
SELECT latitude, longitude, place FROM earth_test WHERE mag > 7;

--select location where mag >6
SELECT latitude, longitude, place FROM earth_test WHERE mag > 6;

-- calculate distant point

SELECT SQRT(POW((latitude - 38.8977), 2) + POW((longitude - 77.0365), 2)) AS distance 
FROM earth_test;

-- order by descending order
SELECT * FROM earth_test ORDER BY mag DESC LIMIT 10;


CREATE INDEX idx_latitude_longitude ON earth_test(latitude, longitude);



SELECT type, AVG(mag) as average_magnitude FROM earth_test GROUP BY type;


SELECT COALESCE(mag, 0) FROM earth_test;



SELECT place, latitude, longitude, COUNT(*) as earthquake_count
FROM earth_test
WHERE type = 'earthquake' AND mag > 6
GROUP BY place, latitude, longitude
ORDER BY earthquake_count DESC;

SELECT * FROM earth_test ORDER BY mag DESC LIMIT 10;

SELECT * FROM earth_test ORDER BY mag DESC LIMIT 10 OFFSET 20;


SELECT *, AVG( depth) over(partition by mag)
From earth_test


SELECT * FROM earth_test
WHERE nst IS NOT NULL AND gap IS NOT NULL AND dmin IS NOT NULL 
AND magError IS NOT NULL;

-- count total null in the following tables

SELECT 
    (COUNT(CASE WHEN nst IS NULL THEN 1 END) +
    COUNT(CASE WHEN gap IS NULL THEN 1 END) +
	COUNT(CASE WHEN rms IS NULL THEN 1 END) +
	 COUNT(CASE WHEN horizontal IS NULL THEN 1 END) +
	 COUNT(CASE WHEN deptherror IS NULL THEN 1 END) +
	 COUNT(CASE WHEN magerror IS NULL THEN 1 END) +
    COUNT(CASE WHEN dmin IS NULL THEN 1 END)) AS total_nulls
   
FROM earth_test;


-- calculate distance between two points

SELECT ST_Distance(
    ST_Transform(ST_SetSRID(ST_MakePoint(longitude, latitude), 4326), 3857),
    ST_Transform(ST_SetSRID(ST_MakePoint((SELECT longitude FROM earth_test WHERE place = '77 km SW of Pilot Point, Alaska'),
										 (SELECT latitude FROM earth_test WHERE place = '77 km SW of Pilot Point, Alaska')), 4326), 3857)
) as distance_in_meters
FROM earth_test
WHERE place = '41 km ENE of Susitna North, Alaska';



SELECT ST_Distance(
    ST_Transform(ST_SetSRID(ST_MakePoint(longitude, latitude), 4326), 3857),
    ST_Transform(ST_SetSRID(ST_MakePoint((SELECT longitude FROM earth_test WHERE place = '170 km SSE of Teluk Dalam, Indonesia'), 
										 (SELECT latitude FROM earth_test WHERE place = '77 km SW of Pilot Point, Alaska')), 4326), 3857)
) as distance_in_meters
FROM earth_test
WHERE place = '77 km SW of Padangsidempuan, Indonesia';


EXPLAIN select * from earth_test

-- create index with mad > than 6

CREATE INDEX idx_earth_test_mag ON earth_test(mag);

SELECT * FROM earth_test WHERE mag > 6;

-- reteive specfic point > 6

SELECT latitude, longitude
FROM earth_test
WHERE type = 'earthquake' AND mag > 6;

--sorting and and limitation table
SELECT * FROM earth_test ORDER BY mag DESC LIMIT 20;



explain select distinct time from earth_test where status ='automatic' order by time

SELECT time, mag FROM earth_test;

-- specific time when earthquake > 6 and seems like April month is peak fro earthquake
select distinct time from earth_test where mag > 6 order by time

--
SELECT COUNT(DISTINCT place) FROM earth_test;

SELECT COUNT(DISTINCT mag) FROM earth_test;

SELECT count(DISTINCT net) FROM earth_test;

select distinct

-- mag above 6 is dangerous, place with high mag and dates

SELECT place, time, depth, mag, net, COUNT(*)
FROM earth_test
WHERE mag > 6
GROUP BY place, time, depth,net, mag;

-- places and time with less dangerous earthquake
SELECT place, time, depth, mag, net, COUNT(*)
FROM earth_test
WHERE mag < 6
GROUP BY place, time, depth,net, mag;

--create index

create index idx_danger_hit
on earth_test (mag);

explain select*
from earth_test
where mag > 6;


--Create view

CREATE VIEW " danger"as
SELECT mag
from earth_test
where mag > 6;

select * from " danger";
 
CREATE VIEW "dangerous_place"as
SELECT mag, place
from earth_test
where mag > 6;

select* from "dangerous_place"


-- create multi columns index

CREATE INDEX idx_safe_zone
on earth_test (mag,place,time);

explain select*
from earth_test
where mag < 6;


-- create function give you total records

CREATE OR REPLACE FUNCTION totalRecords ()
RETURNS integer AS $total$
declare
	total integer;
BEGIN
   SELECT count(*) into total FROM earth_test;
   RETURN total;
END;
$total$ LANGUAGE plpgsql;

select totalRecords();

SELECT * FROM earth_test WHERE mag > 6 AND place = 'Alaska' ORDER BY time DESC;
EXPLAIN SELECT * FROM earth_test WHERE mag > 6 AND place = 'Alaska' ORDER BY time DESC;



