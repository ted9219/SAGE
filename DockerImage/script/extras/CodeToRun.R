library(SAGE)

# The folder where the study intermediate and result files will be written:
outputFolder <- '/data/results'

connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",
  server = paste0(strsplit(Sys.getenv("MEDICAL_RECORDS_URL"), ':')[[1]][1], "/", Sys.getenv("MEDICAL_RECORDS_DATABASE")),
  user = Sys.getenv("MEDICAL_RECORDS_USER"),
  password = Sys.getenv("MEDICAL_RECORDS_PW"),
  port = strsplit(Sys.getenv("MEDICAL_RECORDS_URL"), ':')[[1]][2],
  pathToDriver = '/home/script/jdbc'
)

# The name of the database schema where the CDM data can be found:
cdmDatabaseSchema <- Sys.getenv("MEDICAL_RECORDS_SCHEMA")
cohortDatabaseSchema <- paste0(Sys.getenv("MEDICAL_RECORDS_SCHEMA"),'_results_exec')

cohortTable <- "cohort"

# Some meta-information that will be used by the export function:
databaseName = Sys.getenv("MEDICAL_RECORDS_SCHEMA")


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
