/*
Missing Data Project
Daniel Yang / Aneja Lab
Input: NCDB dta file
Output: generate output file where all missing and unknowns are replaced with "" for strings and . for numerics within Stata
Created 2020-10-22
Last Edited 2020-10-22
*/

frames reset
use "lungNSC.dta"

*include only cases diagnosed in 2006 to 2015
keep if YEAR_OF_DIAGNOSIS >= 2006 & YEAR_OF_DIAGNOSIS <= 2015

*exclude variables where variable is not used for all years <2016
drop CS_METS_DX_*
drop METS_AT_DX_*
drop LYMPH_VASCULAR_INVASION
drop RX_SUMM_SCOPE_REG_LN_2012
drop TUMOR_SIZE_SUMMARY
drop RX_HOSP_SURG_APPR_2010
drop RX_SUMM_TREATMENT_STATUS
*exclude site-specific variables
drop CS_SITESPECIFIC_FACTOR_*

*review variables and recode sentinel values for missing to "" (for strings) and . (for numerics)
*variables that do not have an unknown category are commented out with *
*variables that are not used are commented out with //

*PUF_CASE_ID                 "Case Key"
*PUF_FACILITY_ID             "Facility Key"
*FACILITY_TYPE_CD            "Facility Type"
*FACILITY_LOCATION_CD        "Facility Location"

replace AGE = . if AGE == 999

replace SEX = . if SEX == 9

replace RACE = . if RACE == 99

replace SPANISH_HISPANIC_ORIGIN = . if SPANISH_HISPANIC_ORIGIN == 9

replace INSURANCE_STATUS = . if INSURANCE_STATUS == 9

*MED_INC_QUAR_00             "Median Income Quartiles 2000"
*NO_HSD_QUAR_00              "Percent No High School Degree Quartiles 2000"
*UR_CD_03                    "Urban/Rural 2003"
*MED_INC_QUAR_12			 "Median Income Quartiles 2008-2012"
*NO_HSD_QUAR_12			  	"Percent No High School Degree 2008-2012"
*UR_CD_13					 "Urban/Rural 2013"
*CROWFLY                     "Great Circle Distance"
*CDCC_TOTAL_BEST             "Charlson-Deyo Score"

replace SEQUENCE_NUMBER = "" if SEQUENCE_NUMBER == "99" | SEQUENCE_NUMBER == "88"

*CLASS_OF_CASE               "Class of Case"
*YEAR_OF_DIAGNOSIS           "Year of Diagnosis"
*PRIMARY_SITE                "Primary Site"

replace LATERALITY = . if LATERALITY == 9

*HISTOLOGY                   "Histology"
*BEHAVIOR                    "Behavior"

replace GRADE = . if GRADE == 9

replace DIAGNOSTIC_CONFIRMATION = . if DIAGNOSTIC_CONFIRMATION == 9

replace TUMOR_SIZE = . if TUMOR_SIZE == 999

replace REGIONAL_NODES_POSITIVE = . if REGIONAL_NODES_POSITIVE == 99

replace REGIONAL_NODES_EXAMINED = . if REGIONAL_NODES_EXAMINED >= 96 & REGIONAL_NODES_EXAMINED <= 99

*DX_STAGING_PROC_DAYS        "Surgical Dx and Staging Procedure, Days from Dx"

replace RX_SUMM_DXSTG_PROC = . if RX_SUMM_DXSTG_PROC == 9

*TNM_CLIN_T                  "AJCC Clinical T"
*TNM_CLIN_N                  "AJCC Clinical N"
*TNM_CLIN_M                  "AJCC Clinical M"

replace TNM_CLIN_STAGE_GROUP = "" if TNM_CLIN_STAGE_GROUP == "99"

*TNM_PATH_T                  "AJCC Pathologic T"
*TNM_PATH_N                  "AJCC Pathologic N"
*TNM_PATH_M                  "AJCC Pathologic M"

replace TNM_PATH_STAGE_GROUP = "" if TNM_PATH_STAGE_GROUP == "99" 

replace TNM_EDITION_NUMBER = . if TNM_EDITION_NUMBER == 99

replace ANALYTIC_STAGE_GROUP = . if ANALYTIC_STAGE_GROUP == 9

replace CS_METS_AT_DX = . if CS_METS_AT_DX == 99

replace CS_METS_EVAL = "" if CS_METS_EVAL == "9"

replace CS_EXTENSION = "" if CS_EXTENSION == "999"

replace CS_TUMOR_SIZEEXT_EVAL = "" if CS_TUMOR_SIZEEXT_EVAL == "9"

