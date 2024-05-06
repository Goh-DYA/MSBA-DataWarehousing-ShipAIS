-- General query
SELECT * 
FROM facts f, COG cog, SOG sog, status ss, vessels v, date_ d, time_ t, spatial sp
WHERE f.course = cog.course AND
f.speed = sog.speed AND
f.status = ss.status AND
f.shipid = v.shipid AND
f.date_ = d.date AND
f.time_ = t.time AND
f.geo_cell_id = sp.geo_cell_id
LIMIT 20;


-- Identify ship
select d.dayofweek_abb, v.shipcategory, count(distinct f.shipid) as count
from date_ d, facts f, vessels v
where d.date = f.date_
	and d.calendar_year = 2019
	and d.month_number = 12
	and f.shipid = v.shipid
group by d.dayofweek_abb, d.day_number, v.shipcategory 
order by d.day_number

/*
"Mon"	"CARGO"	616
"Mon"	"PASSENGER"	4
"Mon"	"TANKER"	902
"Tue"	"CARGO"	670
"Tue"	"PASSENGER"	3
"Tue"	"TANKER"	904
"Wed"	"CARGO"	501
"Wed"	"PASSENGER"	1
"Wed"	"TANKER"	776
"Thu"	"CARGO"	522
"Thu"	"TANKER"	741
"Fri"	"CARGO"	528
"Fri"	"PASSENGER"	5
"Fri"	"TANKER"	768
"Sat"	"CARGO"	543
"Sat"	"PASSENGER"	4
"Sat"	"TANKER"	777
"Sun"	"CARGO"	650
"Sun"	"PASSENGER"	4
"Sun"	"TANKER"	897
*/



-- FACT TABLE (MEASURED)
SELECT table2.date_, table2.geo_subcategory, table2.shipcategory, table1.avgspeed, table1.sdspeed, table1.minspeed, table1.maxspeed
FROM 
	(select *
	FROM (SELECT DISTINCT ff.date_ FROM facts ff) AS f
	CROSS JOIN (SELECT DISTINCT s.geo_subcategory FROM spatial s WHERE s.geo_subcategory <> 'Land') AS gg
	CROSS JOIN (SELECT DISTINCT v.shipcategory FROM vessels v) AS vv) AS table2
LEFT OUTER JOIN 
	(select f.date_, s.geo_subcategory, v.shipcategory, avg(f.speed) AS avgspeed, stddev(f.speed) AS sdspeed, min(f.speed) AS minspeed, max(f.speed) AS maxspeed 
	from facts f, spatial s, vessels v
	where f.shipid = v.shipid
	and f.geo_cellid = s.geo_cell_id 
	AND f.speed <> 102.3
	group by f.date_, s.geo_subcategory, v.shipcategory) AS table1
ON table1.date_ = table2.date_
AND table1.geo_subcategory = table2.geo_subcategory 
AND table1.shipcategory = table2.shipcategory;



-- DRAFT BY SHIP ID
SELECT table2.date_, table2.geo_subcategory, table2.shipcategory, table1.shipcount, table1.avgspeed, table1.sdspeed, table1.minspeed, table1.maxspeed
FROM 
(select *
FROM (SELECT DISTINCT ff.date_ FROM facts ff) AS f
CROSS JOIN (SELECT DISTINCT s.geo_subcategory FROM spatial s WHERE s.geo_subcategory <> 'Land') AS gg
CROSS JOIN (SELECT DISTINCT v.shipcategory FROM vessels v) AS vv) AS table2
LEFT OUTER JOIN 
(select f.date_, s.geo_subcategory, v.shipcategory, count(f.shipid) AS shipcount, avg(f.speed) AS avgspeed, stddev(f.speed) AS sdspeed, min(f.speed) AS minspeed, max(f.speed) AS maxspeed 
from facts f, spatial s, vessels v
where f.shipid = v.shipid
and f.geo_cellid = s.geo_cell_id 
AND f.speed <> 102.3
group by f.shipid, f.date_, s.geo_subcategory, v.shipcategory) AS table1
ON table1.date_ = table2.date_
AND table1.geo_subcategory = table2.geo_subcategory 
AND table1.shipcategory = table2.shipcategory;


