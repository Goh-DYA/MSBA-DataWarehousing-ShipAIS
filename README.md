# MSBA Project: Data Warehousing of Ship AIS Data

This repository contains the content from the BT5110 Group Project on data warehousing of Ship AIS Data.

### Project Objective:
The primary aim of this project is to design and populate a database warehouse for AIS messages and build an interface to query the data warehouse.  The AIS database warehouse serves as a structured data environment that is optimised for aggregation (“roll-up”) and de-aggregation (“drill down”) of information along any specific dimension (i.e., “slicing and dicing”).  The end goal is to enable business users to easily analyse the AIS data and reap maximum value from the large volumes of AIS data.  


### Project & Report Structure:
The methodology & results of this project are detailed in the PDF document "Grp12_BT5110_Project_Report.pdf".
We structured our report according to Kimball’s 4 Steps Dimensional Design Process: 
1. We will first identify the business process and outline the business objectives of the AIS database warehouse.   
2. Next, we will explain the choice of AIS scope and steps taken to stage and clean the raw AIS data – this will establish the “grain” of the business process (as Step 2 of Kimball’s 4 Steps Dimensional Design Process). 
3. In step 3 of Dimensional Design Process, we will explain the dimension tables and population process. 
4. As the last step of Dimensional Design Process, we outline the facts and measures in our relational fact table. 
5. We will then present our Star Schema and an illustration of the multi-dimensional data cube of our schema. 
6. Lastly, we will propose 4 business questions with 9 sub-queries on the database warehouse to address the business objectives and demonstrate the use of an interface to access and query the database warehouse. 

### Github Repo Folders:
- Data Cleaning & Processing: Python codes that were applied for processing of raw data before staging
- Flask Interface: Python / HTML codes for Flask interface
- SQL Database: Content of SQL data warehouse
- SQL Queries: SQL queries utilised for visualisation in PowerBI or Flask

### Ship AIS Logs Data Source: 
https://data.liancheng.science/
