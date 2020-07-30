/*Institutional Profiles Data Pull*/
/*Author: Jimmy Luong*/
/*Last Updated: July 2020 */

***********************************************************************************************;

/*Purpose of Code: Generate tables to be used in institutional profile graphs*/

/*TABLES GENERATED:*/
/*work.success_table: Contains data on success outcomes. */
/*work.credits_table: Contains data on credits target and credits delivered*/
/*work.senior_phase_table: Contains data on senior phase pupils studying vocational qualifications*/
/*work.HNC_HND_Table: Contains data on successful students achieving HNC or HND qualifications*/
/*work.gender_table: Contains data on enrolments by gender at each college.*/
/*work.BME_table: Contains data on enrolments by ethnicity at each college*/
/*work.disability_table: Contains data on enrolments by disability at each college*/
/*work.age_table: Contains data on enrolments by age group at each college*/

/* METHOD: */
/* 1. SAS DATA STEP to query POSTALL tables for 5 academic years */
/* 2. Combine tables with PROC SQL UNION */
/* 3. Run a SAS DATA step to format columns of interest. */
/* 4. Run various PROC SQL CREATE TABLE statements to produce data input tables for graphs.*/
/* 5. Export the tables to .csv files.*/

***********************************************************************************************;
DATA work.ay1415_IP; /* 1. Data steps to insert year into each table*/
SET pmaupdat.postall1415;
year = 2014;
RUN;
DATA work.ay1516_IP;
SET pmaupdat.postall1516;
year = 2015;
RUN;
DATA work.ay1617_IP;
SET pmaupdat.postall1617;
year = 2016;
RUN;
DATA work.ay1718_IP;
SET pmaupdat.postall1718;
year = 2017;
RUN;
DATA work.ay1819_IP;
SET pmaupdat.postall1819;
year = 2018;
RUN;
PROC SQL; /* 2. Combine tables with SQL UNION ALL to create WORK.ay1418_IP */
CREATE TABLE WORK.ay1418_IP AS
SELECT 
	pi_publication,
	adv, /*level of study*/
	mode, /*mode of study*/
	homex,
	agedecx,
	genderx,
	ethnic,
	sclass1,
	pi_outcome,
	distype,
	mental_health_condition,
	credits,
	year,
	college_name,
	spvp_student
FROM work.ay1415_IP
UNION ALL
SELECT 
	pi_publication,
	adv,
	mode,
	homex,
	agedecx,
	genderx,
	ethnic,
	sclass1,
	pi_outcome,
	distype,
	mental_health_condition,
	credits,
	year,
	college_name,
	spvp_student
FROM work.ay1516_IP
UNION ALL
SELECT
	pi_publication,
	adv,
	mode,
	homex,
	agedecx,
	genderx,
	ethnic,
	sclass1,
	pi_outcome,
	distype,
	mental_health_condition,
	credits,
	year,
	college_name,
	spvp_student
FROM work.ay1617_IP
UNION ALL
SELECT 
	pi_publication,
	adv,
	mode,
	homex,
	agedecx,
	genderx,
	ethnic,
	sclass1,
	pi_outcome,
	distype,
	mental_health_condition,
	credits,
	year,
	college_name,
	spvp_student
FROM work.ay1718_IP
UNION ALL
SELECT 
	pi_publication,
	adv,
	mode,
	homex,
	agedecx,
	genderx,
	ethnic,
	sclass1,
	pi_outcome,
	distype,
	mental_health_condition,
	credits,
	year,
	college_name,
	spvp_student
FROM work.ay1819_IP
;
QUIT
;
***********************************************************************************************;
DATA work.ay1418_IP_format; /* 3. Run a DATA step to format columns of interest. */
SET work.ay1418_IP;

/* DATA QUALITY: Fixing college names */
if college_name = 'SRUC Land Based' then college_name = 'SRUC';
if college_name = 'Shetland College of Further Education' then college_name = 'Shetland College';
if college_name = 'Lews castle College' then college_name = 'Lews Castle College';