-- ##############################################################################################################################################################################################

-- Find the count of ships at each port on any given day / time (by category)

-- Base query (exclude combis that are null)
-- SELECT dd.date, tt.day_part_segment, sp.geo_subcategory, COUNT(DISTINCT f.shipid)
-- FROM facts f, vessels v, spatial sp, date_ dd, time_ tt
-- WHERE f.shipid = v.shipid
-- 	AND f.geo_cell_id = sp.geo_cell_id
-- 	AND f.date_ = dd.date
-- 	AND f.time_ = tt.time
-- GROUP BY dd.date, tt.day_part_segment, sp.geo_subcategory
-- ORDER BY dd.date ASC, sp.geo_subcategory ASC, tt.day_part_segment ASC

SELECT ddg.date_, ddg.day_part_segment, ddg.geo_subcategory, COALESCE(t1.noOfShips, 0) AS shipCount
FROM
(SELECT *
FROM 
	(SELECT DISTINCT ff1.date_ FROM facts ff1) AS udate,
	(SELECT DISTINCT tt1.day_part_segment FROM time_ tt1) AS uday,
	(SELECT DISTINCT sp1.geo_subcategory FROM spatial sp1) AS ugeo) AS ddg
LEFT OUTER JOIN
	(SELECT dd.date, tt.day_part_segment, sp.geo_subcategory, COUNT(DISTINCT f.shipid) AS noOfShips
	FROM facts f, vessels v, spatial sp, date_ dd, time_ tt
	WHERE f.shipid = v.shipid
	AND f.geo_cell_id = sp.geo_cell_id
	AND f.date_ = dd.date
	AND f.time_ = tt.time
	GROUP BY dd.date, tt.day_part_segment, sp.geo_subcategory
	ORDER BY dd.date ASC, sp.geo_subcategory ASC, tt.day_part_segment ASC) AS t1
ON ddg.date_ = t1.date
	AND ddg.day_part_segment = t1.day_part_segment
	AND ddg.geo_subcategory = t1.geo_subcategory
ORDER BY ddg.date_ ASC, ddg.day_part_segment ASC, ddg.geo_subcategory;


-- "1/1/2020"	"Afternoon"	"Land"		0
-- "1/1/2020"	"Afternoon"	"Port Brani"	5
-- "1/1/2020"	"Afternoon"	"Port Bukom"		14
-- "1/1/2020"	"Afternoon"	"Port Jurong Island"		64
-- "1/1/2020"	"Afternoon"	"Port Marina Bay Cruise Centre"		0
-- "1/1/2020"	"Afternoon"	"Port Pasir Panjang"	44
-- "1/1/2020"	"Afternoon"	"Port Tanjong Pagar"	1
-- "1/1/2020"	"Afternoon"	"Port Tuas"		10
-- "1/1/2020"	"Afternoon"	"Sea"	249


-- Find the count of ships at each port on any given day / time (by hour) - 20k++ rows

SELECT ddg.date_, ddg.hour, ddg.am_pm, ddg.day_part_segment, ddg.geo_subcategory, COALESCE(t1.noOfShips, 0) AS shipCount
FROM
	(SELECT *
	FROM 
	(SELECT DISTINCT ff1.date_ FROM facts ff1) AS udate,
	(SELECT DISTINCT tt1.hour, tt1.am_pm, tt1.day_part_segment FROM time_ tt1 ORDER BY tt1.hour) AS uday,
	(SELECT DISTINCT sp1.geo_subcategory FROM spatial sp1) AS ugeo) AS ddg
LEFT OUTER JOIN
	(SELECT dd.date, tt.hour, tt.day_part_segment, sp.geo_subcategory, COUNT(DISTINCT f.shipid) AS noOfShips
	FROM facts f, vessels v, spatial sp, date_ dd, time_ tt
	WHERE f.shipid = v.shipid
	AND f.geo_cell_id = sp.geo_cell_id
	AND f.date_ = dd.date
	AND f.time_ = tt.time
	GROUP BY dd.date, tt.hour, tt.day_part_segment, sp.geo_subcategory
	ORDER BY dd.date ASC, sp.geo_subcategory ASC, tt.day_part_segment ASC) AS t1
