# Aneja-Lab-Public-MissingData

Research project examining prevalence of missing data unable to be ascertained from the medical record and associated surival outcomes for cancer patients. Manuscript is currently under submission. The project uses the National Cancer Database Participant Use Files (PUF).

To reproduce our analysis:
- Process PUF files to .dta per NCDB instructions
- Run `process_missing.do` to convert all missing and unknowns to same sentinel values
- Categorize all variables of interest in an excel file. Save as column A "variable" and B "category"
- Run `analysis.do` to reproduce analysis
