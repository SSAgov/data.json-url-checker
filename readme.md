# Data.JSON URL Checker 

 Data.JSON URL Checker is a standalone PowerShell script to test the validity of URLs in the Data.JSON file.
  
## What does Data.JSON URL Checker do?

1.	Scans Data.JSON file structure using project open data schema v1.1 (https://project-open-data.cio.gov/v1.1/schema/)
2.	Reads all possible field with type of URLs according to schema
3.  Checks if the field contains a value of url
4.	Collects all urls with fields name
5.  Test each url by executing HTTP request and Collects responses of HTTP request
6.  Generates .CSV file as a report of all urls tested, field location and responses.

## What problem does Data.JSON URL Checker solve?
For federal government agencies required to deliver data.JSON file, this scripts helps agency test URLs from their Data.JSON files before publishing.	

## How do I run the script?

Data.JSON URL Checker is a PowerShell script. Please see following steps to execute the url checker.

1.  Please download, copy and paste this script in the same directory as data.json file.
2.  Optional: If you are using http proxy to execute http requests. open the script with any text editor and apply value to $proxy variable on the top for the proxy link and save the file. 
3.  Execute the script by right click and select to run with PowerShell.
4.  This script will log url testing activity status on command prompt.
5.  Once script is finished executing it will generate the report with .csv file
6.  Log status code of each url along with status code and format. 


## Who maintains Data.JSON URL Checker?

Data.JSON URL Checker is maintained by the Open Source Staff at SSA.
