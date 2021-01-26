/*
Missing Data Project
Daniel Yang / Aneja Lab
Input: dta file, variable category excel file
Output: generate patient level analysis and survival figures, saves in output folder
Created 2020-10-22
Last Edited 2020-10-22
*/

cls
frames reset
display "File path for processed dta file: " _request(puf_file)
use "$puf_file"

*use all variables under consideration for sensitivity analysis
display "File path for variable list: " _request(excel_file)
frame create missing
frame missing{
	import excel "$excel_file", sheet("Sheet1") firstrow
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

frame missing{
	gen flag_interest = 1 if miss_percent >=1 & miss_percent <=20
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


*---------------survival analysis----------------------------------------------*
stset DX_LASTCONTACT_DEATH_MONTHS, failure(PUF_VITAL_STATUS==0) //there is no missing values for PUF_VITAL_STATUS
sts graph, by(missing_flag) risktable(, order(1 "Complete:   " 2 "Missing:   ")) tmax(60) xlabel(0(12)60)
sts test missing_flag, logrank
sts list, by(missing_flag) at(12 24 36 48 60)
graph save output/supplement, replace