//CS_METS_DX_BONE			  "Metastatic Bone Involvement, 2010-2015"
//CS_METS_DX_BRAIN			  "Metastatic Brain Involvement, 2010-2015"
//CS_METS_DX_LIVER			  "Metastatic Liver Involvement, 2010-2015"
//CS_METS_DX_LUNG			  "Metastatic Lung Involvement, 2010-2015"
//LYMPH_VASCULAR_INVASION	  "Lymph Vascular Invasion, 2010"
//CS_SITESPECIFIC_FACTOR_1    "CS Site Specific Factor 1"
//CS_SITESPECIFIC_FACTOR_2    "CS Site Specific Factor 2"
//CS_SITESPECIFIC_FACTOR_3    "CS Site Specific Factor 3"
//CS_SITESPECIFIC_FACTOR_4    "CS Site Specific Factor 4"
//CS_SITESPECIFIC_FACTOR_5    "CS Site Specific Factor 5"
//CS_SITESPECIFIC_FACTOR_6    "CS Site Specific Factor 6"
//CS_SITESPECIFIC_FACTOR_7    "CS Site Specific Factor 7"
//CS_SITESPECIFIC_FACTOR_8    "CS Site Specific Factor 8"
//CS_SITESPECIFIC_FACTOR_9    "CS Site Specific Factor 9"
//CS_SITESPECIFIC_FACTOR_10   "CS Site Specific Factor 10"
//CS_SITESPECIFIC_FACTOR_11   "CS Site Specific Factor 11"
//CS_SITESPECIFIC_FACTOR_12   "CS Site Specific Factor 12"
//CS_SITESPECIFIC_FACTOR_13   "CS Site Specific Factor 13"
//CS_SITESPECIFIC_FACTOR_14   "CS Site Specific Factor 14"
//CS_SITESPECIFIC_FACTOR_15   "CS Site Specific Factor 15"
//CS_SITESPECIFIC_FACTOR_16   "CS Site Specific Factor 16"
//CS_SITESPECIFIC_FACTOR_17   "CS Site Specific Factor 17"
//CS_SITESPECIFIC_FACTOR_18   "CS Site Specific Factor 18"
//CS_SITESPECIFIC_FACTOR_19   "CS Site Specific Factor 19"
//CS_SITESPECIFIC_FACTOR_20   "CS Site Specific Factor 20"
//CS_SITESPECIFIC_FACTOR_21   "CS Site Specific Factor 21"
//CS_SITESPECIFIC_FACTOR_22   "CS Site Specific Factor 22"
//CS_SITESPECIFIC_FACTOR_23   "CS Site Specific Factor 23"
//CS_SITESPECIFIC_FACTOR_24   "CS Site Specific Factor 24"
//CS_SITESPECIFIC_FACTOR_25   "CS Site Specific Factor 25"

*CS_VERSION_LATEST           "CS Version Number"
*DX_RX_STARTED_DAYS          "Treatment Started, Days from Diagnosis"
*DX_SURG_STARTED_DAYS        "First Surgical Procedure, Days from Dx"
*DX_DEFSURG_STARTED_DAYS     "Definitive Surgical Procedure, Days from Dx"

replace RX_SUMM_SURG_PRIM_SITE = . if RX_SUMM_SURG_PRIM_SITE == 99

//RX_HOSP_SURG_APPR_2010      "Surgical Approach at this Facility 2010 and Later"

replace RX_SUMM_SURGICAL_MARGINS = . if RX_SUMM_SURGICAL_MARGINS == 9 

replace RX_SUMM_SCOPE_REG_LN_SUR = . if RX_SUMM_SCOPE_REG_LN_SUR == 9

replace RX_SUMM_SURG_OTH_REGDIS = . if RX_SUMM_SURG_OTH_REGDIS == 9

*SURG_DISCHARGE_DAYS         "Surgical Inpatient Stay, Days from Surgery"

replace READM_HOSP_30_DAYS = . if READM_HOSP_30_DAYS == 9

replace REASON_FOR_NO_SURGERY = . if REASON_FOR_NO_SURGERY == 8 | REASON_FOR_NO_SURGERY == 9

*DX_RAD_STARTED_DAYS		  "Radiation, Days for Dx"

replace RX_SUMM_RADIATION = . if RX_SUMM_RADIATION == 9

replace RAD_LOCATION_OF_RX = . if RAD_LOCATION_OF_RX == 9

replace RAD_TREAT_VOL = . if RAD_TREAT_VOL == 99

replace RAD_REGIONAL_RX_MODALITY = . if RAD_REGIONAL_RX_MODALITY == 98 | RAD_REGIONAL_RX_MODALITY == 99

replace RAD_REGIONAL_DOSE_CGY = . if RAD_REGIONAL_DOSE_CGY == 99999

replace RAD_BOOST_RX_MODALITY = . if RAD_BOOST_RX_MODALITY == 98 | RAD_BOOST_RX_MODALITY == 99

