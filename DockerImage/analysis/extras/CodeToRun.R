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
