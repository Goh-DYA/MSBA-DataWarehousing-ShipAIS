#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Peter Simeth's basic flask pretty youtube downloader (v1.3)
https://github.com/petersimeth/basic-flask-template
© MIT licensed, 2018-2023
"""

from flask import Flask, render_template, request, redirect, url_for 
import psycopg2 

DEVELOPMENT_ENV = True

app = Flask(__name__, static_url_path='/static')

# app.debug = True

app_data = {
    "name": "BT5110 Group Project",
    "description": "Flask Application: Generation of Report from StarAIS database",
    "author": "BT5110 Group 12",
    "html_title": "BT5110 Group Project Flask Web App",
    "project_name": "BT5110 Group Project",
    "keywords": "flask, webapp, BT5110, starais",
}

# Connect to the database 
# conn = psycopg2.connect(database="BT5110_Project",
#                         user="postgres", 
#                         password="adison", 
#                         host="localhost", port="5432") 
  
# # create a cursor 
# cur = conn.cursor() 
  
# # commit the changes 
# conn.commit() 
  
# # close the cursor and connection 
# cur.close() 
# conn.close() 


@app.route("/")
def index():
    # render template
    return render_template("index.html", app_data=app_data)


@app.route("/shipquery")
def shipquery():

    # Connect to the database 
    conn = psycopg2.connect(database="BT5110_Project", user="postgres", password="adison", host="localhost", port="5432")
 
    # create a cursor 
    cur = conn.cursor() 
  
    # Write SQL query here 
    cur.execute('''SELECT * FROM status''') 
  
    # Fetch the data 
    data = cur.fetchall() 
  
    # close the cursor and connection 
    cur.close() 
    conn.close() 

    return render_template("shipquery.html", app_data=app_data, data=data)

# Ship by Day month
@app.route('/ships-daymonth', methods=['GET'])
def query_form():
    return render_template('ships-daymonth.html', app_data=app_data)

@app.route('/ships-daymonth-results', methods=['POST'])
def execute_query():
    try:
        # Get user input from the form
        search_type = request.form.get("search_type")
        calendar_year = request.form.get("calendar_year")
        month_number = request.form.get("month_number")
        day_number_in_month = request.form.get("day_number_in_month")

        # Connect to the database
        conn = psycopg2.connect(database="BT5110_Project", user="postgres", password="adison", host="localhost", port="5432")
        cur = conn.cursor()

        if search_type == "month_year":
            query = """
            SELECT d.date, d.weekday_indicator, d.holiday_indicator, v.shipcategory, COUNT(DISTINCT f.shipid), mf.avgspeed, mf.stdspeed, mf.minspeed, mf.maxspeed
            FROM facts f, date_ d, vessels v, measuredfacts mf
            WHERE f.date_ = d.date
                AND d.calendar_year = %s
                AND d.month_number = %s
                AND f.shipid = v.shipid
                AND mf.date = d.date
                AND mf.shipcategory = v.shipcategory
                AND mf.geo_subcategory = 'Sea'
                AND f.date_ = mf.date
            GROUP BY d.day_number_in_year, d.date, d.weekday_indicator, d.holiday_indicator, v.shipcategory, mf.avgspeed, mf.stdspeed, mf.minspeed, mf.maxspeed
            ORDER BY d.day_number_in_year ASC;
            """
            cur.execute(query, (calendar_year, month_number))
        else:
            query = """
            SELECT d.date, d.weekday_indicator, d.holiday_indicator, v.shipcategory, COUNT(DISTINCT f.shipid), mf.avgspeed, mf.stdspeed, mf.minspeed, mf.maxspeed
            FROM facts f, date_ d, vessels v, measuredfacts mf
            WHERE f.date_ = d.date
                AND d.calendar_year = %s
                AND d.month_number = %s
                AND d.day_number_in_month = %s
                AND f.shipid = v.shipid
                AND mf.date = d.date
                AND mf.shipcategory = v.shipcategory
                AND mf.geo_subcategory = 'Sea'
                AND f.date_ = mf.date
            GROUP BY d.day_number_in_year, d.date, d.weekday_indicator, d.holiday_indicator, v.shipcategory, mf.avgspeed, mf.stdspeed, mf.minspeed, mf.maxspeed
            ORDER BY d.day_number_in_year ASC;
            """
            cur.execute(query, (calendar_year, month_number, day_number_in_month))

        data = cur.fetchall()

        # Close the cursor and connection
        cur.close()
        conn.close()

        return render_template("ships-daymonth-results.html", app_data=app_data, data=data)
    except Exception as e:
        return f"Error: {str(e)}"


# Ships by Time period
@app.route('/ships-timeperiod', methods=['GET'])
def query_form_timeperiod():
    return render_template('ships-timeperiod.html', app_data=app_data)

@app.route('/ships-timeperiod-results', methods=['POST'])
def execute_query_timeperiod():
    try:
        # Get user input from the form
        search_type = request.form.get("search_type")
        calendar_year = request.form.get("calendar_year")
        month_number = request.form.get("month_number")
        day_number_in_month = request.form.get("day_number_in_month")
        port_name = request.form.get("port_name")

        # Connect to the database
        conn = psycopg2.connect(database="BT5110_Project", user="postgres", password="adison", host="localhost", port="5432")
        cur = conn.cursor()

        if search_type == "month_year_port":
            query = """
            SELECT d.month_abb, d.calendar_year, mscf.geo_subcategory, mscf.shipcategory, mscf.day_part_segment, SUM(mscf.shipcount) 
            FROM measuredshipcountfacts mscf, date_ d
            WHERE mscf.geo_subcategory = %s
                AND mscf.date = d.date
                AND d.month_number = %s
                AND d.calendar_year = %s
            GROUP BY d.month_abb, d.calendar_year, mscf.day_part_segment, mscf.geo_subcategory, mscf.shipcategory
            ORDER BY mscf.geo_subcategory ASC, mscf.shipcategory ASC, mscf.day_part_segment ASC;
            """
            cur.execute(query, (port_name, month_number, calendar_year))
            column_names = ["Month", "Year", "Port", "Ship Type", "Day Part", "Count"]

        elif search_type == "day_month_year_port":
            query = """
            SELECT d.date, d.dayofweek_abb, d.weekday_indicator, d.holiday_indicator, mscf.geo_subcategory, mscf.shipcategory, mscf.day_part_segment, SUM(mscf.shipcount) 
            FROM measuredshipcountfacts mscf, date_ d
            WHERE mscf.geo_subcategory = %s
                AND mscf.date = d.date
                AND d.month_number = %s
                AND d.calendar_year = %s
                AND d.day_number_in_month = %s
            GROUP BY d.date, d.dayofweek_abb, d.weekday_indicator, d.holiday_indicator, mscf.day_part_segment, mscf.geo_subcategory, mscf.shipcategory
            ORDER BY mscf.geo_subcategory ASC, mscf.shipcategory ASC, mscf.day_part_segment ASC;
            """
            cur.execute(query, (port_name, month_number, calendar_year, day_number_in_month))
            column_names = ["Date", "Week", "Weekday?", "Holiday?", "Port", "Ship Type", "Day Part", "Count"]

        elif search_type == "month_year_all":
            query = """
            SELECT d.month_abb, d.calendar_year, mscf.geo_subcategory, mscf.shipcategory, mscf.day_part_segment, SUM(mscf.shipcount) 
            FROM measuredshipcountfacts mscf, date_ d
            WHERE (mscf.geo_subcategory = 'Port Brani'
                    OR mscf.geo_subcategory = 'Port Bukom'
                    OR mscf.geo_subcategory = 'Port Jurong Island'
                    OR mscf.geo_subcategory = 'Port Marina Bay Cruise Centre'
                    OR mscf.geo_subcategory = 'Port Pasir Panjang'
                    OR mscf.geo_subcategory = 'Port Tanjong Pagar'
                    OR mscf.geo_subcategory = 'Port Tuas')
                AND mscf.date = d.date
                AND d.month_number = %s
                AND d.calendar_year = %s
            GROUP BY d.month_abb, d.calendar_year, mscf.day_part_segment, mscf.geo_subcategory, mscf.shipcategory
            ORDER BY mscf.geo_subcategory ASC, mscf.shipcategory ASC, mscf.day_part_segment ASC;
            """
            cur.execute(query, (month_number, calendar_year))
            column_names = ["Month", "Year", "Port", "Ship Type", "Day Part", "Count"]

        else:
            query = """
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
                AND d.month_number = %s
                AND d.calendar_year = %s
                AND d.day_number_in_month = %s
            GROUP BY d.date, d.dayofweek_abb, d.weekday_indicator, d.holiday_indicator, mscf.day_part_segment, mscf.geo_subcategory, mscf.shipcategory
            ORDER BY mscf.geo_subcategory ASC, mscf.shipcategory ASC, mscf.day_part_segment ASC;
            """
            cur.execute(query, (month_number, calendar_year, day_number_in_month))
            column_names = ["Date", "Week", "Weekday?", "Holiday?", "Port", "Ship Type", "Day Part", "Count"]

        data = cur.fetchall()

        # Close the cursor and connection
        cur.close()
        conn.close()
        return render_template("ships-timeperiod-results.html", app_data=app_data, data=data, columns=column_names)
    except Exception as e:
        return f"Error: {str(e)}"


if __name__ == "__main__":
    app.run(debug=DEVELOPMENT_ENV)
