DURPrescriptionNum <- function(monthStartDate,
                               monthEndDate,
                               databaseName,
                               outputFolder) {

  monthStartDate <- max(as.Date(monthStartDate), as.Date("2006-01-01"))
  monthEndDate <- as.Date(monthEndDate)

  tmpDir <- file.path(outputFolder, "tmpData")

  resultsDir <- file.path(outputFolder, "results")

  `%>%` <- magrittr::`%>%`
  '%!in%' <- Negate('%in%')

  cohortsToCreate <- read.csv(file.path("inst", "settings", "CohortsToCreate.csv"))

  ParallelLogger::logInfo("Calculating prescription numbers of DUR")
  for (i in cohortsToCreate[cohortsToCreate$cohortType=="DUR", "cohortId"]){
    writeLines(paste("Calculating prescription numbers of DUR:", cohortsToCreate[cohortsToCreate$cohortId==i, "name"]))


    targetDrug <- readRDS(file.path(tmpDir, paste0("drugCohort_", i, ".RDS")))

    targetDrug <- targetDrug %>%
      dplyr::mutate(period = as.numeric(difftime(COHORT_END_DATE, COHORT_START_DATE, units = "days"))+1)

    limit <- cohortsToCreate[cohortsToCreate$cohortId == i, "ageLimit"]

    if (cohortsToCreate[cohortsToCreate$cohortId == i, "range"] == "above") {

      targetDrug <- targetDrug %>%
        dplyr::filter(AGE >= limit)

    } else if (cohortsToCreate[cohortsToCreate$cohortId == i, "range"] == "exceed") {

      targetDrug <- targetDrug %>%
        dplyr::filter(AGE > limit)

    } else if (cohortsToCreate[cohortsToCreate$cohortId == i, "range"] == "upto") {

      targetDrug <- targetDrug %>%
        dplyr::filter(AGE <= limit)

    } else if (cohortsToCreate[cohortsToCreate$cohortId == i, "range"] == "under") {

      targetDrug <- targetDrug %>%
        dplyr::filter(AGE < limit)
    }

    firstRx<- targetDrug %>%
      dplyr::group_by(SUBJECT_ID) %>%
      dplyr::arrange(COHORT_START_DATE) %>%
      dplyr::filter(dplyr::row_number()==1) %>%
      dplyr::ungroup()

    whole_mth <- data.frame()
    yearMth_seq <- seq(monthStartDate, monthEndDate, by = "month")

    for(m in as.list(yearMth_seq)){
      whole_mth_m <- targetDrug %>%
        dplyr::filter(m == start_yearMth) %>%
        dplyr::mutate(calDate = m) %>%
        dplyr::group_by(calDate) %>%
        dplyr::summarise(prescriptions = dplyr::n(),
                         person = dplyr::n_distinct(SUBJECT_ID),
                         periodSum = sum(period), .groups = 'drop')
      whole_mth <- rbind(whole_mth, whole_mth_m)
    }

    prescriptionNum <- whole_mth

    for (m in as.list(yearMth_seq)) {
      if (m %!in% whole_mth$calDate) {
        row <- data.frame(m, 0, 0, 0)
        names(row) <- c("calDate", "prescriptions", "person", "periodSum")
        prescriptionNum <- rbind(prescriptionNum, row)
      }

    }

    rm(whole_mth)
    rm(whole_mth_m)

    whole_mth_first <- data.frame()

    for(m in as.list(yearMth_seq)){
      whole_mth_m_first <- firstRx %>%
        dplyr::filter(m == start_yearMth) %>%
        dplyr::mutate(calDate = m) %>%
        dplyr::group_by(calDate) %>%
        dplyr::summarise(prescriptionsFirst = dplyr::n(),
                         periodSumFirst = sum(period), .groups = 'drop')
      whole_mth_first <- rbind(whole_mth_first, whole_mth_m_first)
    }

    firstRxNum <- whole_mth_first

    for (m in as.list(yearMth_seq)) {
      if (m %!in% whole_mth_first$calDate) {
        row <- data.frame(m, 0, 0)
        names(row) <- c("calDate", "prescriptionsFirst", "periodSumFirst")
        firstRxNum <- rbind(firstRxNum, row)
      }

    }

    rm(whole_mth_first)
    rm(whole_mth_m_first)

    totalRxNum <- merge(prescriptionNum, firstRxNum, by = "calDate")

    totalRxNum <- totalRxNum %>%
      dplyr::arrange(calDate) %>%
      dplyr::mutate(database = databaseName)

    write.csv(totalRxNum, file.path(resultsDir, paste0("drugCohort_", i, ".csv")))

  }

}
