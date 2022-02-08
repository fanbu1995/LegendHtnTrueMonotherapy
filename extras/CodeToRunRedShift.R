

Sys.setenv(DATABASECONNECTOR_JAR_FOLDER='D:/Drivers')

## Optum DoD

cdmDatabaseSchema <- "cdm_optum_extended_dod_v1825" #"cdm_truven_ccae_v1709" #"cdm_idm_ccae_seta"
serverSuffix <-"optum_extended_dod" #"truven_ccae" # "ibm"
cohortDatabaseSchema <- "scratch_fbu2"
databaseId<- "CCAE"
databaseName <- "IBM Health MarketScan® Commercial Claims and Encounters"
databaseDescription <- "IBM MarketScan® Commercial Claims and Encounters (CCAE) adjudicated US health insurance claims for Medicaid enrollees from multiple states and includes hospital discharge diagnoses, outpatient diagnoses and procedures, and outpatient pharmacy claims as well as ethnicity and Medicare eligibility. Members maintain their same identifier even if they leave the system for a brief period however the dataset lacks lab data."
tablePrefix <- "legend_t2dm_ccae"
outputFolder <- "d:/LegendMonotherapy_OptumDOD" # DONE

## IBM CCAE
cdmDatabaseSchema <- "cdm_truven_ccae_v1709" #"cdm_idm_ccae_seta"
serverSuffix <- "truven_ccae" # "ibm"
cohortDatabaseSchema <- "scratch_fbu2"
databaseId<- "CCAE"
databaseName <- "IBM Health MarketScan® Commercial Claims and Encounters"
databaseDescription <- "IBM MarketScan® Commercial Claims and Encounters (CCAE) adjudicated US health insurance claims for Medicaid enrollees from multiple states and includes hospital discharge diagnoses, outpatient diagnoses and procedures, and outpatient pharmacy claims as well as ethnicity and Medicare eligibility. Members maintain their same identifier even if they leave the system for a brief period however the dataset lacks lab data."
tablePrefix <- "legend_monotherapy_ccae"
outputFolder <- "d:/LegendMonotherapy_ccae" # DONE

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