/*Level of study*/
if adv = 1 then level_of_study = 'HE'; 
if adv = 2 then level_of_study = 'FE'; 

/*Mode of study*/
length mode_of_study $2.;
if MODE = 17 then mode_of_study = 'FT';
if MODE NE 17 then mode_of_study = 'PT';

/*Domicile or non-Scottish domicile*/
length domicile $25.;
domicile = 'Non-Scottish';
if homex >= 100 and homex <= 410 then domicile = 'Scottish'; *Scottish domiciled students only;

/*Age group*/
length agegroup $20.; 
agegroup = 'Unknown' ;
if agedecx < 16 then agegroup = 'under 16'; 
if agedecx >= 16 and agedecx <= 19 then agegroup = '16 to 19'; 
if agedecx >= 20 and agedecx <= 24 then agegroup = '20 to 24'; 
if agedecx >= 25 and agedecx <= 40 then agegroup = '25 to 40';
else if agedecx >= 40 then agegroup = '40 and over'; 

/*Gender*/
length gender $6.;
if genderx= '10' then gender = 'Male'; 
if genderx = '11' then gender = 'Female'; 
if genderx IN ('12','13') then gender = 'Other';

/*Ethnicity*/
length BME $20.;
if ethnic IN (1,10,11,12,13,14,30,31,32,33) then BME = 'White';
else if ethnic in (2,3,4,5,6,7,8,9,15,16,17,18,19,20,21,22,23,24,34, 35) then  BME = 'BME';
else BME = 'Not known';

/*DECLARED DISABILITY*/
LENGTH a_distype $50.;
if distype in (2,3,4,5,6,7,8,9,10,11) then a_distype = 'Declared disability';
else if distype = 1 then a_distype = 'No known disability';
else a_distype = 'No known disability';

/*MENTAL_HEALTH_CONDITION... (Blank, Yes, No) */
LENGTH mental_health_cond $25.;
if mental_health_condition = 'Y' then mental_health_cond = 'Yes';
else mental_health_cond = 'None or unknown';

/*Mode of study*/
length mode_of_study $2.;
if MODE = 17 then mode_of_study = 'FT';
if MODE NE 17 then mode_of_study = 'PT';

/*Level of study*/
length level_of_study $2.;
if adv = 1 then level_of_study = 'HE'; 
if adv = 2 then level_of_study = 'FE'; 

/*PI_OUTCOME... Blank, Completed partial success, Completed success, Early withdrawal, further withdrawal */
/*Number success is the number of outcomes that are 'Completed success'*/
LENGTH success_outcome $30.;
if PI_OUTCOME = 'Completed success' then success_outcome = 'Successful';
else success_outcome = 'Not successful';

RUN;
***********************************************************************************************;
/* 4. Run various PROC SQL CREATE TABLE statements to produce data input tables for graphs.*/

/*8A-8D, 9A, 9C, 10B, 11A, 11B, 11C, 11D*/

/*8A - 8D: FTHE FTFE PTFE PTHE SUCCESS*/
/*Use pi_outcome here*/
/*Use if pi_publication = 'Yes';*/
PROC SQL;
CREATE TABLE work.success_table AS
SELECT	year,
		college_name,
		level_of_study,
		mode_of_study,
		SUM(CASE WHEN success_outcome = 'Successful' THEN 1 ELSE 0 END) AS number_of_successful,
		SUM(CASE WHEN success_outcome IN ('Successful','Not successful') THEN 1 ELSE 0 END) AS total_number,
		100*(SUM(CASE WHEN success_outcome = 'Successful' THEN 1 ELSE 0 END)/SUM(CASE WHEN success_outcome IN ('Successful','Not successful') THEN 1 ELSE 0 END))
			FORMAT = 6.1 AS success_percentage
FROM WORK.ay1418_IP_format
	WHERE pi_publication = 'Yes'
	GROUP BY 	year,
				college_name,
				level_of_study,
				mode_of_study
;
QUIT;

PROC EXPORT DATA = work.success_table /*Export this table*/ 
OUTFILE= "\\~\8AD_success_table.csv"
DBMS=CSV REPLACE; 
RUN;
