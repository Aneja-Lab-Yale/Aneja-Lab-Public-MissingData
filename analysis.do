/*
Missing Data Project
Daniel Yang / Aneja Lab
Input: dta file, variable_category excel file
Output: generate patient level analysis and survival figures, saves in output folder
Created 2020-10-22
Last Edited 2020-10-22
*/

cls
frames reset
display "Enter input file path: " _request(puf_file)
use Data/$puf_file

*input the Excel list of variables with their categories
frame create missing
frame missing{
	import excel "Log/variable_category.xlsx", sheet("Sheet1") firstrow
	gen miss_count = .
	gen miss_percent = .
}

foreach var of varlist _all{
	quietly: mdesc `var', ab(99)
	frame missing{
		quietly: replace miss_count = r(miss) if variable == "`var'"
		quietly: replace miss_percent = r(percent) if variable == "`var'"
	}
}

*-----flag variables of interest, which are flagged in "missing" dataframe-----*
display "What disease site are you generating figures for: " _request(site)
if "$site"=="lung" | "$site"=="breast" | "$site"=="prostate" {
	display "Continue for $site"
}
else{
	display "Invalid disease site"
	exit
}

frame missing{
	gen flag_interest = 1 if miss_count != 0
	replace flag_interest = 0 if variable == "DX_CHEMO_STARTED_DAYS" ///
		| variable == "DX_DEFSURG_STARTED_DAYS" ///
		| variable == "DX_HORMONE_STARTED_DAYS" ///
		| variable == "DX_IMMUNO_STARTED_DAYS" ///
		| variable == "DX_OTHER_STARTED_DAYS" ///
		| variable == "DX_RAD_STARTED_DAYS" ///
		| variable == "DX_RX_STARTED_DAYS" ///
		| variable == "DX_STAGING_PROC_DAYS" ///
		| variable == "DX_SURG_STARTED_DAYS" ///
		| variable == "DX_SYSTEMIC_STARTED_DAYS" ///
		| variable == "PUF_30_DAY_MORT_CD" ///
		| variable == "PUF_90_DAY_MORT_CD" ///
		| variable == "RX_SUMM_SURGICAL_MARGINS" ///
		| variable == "SURG_DISCHARGE_DAYS" ///
		| variable == "TNM_PATH_M" ///
		| variable == "TNM_PATH_N" ///
		| variable == "TNM_PATH_T" ///
		| variable == "TNM_PATH_STAGE_GROUP"
	if "$site" == "prostate"{
		replace flag_interest = 0 if variable == "TUMOR_SIZE"
	}		
}

*create flags for if any demographics, cancerspecfic, stage, or treatment variables of interest are missing
gen missing_demographics_flag = 0
gen missing_cancerid_flag = 0
gen missing_stage_flag = 0
gen missing_treatment_flag = 0