ON ddg.date_ = t1.date
	AND ddg.hour = t1.hour
	AND ddg.day_part_segment = t1.day_part_segment
	AND ddg.geo_subcategory = t1.geo_subcategory
ORDER BY ddg.date_ ASC, ddg.hour ASC, ddg.day_part_segment ASC, ddg.geo_subcategory;

-- "1/1/2020"	0	"AM"	"Late_Night"	"Land"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Brani"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Bukom"	2
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Jurong Island"	17
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Marina Bay Cruise Centre"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Pasir Panjang"	19
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Tanjong Pagar"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Tuas"	1
-- "1/1/2020"	0	"AM"	"Late_Night"	"Sea"	116
-- "1/1/2020"	1	"AM"	"Late_Night"	"Land"	0
-- "1/1/2020"	1	"AM"	"Late_Night"	"Port Brani"	0
-- "1/1/2020"	1	"AM"	"Late_Night"	"Port Bukom"	4
-- "1/1/2020"	1	"AM"	"Late_Night"	"Port Jurong Island"	16
-- "1/1/2020"	1	"AM"	"Late_Night"	"Port Marina Bay Cruise Centre"	0
-- "1/1/2020"	1	"AM"	"Late_Night"	"Port Pasir Panjang"	17
-- "1/1/2020"	1	"AM"	"Late_Night"	"Port Tanjong Pagar"	0
-- "1/1/2020"	1	"AM"	"Late_Night"	"Port Tuas"	1
-- "1/1/2020"	1	"AM"	"Late_Night"	"Sea"	123


-- Find the count of ships at each port on any given day / time (by hour + ship category) - 80k rows

SELECT ddg.date_, ddg.hour, ddg.am_pm, ddg.day_part_segment, ddg.geo_subcategory, ddg.shipcategory, COALESCE(t1.noOfShips, 0) AS shipCount
FROM
	(SELECT *
	FROM 
	(SELECT DISTINCT ff1.date_ FROM facts ff1) AS udate,
	(SELECT DISTINCT tt1.hour, tt1.am_pm, tt1.day_part_segment FROM time_ tt1 ORDER BY tt1.hour) AS uday,
	(SELECT DISTINCT sp1.geo_subcategory FROM spatial sp1) AS ugeo,
	(SELECT DISTINCT v1.shipcategory FROM vessels v1) AS vcat) AS ddg
LEFT OUTER JOIN
	(SELECT dd.date, tt.hour, tt.day_part_segment, sp.geo_subcategory, v.shipcategory, COUNT(DISTINCT f.shipid) AS noOfShips
	FROM facts f, vessels v, spatial sp, date_ dd, time_ tt
	WHERE f.shipid = v.shipid
	AND f.geo_cell_id = sp.geo_cell_id
	AND f.date_ = dd.date
	AND f.time_ = tt.time
	GROUP BY dd.date, tt.hour, tt.day_part_segment, sp.geo_subcategory, v.shipcategory
	ORDER BY dd.date ASC, sp.geo_subcategory ASC, tt.day_part_segment ASC) AS t1
ON ddg.date_ = t1.date
	AND ddg.hour = t1.hour
	AND ddg.day_part_segment = t1.day_part_segment
	AND ddg.geo_subcategory = t1.geo_subcategory
	AND ddg.shipcategory = t1.shipcategory
ORDER BY ddg.date_ ASC, ddg.hour ASC, ddg.day_part_segment ASC, ddg.geo_subcategory ASC, ddg.shipcategory ASC;

