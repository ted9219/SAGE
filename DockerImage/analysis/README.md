# SAGE

Requirements
============

- A database in [Common Data Model version 5](https://github.com/OHDSI/CommonDataModel) in one of these platforms: SQL Server, Oracle, PostgreSQL, IBM Netezza, Apache Impala, Amazon RedShift, Google BigQuery, or Microsoft APS.
- R version 4.0.0 or newer
- On Windows: [RTools](http://cran.r-project.org/bin/windows/Rtools/)
- [Java](http://java.com)
- 25 GB of free disk space

How to run
==========
1. Follow [these instructions](https://ohdsi.github.io/Hades/rSetup.html) for setting up your R environment, including RTools and Java.

2. Open your study package in RStudio. Use the following code to install all the dependencies:

	```r
	install.packages('devtools')
	install.packages('dplyr')
	install.packages('data.table')
	install.packages('R.utils')
	install.packages('rvg')
	install.packages('renv')
	install.packages('lubridate')

	devtools::install_github("OHDSI/DatabaseConnector",ref="v5.0.2")
	devtools::install_github("OHDSI/ParallelLogger",ref="v2.0.2")
	```
	
	Or use dockerfile in `DockerImage`

	Build Docker Image
	```
	$docker build --build-arg GIT_ACCESS_TOKEN=[insert-access-token-here] -t [image_name]:[image_tag] .
	```
	Run Docker Container
	```
	$docker run --name [conatainer_name] -e USER=user -e PASSWORD=password -p 8787:8787 [image_name]:[image_tag]
	```

3. In RStudio, select 'Build' then 'Install and Restart' to build the package.

4. Once installed, you can execute the study by modifying and using the code below. For your convenience, this code is also provided under `extras/CodeToRun.R`:

	```r
	library(SAGE)

	# The folder where the study intermediate and result files will be written:
	outputFolder <- file.path("outputFolderDir")

	connectionDetails <- DatabaseConnector::createConnectionDetails(
	  dbms = 'postgresql',
	  server = 'myserver',
	  user = 'joe',
	  password = 'secret',
	  pathToDriver = 'S:/jdbcDrivders'
	)


	# The name of the database schema where the CDM data can be found:
	cdmDatabaseSchema<-'CDM_mydb.dbo'

	# The name of the database schema and table where the study-specific cohorts will be instantiated:
	cohortDatabaseSchema <- 'mydb.dbo'
	cohortTable <- "SAGE"

	# Some meta-information that will be used by the export function:
	databaseName <- 'MYDATABASE'


	execute(connectionDetails = connectionDetails,
	        cdmDatabaseSchema = cdmDatabaseSchema,
	        cohortDatabaseSchema = cohortDatabaseSchema,
	        cohortTable = cohortTable,
	        outputFolder = outputFolder,
	        databaseName = databaseName,
	        createCohorts = TRUE,
	        runPrescriptionNum = TRUE,
	        runDUR = TRUE,
	        resultsToZip = TRUE,
	        yearStartDate = as.Date("2006-01-01"),
	        yearEndDate = as.Date("2022-12-31"),
	        monthStartDate = as.Date("2006-01-01"),
	        monthEndDate = as.Date("2022-12-31"))

	```

5. Share the file ```drugCohort_<DatabaseId>.zip``` in the output folder to the study coordinator

Development
===========
SAGE package is in development