replace RAD_BOOST_DOSE_CGY = . if RAD_BOOST_DOSE_CGY == 99999

replace RAD_NUM_TREAT_VOL = . if RAD_NUM_TREAT_VOL == 999

replace RX_SUMM_SURGRAD_SEQ = . if RX_SUMM_SURGRAD_SEQ == 9

replace RAD_ELAPSED_RX_DAYS = . if RAD_ELAPSED_RX_DAYS == 999

replace REASON_FOR_NO_RADIATION = . if REASON_FOR_NO_RADIATION == 8 | REASON_FOR_NO_RADIATION == 9

*DX_SYSTEMIC_STARTED_DAYS    "Systemic, Days from Dx"
*DX_CHEMO_STARTED_DAYS       "Chemotherapy, Days from Dx"

replace RX_SUMM_CHEMO = . if RX_SUMM_CHEMO == 88 | RX_SUMM_CHEMO == 99 

*DX_HORMONE_STARTED_DAYS     "Hormone Therapy, Days from Dx"

replace RX_SUMM_HORMONE = . if RX_SUMM_HORMONE == 88 | RX_SUMM_HORMONE == 99

*DX_IMMUNO_STARTED_DAYS      "Immunotherapy, Days from Dx"

replace RX_SUMM_IMMUNOTHERAPY = . if RX_SUMM_IMMUNOTHERAPY == 88 | RX_SUMM_IMMUNOTHERAPY == 99

replace RX_SUMM_TRNSPLNT_ENDO = . if RX_SUMM_TRNSPLNT_ENDO == 88 | RX_SUMM_TRNSPLNT_ENDO == 99

replace RX_SUMM_SYSTEMIC_SUR_SEQ = . if RX_SUMM_SYSTEMIC_SUR_SEQ == 9

*DX_OTHER_STARTED_DAYS       "Other Treatment, Days from Dx"

replace RX_SUMM_OTHER = . if RX_SUMM_OTHER == 8 | RX_SUMM_OTHER == 9

replace PALLIATIVE_CARE = . if PALLIATIVE_CARE == 9

//RX_SUMM_TREATMENT_STATUS	"Received Treatment or Active Surveillance"

replace PUF_30_DAY_MORT_CD = . if PUF_30_DAY_MORT_CD == 9

replace PUF_90_DAY_MORT_CD = . if PUF_90_DAY_MORT_CD == 9

*DX_LASTCONTACT_DEATH_MONTHS "Last Contact or Death, Months from Dx"
*PUF_VITAL_STATUS            "Vital Status"

replace RX_HOSP_SURG_PRIM_SITE = . if RX_HOSP_SURG_PRIM_SITE == 99

replace RX_HOSP_CHEMO = . if RX_HOSP_CHEMO == 99

replace RX_HOSP_IMMUNOTHERAPY = . if RX_HOSP_IMMUNOTHERAPY == 99

replace RX_HOSP_HORMONE = . if RX_HOSP_HORMONE == 99

replace RX_HOSP_OTHER = . if RX_HOSP_OTHER == 8 | RX_HOSP_OTHER == 9

*PUF_MULT_SOURCE			  "Patient Treated in > 1 CoC Facility"
*REFERENCE_DATE_FLAG	  	  "Reference Date Flag"
//RX_SUMM_SCOPE_REG_LN_2012	  "Regional Lymph Node Surgery at any CoC Facility"

replace RX_HOSP_DXSTG_PROC = . if RX_HOSP_DXSTG_PROC == 7 | RX_HOSP_DXSTG_PROC == 9

replace PALLIATIVE_CARE_HOSP = . if PALLIATIVE_CARE_HOSP == 7 | PALLIATIVE_CARE_HOSP == 9

//TUMOR_SIZE_SUMMARY		  "Tumor Size, >=2016 Dx"
//METS_AT_DX_OTHER			  "Metastatic Involvement, Other Bone, Brain, Liver, Lung or Distant Lymph Nodes, >=2016"
//METS_AT_DX_DISTANT_LN 	  "Distant Lymph Node Involvement, >= 2016"
//METS_AT_DX_BONE             "Metastatic Bone Involvement, >= 2016"
//METS_AT_DX_BRAIN            "Metastatic Brain Involvement, >= 2016"
//METS_AT_DX_LIVER            "Metastatic Liver Involvement, >= 2016"
//METS_AT_DX_LUNG             "Metastatic Lung Involvement, >= 2016"

*NO_HSD_QUAR_16              "Percent No High School Degree Quartiles 2012-2016"
*MED_INC_QUAR_16             "Median Income Quartiles 2012-2016"
*MEDICAID_EXPN_CODE          "Patient State at Diagnosis Grouped by Medicaid Expansion Status 2010-2016"

save "lungNSC_replace.dta", replace