-- "1/1/2020"	0	"AM"	"Late_Night"	"Land"	"CARGO"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Land"	"PASSENGER"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Land"	"TANKER"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Brani"	"CARGO"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Brani"	"PASSENGER"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Brani"	"TANKER"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Bukom"	"CARGO"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Bukom"	"PASSENGER"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Bukom"	"TANKER"	2
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Jurong Island"	"CARGO"	2
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Jurong Island"	"PASSENGER"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Jurong Island"	"TANKER"	15
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Marina Bay Cruise Centre"	"CARGO"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Marina Bay Cruise Centre"	"PASSENGER"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Marina Bay Cruise Centre"	"TANKER"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Pasir Panjang"	"CARGO"	16
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Pasir Panjang"	"PASSENGER"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Pasir Panjang"	"TANKER"	3
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Tanjong Pagar"	"CARGO"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Tanjong Pagar"	"PASSENGER"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Tanjong Pagar"	"TANKER"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Tuas"	"CARGO"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Tuas"	"PASSENGER"	0
-- "1/1/2020"	0	"AM"	"Late_Night"	"Port Tuas"	"TANKER"	1
-- "1/1/2020"	0	"AM"	"Late_Night"	"Sea"	"CARGO"	20
-- "1/1/2020"	0	"AM"	"Late_Night"	"Sea"	"PASSENGER"	1
-- "1/1/2020"	0	"AM"	"Late_Night"	"Sea"	"TANKER"	95


-- Find the count of ships at each port on any given day / time (by day part + ship category) - 20k rows

SELECT ddg.date_, ddg.day_part_segment, ddg.geo_subcategory, ddg.shipcategory, COALESCE(t1.noOfShips, 0) AS shipCount
FROM
	(SELECT *
	FROM 
	(SELECT DISTINCT ff1.date_ FROM facts ff1) AS udate,
	(SELECT DISTINCT tt1.day_part_segment FROM time_ tt1) AS uday,
	(SELECT DISTINCT sp1.geo_subcategory FROM spatial sp1) AS ugeo,
	(SELECT DISTINCT v1.shipcategory FROM vessels v1) AS vcat) AS ddg
LEFT OUTER JOIN
	(SELECT dd.date, tt.day_part_segment, sp.geo_subcategory, v.shipcategory, COUNT(DISTINCT f.shipid) AS noOfShips
	FROM facts f, vessels v, spatial sp, date_ dd, time_ tt
	WHERE f.shipid = v.shipid
	AND f.geo_cell_id = sp.geo_cell_id
	AND f.date_ = dd.date
	AND f.time_ = tt.time
	GROUP BY dd.date, tt.day_part_segment, sp.geo_subcategory, v.shipcategory
	ORDER BY dd.date ASC, sp.geo_subcategory ASC, tt.day_part_segment ASC) AS t1
ON ddg.date_ = t1.date
	AND ddg.day_part_segment = t1.day_part_segment
	AND ddg.geo_subcategory = t1.geo_subcategory
	AND ddg.shipcategory = t1.shipcategory
ORDER BY ddg.date_ ASC, ddg.day_part_segment ASC, ddg.geo_subcategory ASC, ddg.shipcategory ASC;


-- Find the total no of unique ships per day 
-- does NOT work as there is double counting
SELECT ms.date,  , SUM(ms.shipcount)
FROM measuredshipcountfacts ms, date_ dd
WHERE dd.date = ms.date
GROUP BY ms.date, dd.day_number_in_year, dd.calendar_year
ORDER BY dd.calendar_year ASC, dd.day_number_in_year ASC

-- "1/12/2019"	3141
-- "2/12/2019"	2580
-- "3/12/2019"	3057
-- "4/12/2019"	3551
-- "5/12/2019"	3239
-- "6/12/2019"	3062


-- ##############################################################################################################################################################################################


-- PRe vs POST covid
-- Total Ships Count 
SELECT dd.covid_indicator, COUNT(DISTINCT v.shipid)
FROM facts f, vessels v, date_ dd
WHERE f.date_ = dd.date
AND f.shipid = v.shipid
GROUP BY dd.covid_indicator

-- "CV19"	4784
-- "Pre-CV19"	5082


-- -- By ship Category (dont need)
-- SELECT dd.covid_indicator, v.shipcategory, COUNT(DISTINCT v.shipid)
-- FROM facts f, vessels v, date_ dd
-- WHERE f.date_ = dd.date
-- AND f.shipid = v.shipid
-- GROUP BY dd.covid_indicator, v.shipcategory

-- By Geo Category (Port, Sea, Land)
SELECT dd.covid_indicator, sp.geo_category, COUNT(DISTINCT f.shipid)
FROM facts f, date_ dd, spatial sp
WHERE f.date_ = dd.date
AND f.geo_cell_id = sp.geo_cell_id
GROUP BY dd.covid_indicator, sp.geo_category
ORDER BY sp.geo_category ASC, dd.covid_indicator DESC;

