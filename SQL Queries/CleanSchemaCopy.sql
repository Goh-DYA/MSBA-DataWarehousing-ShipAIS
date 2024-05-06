/*******************

  Cleaning script, Create the schema, 

*******************/

DROP TABLE IF EXISTS facts;
CREATE TABLE IF NOT EXISTS facts (
    rec_id INT,
    type INT,
    mmsi BIGINT,
    status INT,
    turn INT,
    speed FLOAT,
    accuracy SMALLINT,
    lon FLOAT,
    lat FLOAT,
    course FLOAT,
    heading INT,
    time TIMESTAMP WITH TIME ZONE,
    date_ VARCHAR(10),
    time_ VARCHAR(5),
	shipID INT,
    Geo_Cell_ID INT
);
COPY facts FROM 'D:\Dimensions\facttable_main.csv' DELIMITER ',' CSV HEADER;


DROP TABLE IF EXISTS COG;
CREATE TABLE IF NOT EXISTS COG (
    course FLOAT,
	course_category VARCHAR(2) 
);
COPY COG FROM 'D:\Dimensions\course.csv' DELIMITER ',' CSV HEADER;


DROP TABLE IF EXISTS SOG;
CREATE TABLE IF NOT EXISTS SOG (
    speed FLOAT,
	speed_category VARCHAR(15) 
);
COPY SOG FROM 'D:\Dimensions\speed.csv' DELIMITER ',' CSV HEADER;

DROP TABLE IF EXISTS status;
CREATE TABLE IF NOT EXISTS status (
    status INT,
	status_Description VARCHAR 
);
COPY status FROM 'D:\Dimensions\status.csv' DELIMITER ',' CSV HEADER;

DROP TABLE IF EXISTS date_;
CREATE TABLE IF NOT EXISTS date_ (
    Date VARCHAR (10),
	dayOfWeek VARCHAR,
	dayOfWeek_abb VARCHAR(3),
	Day_Number SMALLINT,
	Month VARCHAR,
	Month_abb VARCHAR(3),
	Month_Number SMALLINT,
	Calendar_Year SMALLINT,
	Calendar_Qtr VARCHAR(4),
	Calendar_Year_Qtr VARCHAR(10),
	Calendar_Year_Mth VARCHAR(10),
	Day_Number_in_Month SMALLINT,
	Day_Number_in_Qtr SMALLINT,
	Day_Number_in_Year SMALLINT,
	Week_In_Year VARCHAR,
	Weekday_Indicator VARCHAR,
	Holiday_Indicator VARCHAR,
	Covid_indicator VARCHAR
);
COPY date_ FROM 'D:\Dimensions\date.csv' DELIMITER ',' CSV HEADER;

DROP TABLE IF EXISTS time_;
CREATE TABLE IF NOT EXISTS time_ (
    Time VARCHAR(5),
	AM_PM VARCHAR(2),
	Hour SMALLINT,
	Day_Part_Segment VARCHAR
);
COPY time_ FROM 'D:\Dimensions\time.csv' DELIMITER ',' CSV HEADER;

DROP TABLE IF EXISTS vessels;
CREATE TABLE IF NOT EXISTS vessels (
    shipID INT,
    imo BIGINT,
	mmsi BIGINT,
	vessel_name VARCHAR,
	callsign VARCHAR,
	flag_name VARCHAR,
	shiptype INT,
	shiptypeDescription VARCHAR,
	shipCategory VARCHAR,
	shipSubCategory VARCHAR,
	to_bow BIGINT,
	to_stern BIGINT,
	to_port BIGINT,
	to_starboard BIGINT,
	vesselLength INT,
	vesselBeam INT,
	deadweighttonage INT,
	beneficial_owner VARCHAR,
	beneficial_owner_country VARCHAR,
	operator VARCHAR,
	operator_country VARCHAR,
	technical_manager VARCHAR,
	technical_manager_country VARCHAR,
	commercial_manager VARCHAR,
	commercial_manager_country VARCHAR,
	class1_code VARCHAR,
	built_year INT
);
COPY vessels FROM 'D:\Dimensions\vessels.csv' DELIMITER ',' CSV HEADER;

DROP TABLE IF EXISTS spatial;
CREATE TABLE IF NOT EXISTS spatial (
    Geo_Cell_ID INT,
	Lat_gte FLOAT,
	Lat_lt FLOAT,
	Lon_gte FLOAT,
	Lon_lt FLOAT,
	Geo_Category VARCHAR,
	Geo_subcategory VARCHAR,
	Geo_Description VARCHAR
);
COPY spatial FROM 'D:\Dimensions\Spatial.csv' DELIMITER ',' CSV HEADER;

DROP TABLE IF EXISTS measuredspeedfacts;
CREATE TABLE IF NOT EXISTS measuredspeedfacts (
	date VARCHAR(10),
	geo_subcategory VARCHAR,
	shipcategory VARCHAR,
	avgspeed FLOAT,
	stdspeed FLOAT,
	minspeed FLOAT,
	maxspeed FLOAT
);
COPY measuredspeedfacts FROM 'D:\Dimensions\measured_facttable_ship_geo_date.csv' DELIMITER ',' CSV HEADER;

DROP TABLE IF EXISTS measuredshipcountfacts;
CREATE TABLE IF NOT EXISTS measuredshipcountfacts (
	date VARCHAR(10),
	-- hour SMALLINT,
	-- am_pm VARCHAR(2),
	day_part_segment VARCHAR,
	geo_subcategory VARCHAR,
	shipcategory VARCHAR,
	shipCount INT
);
COPY measuredshipcountfacts FROM 'D:\Dimensions\measured_facttable_shipcount.csv' DELIMITER ',' CSV HEADER

