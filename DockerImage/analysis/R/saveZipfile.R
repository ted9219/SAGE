saveZipfile <- function(databaseName,
                       outputFolder) {

  resultsDir <- file.path(outputFolder, "results")

  message("Adding results to zip file")
  zipName <- file.path(outputFolder, sprintf("drugCohort_%s.zip", databaseName))
  files <- list.files(resultsDir, pattern = ".*\\.csv$")
  oldWd <- setwd(resultsDir)
  on.exit(setwd(oldWd))
  DatabaseConnector::createZipFile(zipFile = zipName, files = files)

}