-- "Pre-CV19"	"Port"	2576
-- "CV19"	"Port"	2266
-- "Pre-CV19"	"Sea"	5071
-- "CV19"	"Sea"	4777



-- By Individual Ports
SELECT dd.covid_indicator, sp.geo_subcategory, COUNT(DISTINCT v.shipid)
FROM facts f, vessels v, spatial sp, date_ dd
WHERE f.date_ = dd.date
AND f.shipid = v.shipid
AND f.geo_cell_id = sp.geo_cell_id
AND sp.geo_category = 'Port'
GROUP BY dd.covid_indicator, sp.geo_subcategory
ORDER BY sp.geo_subcategory ASC, dd.covid_indicator DESC;

-- "Pre-CV19"	"Port Brani"	238
-- "CV19"	"Port Brani"	188
-- "Pre-CV19"	"Port Bukom"	954
-- "CV19"	"Port Bukom"	794
-- "Pre-CV19"	"Port Jurong Island"	1831
-- "CV19"	"Port Jurong Island"	1623
-- "Pre-CV19"	"Port Marina Bay Cruise Centre"	16
-- "CV19"	"Port Marina Bay Cruise Centre"	2
-- "Pre-CV19"	"Port Pasir Panjang"	1549
-- "CV19"	"Port Pasir Panjang"	1377
-- "Pre-CV19"	"Port Tanjong Pagar"	224
-- "CV19"	"Port Tanjong Pagar"	147
-- "Pre-CV19"	"Port Tuas"	972
-- "CV19"	"Port Tuas"	759


-- By Individual Port + Ship Category 
SELECT cvgeocat.covid_indicator, cvgeocat.geo_subcategory, cvgeocat.shipcategory, COALESCE(counts.shipcount, 0) AS shipCount
FROM 
	(SELECT *
	FROM
	(SELECT DISTINCT dd1.covid_indicator FROM date_ dd1) AS cv,
	(SELECT DISTINCT sp1.geo_subcategory FROM spatial sp1 WHERE sp1.geo_category = 'Port') AS sp1,
	(SELECT DISTINCT v1.shipcategory FROM vessels v1) AS vc) AS cvgeocat
LEFT OUTER JOIN
	(SELECT dd.covid_indicator, sp.geo_subcategory, v.shipcategory, COUNT(DISTINCT v.shipid) AS shipcount
	FROM facts f, vessels v, spatial sp, date_ dd
	WHERE f.date_ = dd.date
	AND f.shipid = v.shipid
	AND f.geo_cell_id = sp.geo_cell_id
	AND sp.geo_category = 'Port'
	GROUP BY dd.covid_indicator, sp.geo_subcategory, v.shipcategory
	ORDER BY sp.geo_subcategory ASC, dd.covid_indicator DESC, v.shipcategory ASC) AS counts
ON cvgeocat.covid_indicator = counts.covid_indicator
AND cvgeocat.geo_subcategory = counts.geo_subcategory
AND cvgeocat.shipcategory = counts.shipcategory;

-- "CV19"	"Port Brani"	"CARGO"	157
-- "Pre-CV19"	"Port Brani"	"CARGO"	184
-- "CV19"	"Port Brani"	"TANKER"	31
-- "Pre-CV19"	"Port Brani"	"TANKER"	54
-- "CV19"	"Port Brani"	"PASSENGER"	0
-- "Pre-CV19"	"Port Brani"	"PASSENGER"	0
-- "CV19"	"Port Bukom"	"CARGO"	319
-- "Pre-CV19"	"Port Bukom"	"CARGO"	421
-- "CV19"	"Port Bukom"	"TANKER"	475
-- "Pre-CV19"	"Port Bukom"	"TANKER"	531
-- "CV19"	"Port Bukom"	"PASSENGER"	0
-- "Pre-CV19"	"Port Bukom"	"PASSENGER"	2

-- ##############################################################################################################################################################################################

-- Business Queston 2

