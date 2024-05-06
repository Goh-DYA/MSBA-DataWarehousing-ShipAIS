/*******************

  Copy data script

*******************/

--COPY facts FROM 'D:\Dimensions\facttable_main.csv' DELIMITER ',' CSV HEADER;
--COPY COG FROM 'D:\Dimensions\course.csv' DELIMITER ',' CSV HEADER;
--COPY SOG FROM 'D:\Dimensions\speed.csv' DELIMITER ',' CSV HEADER;
--COPY status FROM 'D:\Dimensions\status.csv' DELIMITER ',' CSV HEADER;
--COPY vessels FROM 'D:\Dimensions\vessels.csv' DELIMITER ',' CSV HEADER;
--COPY time_ FROM 'D:\Dimensions\time.csv' DELIMITER ',' CSV HEADER;
--COPY date_ FROM 'D:\Dimensions\date.csv' DELIMITER ',' CSV HEADER;
--COPY spatial FROM 'D:\Dimensions\Spatial.csv' DELIMITER ',' CSV HEADER;
-- COPY measuredfacts FROM 'D:\Dimensions\measured_facttable_ship_geo_date.csv' DELIMITER ',' CSV HEADER;\
-- COPY measuredshipcountfacts FROM 'D:\Dimensions\measured_facttable_shipcount.csv' DELIMITER ',' CSV HEADER;

-- Using psql shell
-- \copy facts FROM 'C:\Users\Adison\Downloads\GroupProject_Schema\facttable_main.csv' DELIMITER ',' CSV HEADER;
-- \copy COG FROM 'C:\Users\Adison\Downloads\GroupProject_Schema\course.csv' DELIMITER ',' CSV HEADER;
-- \copy SOG FROM 'C:\Users\Adison\Downloads\GroupProject_Schema\speed.csv' DELIMITER ',' CSV HEADER;
-- \copy status FROM 'C:\Users\Adison\Downloads\GroupProject_Schema\status.csv' DELIMITER ',' CSV HEADER;
-- \copy vessels FROM 'C:\Users\Adison\Downloads\GroupProject_Schema\vessels.csv' DELIMITER ',' CSV HEADER;
-- \copy time_ FROM 'C:\Users\Adison\Downloads\GroupProject_Schema\time.csv' DELIMITER ',' CSV HEADER;
-- \copy date_ FROM 'C:\Users\Adison\Downloads\GroupProject_Schema\date.csv' DELIMITER ',' CSV HEADER;
-- \copy spatial FROM 'C:\Users\Adison\Downloads\GroupProject_Schema\Spatial.csv' DELIMITER ',' CSV HEADER;
-- \copy measuredfacts FROM 'C:\Users\Adison\Downloads\GroupProject_Schema\measured_facttable_ship_geo_date.csv' DELIMITER ',' CSV HEADER;
-- \copy measuredshipcountfacts FROM 'C:\Users\Adison\Downloads\GroupProject_Schema\measured_facttable_shipcount.csv' DELIMITER ',' CSV HEADER;
-- \copy measuredshipcountfacts FROM 'C:\Users\Adison\Downloads\GroupProject_Schema\measured_facttable_shipcount.csv' DELIMITER ',' CSV HEADER;