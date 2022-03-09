
library(LEGENDHTNTrueMonotherapy)

# Optional: specify where the temporary files (used by the Andromeda package) will be created:
options(andromedaTempFolder = "E:/andromedaTemp")

# Maximum number of cores to be used:
maxCores <- 1 #parallel::detectCores()

# specify where the Drivers are
Sys.setenv(DATABASECONNECTOR_JAR_FOLDER='D:/Drivers')

## 1a. Optum DoD------------
cdmDatabaseSchema <- "cdm_optum_extended_dod_v1825" 
serverSuffix <-"optum_extended_dod" 
cohortDatabaseSchema <- "scratch_fbu2"
databaseId <- "OptumDod"
databaseName <- "Optum Clinformatics Extended Data Mart - Date of Death (DOD)"
databaseDescription <- "Optum Clinformatics Extended DataMart is an adjudicated US administrative health claims database for members of private health insurance, who are fully insured in commercial plans or in administrative services only (ASOs), Legacy Medicare Choice Lives (prior to January 2006), and Medicare Advantage (Medicare Advantage Prescription Drug coverage starting January 2006).  The population is primarily representative of commercial claims patients (0-65 years old) with some Medicare (65+ years old) however ages are capped at 90 years.  It includes data captured from administrative claims processed from inpatient and outpatient medical services and prescriptions as dispensed, as well as results for outpatient lab tests processed by large national lab vendors who participate in data exchange with Optum.  This dataset also provides date of death (month and year only) for members with both medical and pharmacy coverage from the Social Security Death Master File (however after 2011 reporting frequency changed due to changes in reporting requirements) and location information for patients is at the US state level."
tablePrefix <- "legend_monotherapy_OptumDoD"
outputFolder <- "E:/LegendMonotherapy_OptumDod2" # DONE # changed the save directory

## 1b. Optum EHR ---------------
cdmDatabaseSchema <- "cdm_optum_ehr_v1821"
serverSuffix <- "optum_ehr"
cohortDatabaseSchema <- "scratch_fbu2"
databaseId <- "OptumEHR"
databaseName <- "Optum© de-identified Electronic Health Record Dataset"
databaseDescription <- "Optum© de-identified Electronic Health Record Dataset represents Humedica’s Electronic Health Record data a medical records database. The medical record data includes clinical information, inclusive of prescriptions as prescribed and administered, lab results, vital signs, body measurements, diagnoses, procedures, and information derived from clinical Notes using Natural Language Processing (NLP)."
tablePrefix <- "legend_monotherapy_ehr"
outputFolder <- "d:/LegendMonotherapy_OptumEhr" # DONE

## 2. IBM MDCD ------------------
# cdmDatabaseSchema <- "cdm_truven_mdcd_v1714"
# serverSuffix <- "truven_mdcd"
# cohortDatabaseSchema <- "scratch_fbu2"
# databaseId<- "MDCD"
# databaseName <- "IBM Health MarketScan® Multi-State Medicaid Database"
# databaseDescription <- "IBM MarketScan® Multi-State Medicaid Database (MDCD) adjudicated US health insurance claims for Medicaid enrollees from multiple states and includes hospital discharge diagnoses, outpatient diagnoses and procedures, and outpatient pharmacy claims as well as ethnicity and Medicare eligibility. Members maintain their same identifier even if they leave the system for a brief period however the dataset lacks lab data."
# tablePrefix <- "legend_monotherapy_mdcd"
# outputFolder <- "d:/LegendMonotherapy_mdcd" # DONE

## 3. IBM CCAE ------------
cdmDatabaseSchema <- "cdm_truven_ccae_v1709" #"cdm_idm_ccae_seta"
serverSuffix <- "truven_ccae" # "ibm"
cohortDatabaseSchema <- "scratch_fbu2"
databaseId<- "CCAE"
databaseName <- "IBM Health MarketScan® Commercial Claims and Encounters"
databaseDescription <- "IBM MarketScan® Commercial Claims and Encounters (CCAE) adjudicated US health insurance claims for Medicaid enrollees from multiple states and includes hospital discharge diagnoses, outpatient diagnoses and procedures, and outpatient pharmacy claims as well as ethnicity and Medicare eligibility. Members maintain their same identifier even if they leave the system for a brief period however the dataset lacks lab data."
tablePrefix <- "legend_monotherapy_ccae"
outputFolder <- "d:/LegendMonotherapy_ccae" # DONE

## 4. IBM MDCR --------------
# cdmDatabaseSchema <- "cdm_truven_mdcr_v1838"
# serverSuffix <- "truven_mdcr"
# cohortDatabaseSchema <- "scratch_fbu2"
# databaseId<- "MDCR"
# databaseName <- "IBM Health MarketScan Medicare Supplemental and Coordination of Benefits Database"
# databaseDescription <- "IBM Health MarketScan® Medicare Supplemental and Coordination of Benefits Database (MDCR) represents health services of retirees in the United States with primary or Medicare supplemental coverage through privately insured fee-for-service, point-of-service, or capitated health plans. These data include adjudicated health insurance claims (e.g. inpatient, outpatient, and outpatient pharmacy). Additionally, it captures laboratory tests for a subset of the covered lives."
# tablePrefix <- "legend_monotherapy_mdcr"
# outputFolder <- "d:/LegendMonotherapy_mdcr" # DONE

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
        createCohorts = FALSE,
        synthesizePositiveControls = FALSE,
        runAnalyses = FALSE,
        covariateBalance = FALSE,
        packageResults = TRUE,
        maxCores = maxCores)

# prepare for RShiny
resultsZipFile <- file.path(outputFolder, "export", paste0("Results_", databaseId, ".zip"))
dataFolder <- file.path(outputFolder, "shinyData")

# You can inspect the results if you want:
prepareForEvidenceExplorer(resultsZipFile = resultsZipFile, dataFolder = dataFolder)
launchEvidenceExplorer(dataFolder = dataFolder, blind = FALSE, launch.browser = TRUE) # need to set blind=FALSE first



#DatabaseConnector::disconnect(connection)