-- Find the number of unique ships (ie. traffic) across singapore waters on a daily basis for Dec 2019
SELECT d.date, d.weekday_indicator, d.holiday_indicator, v.shipcategory, COUNT(DISTINCT f.shipid)
FROM facts f, date_ d, vessels v
WHERE f.date_ = d.date
	AND d.calendar_year = 2019
	AND d.month_number = 12
	AND f.shipid = v.shipid
	-- AND v.shipcategory
GROUP BY d.day_number_in_year, d.date, d.weekday_indicator, d.holiday_indicator, v.shipcategory
ORDER BY d.day_number_in_year;

-- "1/12/2019"	"Weekend"	"NonHoliday"	"CARGO"	129
-- "1/12/2019"	"Weekend"	"NonHoliday"	"PASSENGER"	1
-- "1/12/2019"	"Weekend"	"NonHoliday"	"TANKER"	302
-- "2/12/2019"	"Weekday"	"NonHoliday"	"CARGO"	138
-- "2/12/2019"	"Weekday"	"NonHoliday"	"PASSENGER"	2
-- "2/12/2019"	"Weekday"	"NonHoliday"	"TANKER"	307


-- Find the number of unique ships (ie. traffic) across singapore waters on a daily basis for Dec 2019, and their average speed, etc.
SELECT d.date, d.weekday_indicator, d.holiday_indicator, v.shipcategory, COUNT(DISTINCT f.shipid), mf.avgspeed, mf.stdspeed, mf.minspeed, mf.maxspeed
FROM facts f, date_ d, vessels v, measuredfacts mf
WHERE f.date_ = d.date
	AND d.calendar_year = 2019
	AND d.month_number = 12
	AND f.shipid = v.shipid
	AND mf.date = d.date
	AND mf.shipcategory = v.shipcategory
	AND mf.geo_subcategory = 'Sea'
	AND f.date_ = mf.date
GROUP BY d.day_number_in_year, d.date, d.weekday_indicator, d.holiday_indicator, v.shipcategory, mf.avgspeed, mf.stdspeed, mf.minspeed, mf.maxspeed
ORDER BY d.day_number_in_year ASC;

-- "1/12/2019"	"Weekend"	"NonHoliday"	"CARGO"	129	7.714967811	5.572827855	0	20
-- "1/12/2019"	"Weekend"	"NonHoliday"	"PASSENGER"	1	0	0	0	0
-- "1/12/2019"	"Weekend"	"NonHoliday"	"TANKER"	302	3.006264407	4.287156227	0	82.7
-- "2/12/2019"	"Weekday"	"NonHoliday"	"CARGO"	138	6.761970614	5.746321729	0	21.3
-- "2/12/2019"	"Weekday"	"NonHoliday"	"PASSENGER"	2	10.61666667	6.321840449	0	15.3
-- "2/12/2019"	"Weekday"	"NonHoliday"	"TANKER"	307	3.069709763	4.068056	0	25.7


-- In the month of Dec 2019, at each port, based on each type of ship, find the busiest period of the day:
SELECT mscf.geo_subcategory, mscf.shipcategory, mscf.day_part_segment, SUM(mscf.shipcount) 
FROM measuredshipcountfacts mscf, date_ d
WHERE mscf.geo_subcategory LIKE 'Port %'
	AND mscf.date = d.date
	AND d.month_number = 12
	AND d.calendar_year = 2019
GROUP BY mscf.day_part_segment, mscf.geo_subcategory, mscf.shipcategory
ORDER BY mscf.geo_subcategory ASC, mscf.shipcategory ASC, mscf.day_part_segment ASC;

-- "Port Brani"	"CARGO"	"Afternoon"	61
-- "Port Brani"	"CARGO"	"Early_Morning"	30
-- "Port Brani"	"CARGO"	"Evening"	37
-- "Port Brani"	"CARGO"	"Late_Night"	45
-- "Port Brani"	"CARGO"	"Morning"	38
-- "Port Brani"	"CARGO"	"Night"	37
-- "Port Brani"	"PASSENGER"	"Afternoon"	0
-- "Port Brani"	"PASSENGER"	"Early_Morning"	0
-- "Port Brani"	"PASSENGER"	"Evening"	0
-- "Port Brani"	"PASSENGER"	"Late_Night"	0
-- "Port Brani"	"PASSENGER"	"Morning"	0
-- "Port Brani"	"PASSENGER"	"Night"	0
-- "Port Brani"	"TANKER"	"Afternoon"	11
-- "Port Brani"	"TANKER"	"Early_Morning"	8
-- "Port Brani"	"TANKER"	"Evening"	10
-- "Port Brani"	"TANKER"	"Late_Night"	8
-- "Port Brani"	"TANKER"	"Morning"	7
-- "Port Brani"	"TANKER"	"Night"	6