frame change missing
levelsof variable if flag_interest == 1 & (category == "Demographics"), local(vars_demographics)
frame change default
foreach var in `vars_demographics'{
	display "`var'"
	capture confirm string variable `var'
	if !_rc{
		replace missing_demographics_flag = 1 if `var' == ""
	}
	else{
		replace missing_demographics_flag = 1 if `var' == .
	}
}	

frame change missing
levelsof variable if flag_interest == 1 & category == "Cancer Identification", local(vars_cancerid)
frame change default
foreach var in `vars_cancerid'{
	display "`var'"
	capture confirm string variable `var'
	if !_rc{
		replace missing_cancerid_flag = 1 if `var' == ""
	}
	else{
		replace missing_cancerid_flag = 1 if `var' == .
	}
}

frame change missing
levelsof variable if flag_interest == 1 & category == "Stage", local(vars_stage)
frame change default
foreach var in `vars_stage'{
	display "`var'"
	capture confirm string variable `var'
	if !_rc{
		replace missing_stage_flag = 1 if `var' == ""
	}
	else{
		replace missing_stage_flag = 1 if `var' == .
	}
}

frame change missing
levelsof variable if flag_interest == 1 & category == "Treatment", local(vars_treatment)
frame change default
foreach var in `vars_treatment'{
	display "`var'"
	capture confirm string variable `var'
	if !_rc{
		replace missing_treatment_flag = 1 if `var' == ""
	}
	else{
		replace missing_treatment_flag = 1 if `var' == .
	}
}
*generate missing flags
gen missing_flag = 0
replace missing_flag = 1 if missing_demographics_flag == 1 | missing_cancerid_flag == 1 | missing_stage_flag == 1 | missing_treatment_flag == 1

tab missing_flag, m
tab missing_demographics_flag, m
tab missing_cancerid_flag, m
tab missing_stage_flag, m
tab missing_treatment_flag, m



*------------------------Recode variables for analysis-------------------------*

recode RACE (1=1) (2=2) (nonmiss=3), gen(race_recode)
	*1 = white
	*2 = black
	*3 = other
recode SPANISH_HISPANIC_ORIGIN (0=0) (nonmiss=1), gen(hispanic_recode)
	*0 = non-hispanic
	*1 = hispanic
recode FACILITY_TYPE_CD (3=1) (nonmiss=0), gen(facility_type_recode)
	*0 = community/non-academic
	*1 = academic

if "$site" == "lung"{
	recode TUMOR_SIZE (1/30 990/993 =0) (31/989 994/995 =1) (nonmiss=.), gen(tumor_size_recode)
		*0 = tumor <=3 cm
		*1 = tumor > 3 cm
		*excluded tumor_size for where no tumor was found i.e. 0
		*excluded 996-998 where tumor_size was not specified
	recode ANALYTIC_STAGE_GROUP (0 1 =1) (5 8 =.), gen(stage_recode)
		*combines stage 0 and 1 into stage 1 (for NSCLC only)
		*exclude 5 (occult only for lung) and 8 (N/A)
}
if "$site" == "breast"{
	recode TUMOR_SIZE (1/20 990/992 =0) (21/989 993/995 =1) (nonmiss=.), gen(tumor_size_recode)
		*0 = tumor <=2 cm
		*1 = tumor > 2 cm
		*excluded tumor_size for where no tumor was found i.e. 0
		*excluded 996-998 where tumor_size was not specified
	recode ANALYTIC_STAGE_GROUP (5 8 =.), gen(stage_recode)
		*exclude 5 (occult only for lung) and 8 (N/A)
}
if "$site" == "prostate"{
	recode ANALYTIC_STAGE_GROUP (0 5 8 =.), gen(stage_recode)
		*exclude stage 0, 5 (occult only for lung), and 8 (N/A)
}
label values stage_recode ANALYTIC_STAGE_GROUP

*recode nodal status using combined path_N and clin_N for cases where N stage info is available
gen n_recode = 0 if regexm(TNM_PATH_N, "^p0")
replace n_recode = 1 if regexm(TNM_PATH_N, "^p1")
replace n_recode = 1 if regexm(TNM_PATH_N, "^p2")
replace n_recode = 1 if regexm(TNM_PATH_N, "^p3")
*where pathologic N status is unavailable use clinical N status
replace n_recode = 0 if regexm(TNM_CLIN_N, "^c0") & n_recode == .
replace n_recode = 1 if regexm(TNM_CLIN_N, "^c1") & n_recode == .
replace n_recode = 1 if regexm(TNM_CLIN_N, "^c2") & n_recode == .
replace n_recode = 1 if regexm(TNM_CLIN_N, "^c3") & n_recode == .
	*0 = N0
	*1 = node positive

*recode M stage status using combined path_M and clin_M for cases where M stage info is available
*note TNM_PATH_M does not have any M0 entries
gen m_recode = 1 if regexm(TNM_PATH_M, "^p1")
*where pathologic M status is unavailable use clinical M status
replace m_recode = 0 if regexm(TNM_CLIN_M, "^c0") & m_recode == .
replace m_recode = 1 if regexm(TNM_CLIN_M, "^c1") & m_recode == .
	*0 = M0
	*1 = metastatic

recode RX_SUMM_SURG_PRIM_SITE (0=0) (10/98=1), gen(surgery_recode)
	*0 = no primary site surgery
	*1 = some kind of primary site surgery
recode RX_SUMM_RADIATION (0=0) (1/5=1), gen(radiation_recode)
	*0 = no RT
	*1 = some kind of RT
recode RX_SUMM_CHEMO (1/3=1) (nonmiss=0), gen(chemo_recode)
	*0 = no chemo
	*1 = some kind of chemo
recode RX_SUMM_HORMONE (1=1) (nonmiss=0), gen(hormone_recode)
	*0 = no hormone therapy
	*1 = hormone therapy administered as first course therapy


*---------------------pie chart of variables----------------------------------*/

frame missing{
	gen graph_order = 1 if category == "Demographics"
	replace graph_order = 2 if category == "Cancer Identification"
	replace graph_order = 3 if category == "Stage"
	replace graph_order = 4 if category == "Treatment"
	replace graph_order = 5 if category == "Outcomes"
	*all variables
	graph pie, over(category) sort(graph_order) legend(rows(1) size(vsmall)) plabel(_all sum)
	graph save output/1A_varsall, replace
	*variables with any missing
	preserve
	keep if miss_count != 0
	graph pie, over(category) sort(graph_order) legend(rows(1) size(vsmall)) plabel(_all sum)
	graph save output/1B_varsmiss, replace
	restore
	*variables of interest; outcomes variables not used for patient-level analysis
	preserve
	replace flag_interest = 0 if category == "Outcomes"
	keep if miss_count != 0 & flag_interest == 1
	graph pie, over(category) sort(graph_order) legend(rows(1) size(vsmall)) plabel(_all sum)
	graph save output/1C_varsinterest, replace
	restore	
}

*---------------survival analysis----------------------------------------------*
stset DX_LASTCONTACT_DEATH_MONTHS, failure(PUF_VITAL_STATUS==0) //there is no missing values for PUF_VITAL_STATUS
sts graph, by(missing_flag) risktable(, order(1 "Non-missing:   " 2 "Missing:   ")) tmax(60) xlabel(0(12)60)
sts test missing_flag, logrank
sts list, by(missing_flag) at(12 24 36 48 60)
graph save output/2_OS, replace


*non-metastatic (stage (0), I, II, III) vs metastatic (stage IV) survival impact
*stage 0 excluded for prostate
gen met_missing = .
if "$site" == "prostate"{
	replace met_missing = 1 if (ANALYTIC_STAGE_GROUP == 1 | ANALYTIC_STAGE_GROUP == 2 | ANALYTIC_STAGE_GROUP == 3) & missing_flag == 0
	replace met_missing = 2 if (ANALYTIC_STAGE_GROUP == 1 | ANALYTIC_STAGE_GROUP == 2 | ANALYTIC_STAGE_GROUP == 3) & missing_flag == 1
	replace met_missing = 3 if ANALYTIC_STAGE_GROUP == 4 & missing_flag == 0
	replace met_missing = 4 if ANALYTIC_STAGE_GROUP == 4 & missing_flag == 1
}
else{
	replace met_missing = 1 if (ANALYTIC_STAGE_GROUP == 0 | ANALYTIC_STAGE_GROUP == 1 | ANALYTIC_STAGE_GROUP == 2 | ANALYTIC_STAGE_GROUP == 3) & missing_flag == 0
	replace met_missing = 2 if (ANALYTIC_STAGE_GROUP == 0 | ANALYTIC_STAGE_GROUP == 1 | ANALYTIC_STAGE_GROUP == 2 | ANALYTIC_STAGE_GROUP == 3) & missing_flag == 1
	replace met_missing = 3 if ANALYTIC_STAGE_GROUP == 4 & missing_flag == 0
	replace met_missing = 4 if ANALYTIC_STAGE_GROUP == 4 & missing_flag == 1
}
	*1 = non-metastatic, non-missing
	*2 = non-metastatic, missing
	*3 = metastatic, non-missing
	*4 = metastatic, missing
sts graph, by(met_missing) risktable(, order(1 "Group 1:   " 2 "Group 2:   " 3 "Group 3:   " 4 "Group 4:   ")) tmax(60) xlabel(0(12)60)
sts test met_missing if inlist(met_missing, 1, 2)
sts test met_missing if inlist(met_missing, 3, 4)
sts list, by(met_missing) at(12 24 36 48 60)
graph save output/3_OS_met, replace


/*
SUPPLEMENTAL
*/

*survival by stage

*stage 0 (breast only)
if "$site" == "breast"{
	preserve
	keep if stage_recode == 0
	sts graph, by(missing_flag) risktable(, order(1 "Non-missing:   " 2 "Missing:   ")) tmax(60) xlabel(0(12)60)
	sts test missing_flag, logrank
	sts list, by(missing_flag) at(12 24 36 48 60)
	graph save output/s1_os_stage0, replace
	restore
}
	
*stage 1
preserve
keep if stage_recode == 1
sts graph, by(missing_flag) risktable(, order(1 "Non-missing:   " 2 "Missing:   ")) tmax(60) xlabel(0(12)60)
sts test missing_flag, logrank
sts list, by(missing_flag) at(12 24 36 48 60)
graph save output/s1_os_stage1, replace
restore

*stage 2
preserve
keep if stage_recode == 2
sts graph, by(missing_flag) risktable(, order(1 "Non-missing:   " 2 "Missing:   ")) tmax(60) xlabel(0(12)60)
sts test missing_flag, logrank
sts list, by(missing_flag) at(12 24 36 48 60)
graph save output/s1_os_stage2, replace
restore

*stage 3
preserve
keep if stage_recode == 3
sts graph, by(missing_flag) risktable(, order(1 "Non-missing:   " 2 "Missing:   ")) tmax(60) xlabel(0(12)60)
sts test missing_flag, logrank
sts list, by(missing_flag) at(12 24 36 48 60)
graph save output/s1_os_stage3, replace
restore

*stage 4
preserve
keep if stage_recode == 4
sts graph, by(missing_flag) risktable(, order(1 "Non-missing:   " 2 "Missing:   ")) tmax(60) xlabel(0(12)60)
sts test missing_flag, logrank
sts list, by(missing_flag) at(12 24 36 48 60)
graph save output/s1_os_stage4, replace
restore


*graph missingness by year of diagnosis
mean missing_flag , over(YEAR_OF_DIAGNOSIS)
gen missing_flag_reverse = 1
replace missing_flag_reverse = 0 if missing_flag == 1
graph bar, over(missing_flag_reverse) over(YEAR_OF_DIAGNOSIS) asyvars stack missing percentages
drop missing_flag_reverse
graph save output/s4_missing_year, replace


*graph change in stage by of diagnosis
preserve
drop if ANALYTIC_STAGE_GROUP == 8
if "$site"=="lung"{
	replace ANALYTIC_STAGE_GROUP = 1 if ANALYTIC_STAGE_GROUP == 0
	drop if ANALYTIC_STAGE_GROUP == 5
}
if "$site"=="prostate"{
	drop if ANALYTIC_STAGE_GROUP == 0
}
graph bar, over(ANALYTIC_STAGE_GROUP) over(YEAR_OF_DIAGNOSIS) asyvars stack missing percentages
graph save output/s5_stage_year, replace
restore

*survival impact of missing in first 5 years vs last 5 years of dx
preserve
keep if YEAR_OF_DIAGNOSIS >= 2006 & YEAR_OF_DIAGNOSIS <= 2010
sts graph, by(met_missing) risktable(, order(1 "Group 1:   " 2 "Group 2:   " 3 "Group 3:   " 4 "Group 4:   ")) tmax(60) xlabel(0(12)60)
sts test met_missing if inlist(met_missing, 1, 2)
sts test met_missing if inlist(met_missing, 3, 4)
graph save output/s6_os_2006_2010, replace
restore

preserve
keep if YEAR_OF_DIAGNOSIS >= 2011 & YEAR_OF_DIAGNOSIS <= 2015
sts graph, by(met_missing) risktable(, order(1 "Group 1:   " 2 "Group 2:   " 3 "Group 3:   " 4 "Group 4:   ")) tmax(60) xlabel(0(12)60)
sts test met_missing if inlist(met_missing, 1, 2)
sts test met_missing if inlist(met_missing, 3, 4)
graph save output/s6_os_2011_2015, replace
restore


*survival curves by treatment status
gen surg_missing = .
replace surg_missing = 1 if surgery_recode == 1 & missing_flag == 0
replace surg_missing = 2 if surgery_recode == 1 & missing_flag == 1
replace surg_missing = 3 if surgery_recode == 0 & missing_flag == 0
replace surg_missing = 4 if surgery_recode == 0 & missing_flag == 1
	*1 = surgery, non-missing
	*2 = surgery, missing
	*3 = no surgery, non-missing
	*4 = no surgery, missing
sts graph, by(surg_missing) risktable(, order(1 "Group 1:   " 2 "Group 2:   " 3 "Group 3:   " 4 "Group 4:   ")) tmax(60) xlabel(0(12)60)
sts test surg_missing if inlist(surg_missing, 1, 2)
sts test surg_missing if inlist(surg_missing, 3, 4)
graph save output/s7_os_surgery, replace

gen rt_missing = .
replace rt_missing = 1 if radiation_recode == 1 & missing_flag == 0
replace rt_missing = 2 if radiation_recode == 1 & missing_flag == 1
replace rt_missing = 3 if radiation_recode == 0 & missing_flag == 0
replace rt_missing = 4 if radiation_recode == 0 & missing_flag == 1
	*1 = radiation, non-missing
	*2 = radiation, missing
	*3 = no radiation, non-missing
	*4 = no radiation, missing
sts graph, by(rt_missing) risktable(, order(1 "Group 1:   " 2 "Group 2:   " 3 "Group 3:   " 4 "Group 4:   ")) tmax(60) xlabel(0(12)60)
sts test rt_missing if inlist(rt_missing, 1, 2)
sts test rt_missing if inlist(rt_missing, 3, 4)
graph save output/s7_os_radiation, replace

gen chemo_missing = .
replace chemo_missing = 1 if chemo_recode == 1 & missing_flag == 0
replace chemo_missing = 2 if chemo_recode == 1 & missing_flag == 1
replace chemo_missing = 3 if chemo_recode == 0 & missing_flag == 0
replace chemo_missing = 4 if chemo_recode == 0 & missing_flag == 1
	*1 = chemo, non-missing
	*2 = chemo, missing
	*3 = no chemo, non-missing
	*4 = no chemo, missing
sts graph, by(chemo_missing) risktable(, order(1 "Group 1:   " 2 "Group 2:   " 3 "Group 3:   " 4 "Group 4:   ")) tmax(60) xlabel(0(12)60)
sts test chemo_missing if inlist(chemo_missing, 1, 2)
sts test chemo_missing if inlist(chemo_missing, 3, 4)
graph save output/s7_os_chemo, replace



*generate baseline patient, tumor, and treatment characteristics table (Table 2)
preserve
*skip tumor_size_recode for prostate
if "$site" == "prostate"{
	quietly: table1_mc, by(missing_flag) vars( ///
		AGE conts %9.0f \ ///
		SEX cat %9.0f \ ///
		race_recode cat %9.2f \ ///
		hispanic_recode cat %9.2f \ ///
		CDCC_TOTAL_BEST cat %9.2f \ ///
		INSURANCE_STATUS cat %9.2f \ ///
		facility_type_recode cat %9.2f \ ///
		YEAR_OF_DIAGNOSIS conts %9.0f \ ///
		stage_recode cat %9.2f \ ///
		n_recode cat %9.2f \ ///
		m_recode cat %9.2f \ ///
		surgery_recode cat %9.2f \ ///
		radiation_recode cat %9.2f \ ///
		chemo_recode cat %9.2f \ ///
		hormone_recode cat %9.2f ///
	) onecol clear
	table1_mc_dta2docx using "output/table_baseline.docx", replace
}
else{
	quietly: table1_mc, by(missing_flag) vars( ///
		AGE conts %9.0f \ ///
		SEX cat %9.0f \ ///
		race_recode cat %9.2f \ ///
		hispanic_recode cat %9.2f \ ///
		CDCC_TOTAL_BEST cat %9.2f \ ///
		INSURANCE_STATUS cat %9.2f \ ///
		facility_type_recode cat %9.2f \ ///
		YEAR_OF_DIAGNOSIS conts %9.0f \ ///
		stage_recode cat %9.2f \ ///
		tumor_size_recode cat %9.2f \ ///
		n_recode cat %9.2f \ ///
		m_recode cat %9.2f \ ///
		surgery_recode cat %9.2f \ ///
		radiation_recode cat %9.2f \ ///
		chemo_recode cat %9.2f \ ///
		hormone_recode cat %9.2f ///
	) onecol clear
	table1_mc_dta2docx using "output/table_baseline.docx", replace
}
restore
