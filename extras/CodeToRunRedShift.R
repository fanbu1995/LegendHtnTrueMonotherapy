
library(LEGENDHTNTrueMonotherapy)

# Optional: specify where the temporary files (used by the Andromeda package) will be created:
options(andromedaTempFolder = "d:/andromedaTemp")

# Maximum number of cores to be used:
maxCores <- parallel::detectCores()

# specify where the Drivers are
Sys.setenv(DATABASECONNECTOR_JAR_FOLDER='D:/Drivers')

## 1. Optum DoD------------
cdmDatabaseSchema <- "cdm_optum_extended_dod_v1825" #"cdm_truven_ccae_v1709" #"cdm_idm_ccae_seta"
serverSuffix <-"optum_extended_dod" #"truven_ccae" # "ibm"
cohortDatabaseSchema <- "scratch_fbu2"
databaseId <- "OptumDod"
databaseName <- "Optum Clinformatics Extended Data Mart - Date of Death (DOD)"
databaseDescription <- "Optum Clinformatics Extended DataMart is an adjudicated US administrative health claims database for members of private health insurance, who are fully insured in commercial plans or in administrative services only (ASOs), Legacy Medicare Choice Lives (prior to January 2006), and Medicare Advantage (Medicare Advantage Prescription Drug coverage starting January 2006).  The population is primarily representative of commercial claims patients (0-65 years old) with some Medicare (65+ years old) however ages are capped at 90 years.  It includes data captured from administrative claims processed from inpatient and outpatient medical services and prescriptions as dispensed, as well as results for outpatient lab tests processed by large national lab vendors who participate in data exchange with Optum.  This dataset also provides date of death (month and year only) for members with both medical and pharmacy coverage from the Social Security Death Master File (however after 2011 reporting frequency changed due to changes in reporting requirements) and location information for patients is at the US state level."
tablePrefix <- "legend_t2dm_ccae"
outputFolder <- "d:/LegendMonotherapy_OptumDOD" # DONE

## 3. IBM CCAE ------------
cdmDatabaseSchema <- "cdm_truven_ccae_v1709" #"cdm_idm_ccae_seta"
serverSuffix <- "truven_ccae" # "ibm"
cohortDatabaseSchema <- "scratch_fbu2"
databaseId<- "CCAE"
databaseName <- "IBM Health MarketScan® Commercial Claims and Encounters"
databaseDescription <- "IBM MarketScan® Commercial Claims and Encounters (CCAE) adjudicated US health insurance claims for Medicaid enrollees from multiple states and includes hospital discharge diagnoses, outpatient diagnoses and procedures, and outpatient pharmacy claims as well as ethnicity and Medicare eligibility. Members maintain their same identifier even if they leave the system for a brief period however the dataset lacks lab data."
tablePrefix <- "legend_monotherapy_ccae"
outputFolder <- "d:/LegendMonotherapy_ccae" # DONE

## fill out connection details ------------
conn <- DatabaseConnector::createConnectionDetails(
  dbms = "redshift",
  server = paste0(keyring::key_get("epi_server"), "/", !!serverSuffix),
  port = 5439,
  user = keyring::key_get("redshiftUser"),
  password = keyring::key_get("redshiftPassword"),
  extraSettings = "ssl=true&sslfactory=com.amazon.redshift.ssl.NonValidatingFactory",
  pathToDriver = 'D:/Drivers')

# connection = DatabaseConnector::connect(connectionDetails = conn)

# sql <- "SELECT COUNT(*) from cdm_truven_ccae_1247.COHORT"
# sql <- SqlRender::translate(sql, targetDialect = connection@dbms)
# count_cohort <- DatabaseConnector::querySql(connection, sql)


oracleTempSchema <- NULL
cohortTable = 'cohort_fbu2'

execute(connectionDetails = conn,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        oracleTempSchema = oracleTempSchema,
        outputFolder = outputFolder,
        databaseId = databaseId,
        databaseName = databaseName,
        databaseDescription = databaseDescription,
        createCohorts = TRUE,
        synthesizePositiveControls = FALSE,
        runAnalyses = FALSE,
        packageResults = FALSE,
        maxCores = maxCores)


DatabaseConnector::disconnect(connection)