-- BY MONTH-YEAR
-- In a specified day, at each port, based on each type of ship, find the busiest period of the day:
SELECT d.month_abb, d.calendar_year, mscf.geo_subcategory, mscf.shipcategory, mscf.day_part_segment, SUM(mscf.shipcount) 
FROM measuredshipcountfacts mscf, date_ d
WHERE mscf.geo_subcategory LIKE 'Port %'
	AND mscf.date = d.date
	AND d.month_number = 12
	AND d.calendar_year = 2019
	-- AND d.day_number_in_month = 8
GROUP BY d.month_abb, d.calendar_year, mscf.day_part_segment, mscf.geo_subcategory, mscf.shipcategory
ORDER BY mscf.geo_subcategory ASC, mscf.shipcategory ASC, mscf.day_part_segment ASC;

-- By a Specific port
SELECT mscf.geo_subcategory, mscf.shipcategory, mscf.day_part_segment, SUM(mscf.shipcount) 
FROM measuredshipcountfacts mscf, date_ d
WHERE mscf.geo_subcategory = 'Port Brani'
	AND mscf.date = d.date
	AND d.month_number = 12
	AND d.calendar_year = 2019
-- 	AND d.day_number_in_month = 9
GROUP BY mscf.day_part_segment, mscf.geo_subcategory, mscf.shipcategory
ORDER BY mscf.geo_subcategory ASC, mscf.shipcategory ASC, mscf.day_part_segment ASC;


-- BY DAY-MONTH-YEAR
-- In a specified day, at each port, based on each type of ship, find the busiest period of the day:
SELECT d.date, d.dayofweek_abb, d.weekday_indicator, d.holiday_indicator, mscf.geo_subcategory, mscf.shipcategory, mscf.day_part_segment, SUM(mscf.shipcount) 
FROM measuredshipcountfacts mscf, date_ d
WHERE mscf.geo_subcategory LIKE 'Port %'
	AND mscf.date = d.date
	AND d.month_number = 12
	AND d.calendar_year = 2019
	AND d.day_number_in_month = 25
GROUP BY d.date, d.dayofweek_abb, d.weekday_indicator, d.holiday_indicator, mscf.day_part_segment, mscf.geo_subcategory, mscf.shipcategory
ORDER BY mscf.geo_subcategory ASC, mscf.shipcategory ASC, mscf.day_part_segment ASC;

-- ALL PORTS (workaround)
SELECT d.date, d.dayofweek_abb, d.weekday_indicator, d.holiday_indicator, mscf.geo_subcategory, mscf.shipcategory, mscf.day_part_segment, SUM(mscf.shipcount) 
FROM measuredshipcountfacts mscf, date_ d
WHERE (mscf.geo_subcategory = 'Port Brani'
	OR mscf.geo_subcategory = 'Port Bukom'
	OR mscf.geo_subcategory = 'Port Jurong Island'
	OR mscf.geo_subcategory = 'Port Marina Bay Cruise Centre'
	OR mscf.geo_subcategory = 'Port Pasir Panjang'
	OR mscf.geo_subcategory = 'Port Tanjong Pagar'
	OR mscf.geo_subcategory = 'Port Tuas')
	AND mscf.date = d.date
	AND d.month_number = 12
	AND d.calendar_year = 2020
	AND d.day_number_in_month = 25
GROUP BY d.date, d.dayofweek_abb, d.weekday_indicator, d.holiday_indicator, mscf.day_part_segment, mscf.geo_subcategory, mscf.shipcategory
ORDER BY mscf.geo_subcategory ASC, mscf.shipcategory ASC, mscf.day_part_segment ASC;