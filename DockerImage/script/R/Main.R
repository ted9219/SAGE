#' Execute the Study
#'
#' @details
#' This function executes the SAGE Study.
#'
#' The \code{createCohorts}, \code{createAllCohorts}, \code{computePrescriptionNum} arguments
#' are intended to be used to run parts of the full study at a time, but none of the parts are considered to be optional.
#'
#' @param connectionDetails    An object of type \code{connectionDetails} as created using the
#'                             \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                             DatabaseConnector package.
#' @param cdmDatabaseSchema    Schema name where your patient-level data in OMOP CDM format resides.
#'                             Note that for SQL Server, this should include both the database and
#'                             schema name, for example 'cdm_data.dbo'.
#' @param cohortDatabaseSchema Schema name where intermediate data can be stored. You will need to have
#'                             write priviliges in this schema. Note that for SQL Server, this should
#'                             include both the database and schema name, for example 'cdm_data.dbo'.
#' @param cohortTable          The name of the table that will be created in the work database schema.
#'                             This table will hold the exposure and outcome cohorts used in this
#'                             study.
#' @param outputFolder         Name of local folder to place results; make sure to use forward slashes
#'                             (/). Do not use a folder on a network drive since this greatly impacts
#'                             performance.
#' @param databaseName         The name of the database (e.g. 'SynPUFs').
#' @param createCohorts        Create the cohortTable table with the exposure and outcome cohorts?
#' @param runPrescriptionNum   Calculate the monthly prescription numbers?
#' @param runDUR               Calculate the monthly prescription numbers of DUR?
#' @param resultsToZip         Create the zip files?
#' @param yearStartDate        Start date of observation period, has to be on or later than 2006-01-01
#' @param yearEndDate          End date of observation period, has to be on or earlier than the latest date in the database
#' @param monthStartDate       Start date for monthly prescription numbers, has to be on or later than 2006-01-01
#' @param monthEndDate         End date for monthly prescription numbers, has to on or earlier than the latest date in the database
#'
#' @examples
#' \dontrun{
#' connectionDetails <- createConnectionDetails(dbms = "redshift",
#'                                              user = "joe",
#'                                              password = "secret",
#'                                              server = "myserver")
#'
#' execute(connectionDetails,
#'         cdmDatabaseSchema = "cdm_data",
#'         cohortDatabaseSchema = "study_results",
#'         cohortTable = "cohort",
#'         outputFolder = "c:/temp/study_results")
#' }
#'
#' @export
execute <- function(connectionDetails,
                    cdmDatabaseSchema,
                    cohortDatabaseSchema,
                    cohortTable,
                    outputFolder,
                    databaseName = "Unknown",
                    createCohorts = TRUE,
                    runPrescriptionNum = TRUE,
                    runDUR = TRUE,
                    resultsToZip = TRUE,
                    yearStartDate = as.Date("2006-01-01"),
                    yearEndDate = as.Date("2022-12-31"),
                    monthStartDate = as.Date("2006-01-01"),
                    monthEndDate = as.Date("2022-12-31")) {

  if (!file.exists(outputFolder))
    dir.create(outputFolder, recursive = TRUE)

  if (!file.exists(file.path(outputFolder, "results")))
    dir.create(file.path(outputFolder, "results"))

  ParallelLogger::addDefaultFileLogger(file.path(outputFolder, "log.txt"))
  ParallelLogger::addDefaultErrorReportLogger(file.path(outputFolder, "errorReportR.txt"))
  on.exit(ParallelLogger::unregisterLogger("DEFAULT_FILE_LOGGER", silent = TRUE))
  on.exit(ParallelLogger::unregisterLogger("DEFAULT_ERRORREPORT_LOGGER", silent = TRUE), add = TRUE)


  if (createCohorts) {
    ParallelLogger::logInfo("Creating Drug Cohort Table")
    createAllCohorts(connectionDetails = connectionDetails,
                     cdmDatabaseSchema = cdmDatabaseSchema,
                     cohortDatabaseSchema = cohortDatabaseSchema,
                     cohortTable = cohortTable,
                     outputFolder = outputFolder,
                     yearStartDate=yearStartDate,
                     yearEndDate=yearEndDate)
  }


  if (runPrescriptionNum) {
    computePrescriptionNum(monthStartDate = monthStartDate,
                           monthEndDate = monthEndDate,
                           databaseName = databaseName,
                           outputFolder = outputFolder)
  }

  if (runDUR) {

    DURPrescriptionNum(monthStartDate = monthStartDate,
                       monthEndDate = monthEndDate,
                       databaseName = databaseName,
                       outputFolder = outputFolder)
  }


  if (resultsToZip) {

    saveZipfile(databaseName,
                outputFolder)
  }

  invisible(NULL)
}
