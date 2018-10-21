
LIBNAME PROJECT 'C:\Users\Desktop\Course\Survival in SAS\project';

PROC IMPORT OUT= PROJECT.FERM2 FILE = 'C:\Users\arkak\Desktop\Course\Survival in SAS\project\FermaLogis_Event_Type.csv'
     DBMS=CSV  REPLACE;  
RUN;

DATA FERM;
SET PROJECT.FERM2;
RUN;

PROC CONTENTS DATA = FERM;
RUN;
/* Dropping the variables not required and correcting values of Turnover*/

DATA PROJECT.FERM (DROP = EmployeeCount EmployeeNumber Over18 StandardHours);  
	SET FERM ;
	IF Turnover='Yes' AND Type=0 THEN Turnover='No';
	IF type = 0 then DO;
		event = 0;
		Description = 'Still in';
	END;
	ELSE DO;
		event = 1;
		IF type = 1 THEN Description = 'LeftforType1';
		IF type = 2 THEN Description  = 'LeftforType2';
		IF type = 3 THEN Description  = 'LeftforType3'; 
		IF type = 4 THEN Description  = 'LeftforType4'; 
	END;

RUN;

/* Changing variable values to numbers and adding the Employee_status column*/

DATA PROJECT.FERM ;
SET PROJECT.FERM ;

IF DEPARTMENT ='Sales' then Department_n=0;
ELSE IF DEPARTMENT ='Research & Development' THEN Department_n=1;
ELSE IF DEPARTMENT ='Human Resources' THEN Department_n=2;

IF BusinessTravel='Non-Travel' THEN BusinessTravel_n=0;
ELSE  IF BusinessTravel='Travel_Rarely' THEN BusinessTravel_n=1;
ELSE IF BusinessTravel='Travel_Frequently' THEN BusinessTravel_n=2;

IF EducationField='Human Resources' THEN EducationField_n =0;
ELSE IF EducationField='Medical' THEN EducationField_n =1;
ELSE IF EducationField='Technical Degree' THEN EducationField_n =2;
ELSE IF EducationField='Life Sciences' THEN EducationField_n =3;
ELSE IF EducationField='Marketing' THEN EducationField_n =4;
ELSE IF EducationField='Other' THEN EducationField_n =5;

IF Gender='Female' THEN Gender_n =0;
ELSE Gender_n=1;

IF JOBROLE='Healthcare Representative' THEN JobRole_n=0;
ELSE IF JOBROLE='Laboratory Technician' THEN JobRole_n=1;
ELSE IF JOBROLE='Manager' THEN JobRole_n=2;
ELSE IF JOBROLE='Manufacturing Director' THEN JobRole_n=3;
ELSE IF JOBROLE='Research Director' THEN JobRole_n=4;
ELSE IF JOBROLE='Research Scientist' THEN JobRole_n=5;
ELSE IF JOBROLE='Sales Executive' THEN JobRole_n=6;
ELSE IF JOBROLE='Sales Representative' THEN JobRole_n=7;

IF MaritalStatus='Single' THEN MaritalStatus_n=0;
ELSE MaritalStatus_n=1;

IF Over18='Y' THEN Over18_n=0;
ELSE Over18_n=1;

IF OverTime='Yes' THEN OverTime_n=0;
ELSE OverTime_n=1;

IF TurnOver='Yes' Then Turnover_n=1;
ELSE TurnOver_n=0;

If YearsAtCompany<=3 Then Employee_Status="NEW_EMPLOYEE";
ELSE Employee_Status="OLD_EMPLOYEE";

RUN;

/*Splitting the datasets into new employees and old employees*/

DATA PROJECT.NEW_EMP PROJECT.OLD_EMP;
SET PROJECT.FERM;
IF Employee_Status="NEW_EMPLOYEE" THEN OUTPUT PROJECT.NEW_EMP;
ELSE OUTPUT PROJECT.OLD_EMP;
RUN;


/*When is the biggest danger for employees to leave?*/

PROC LIFETEST DATA= PROJECT.NEW_EMP METHOD=LIFE INTERVALS = 0 1 2 3 4 PLOTS=(S,H);  
  TIME YearsAtCompany*event(0);
TITLE 'LIFETEST FOR NEW EMPLOYEES';
RUN;

PROC LIFETEST DATA= PROJECT.OLD_EMP METHOD=LIFE INTERVALS = 4 10 15 20 25 30 35 40 PLOTS=(S,H);  
  TIME YearsAtCompany*event(0);
TITLE 'LIFETEST FOR OLD EMPLOYEES';
RUN;

/* Analyzing attrition by different variables*/

PROC LIFETEST DATA= PROJECT.NEW_EMP METHOD=LIFE INTERVALS = 0 1 2 3 4 PLOTS=(S);  
  TIME YearsAtCompany*event(0);
  STRATA Gender_n;
TITLE 'LIFETEST FOR NEW EMPLOYEES BY GENDER';
RUN;


PROC LIFETEST DATA= PROJECT.OLD_EMP METHOD=LIFE INTERVALS = 4 10 15 20 25 30 35 40 PLOTS=(S);  
  TIME YearsAtCompany*event(0);
  STRATA Gender_n;
TITLE 'LIFETEST FOR OLD EMPLOYEES BY GENDER';
RUN;


PROC LIFETEST DATA= PROJECT.NEW_EMP METHOD=LIFE INTERVALS = 0 1 2 3 4 PLOTS=(S);  
  TIME YearsAtCompany*event(0);
  STRATA BusinessTravel_n;
TITLE 'LIFETEST FOR NEW EMPLOYEES BY BusinessTravel';
RUN;


PROC LIFETEST DATA= PROJECT.OLD_EMP METHOD=LIFE INTERVALS = 4 10 15 20 25 30 35 40 PLOTS=(S);  
  TIME YearsAtCompany*event(0);
  STRATA BusinessTravel_n;
TITLE 'LIFETEST FOR OLD EMPLOYEES BY BusinessTravel';
RUN;

PROC LIFETEST DATA= PROJECT.NEW_EMP METHOD=LIFE INTERVALS = 0 1 2 3 4 PLOTS=(S);  
  TIME YearsAtCompany*event(0);
  STRATA Department_n;
TITLE 'LIFETEST FOR NEW EMPLOYEES BY Department';
RUN;


PROC LIFETEST DATA= PROJECT.OLD_EMP METHOD=LIFE INTERVALS = 4 10 15 20 25 30 35 40 PLOTS=(S);  
  TIME YearsAtCompany*event(0);
  STRATA Department_n;
TITLE 'LIFETEST FOR OLD EMPLOYEES BY Department';
RUN;
/*Modeling paramteric regressions*/

/* Models for New Employees*/

/*Exponential Model*/
PROC LIFEREG DATA=PROJECT.NEW_EMP;
  
MODEL YearsAtCompany*event(0) = Age BusinessTravel_n DailyRate	Department_n	DistanceFromHome	Education	EducationField_n	EnvironmentSatisfaction	
Gender_n	HourlyRate	JobInvolvement	JobLevel	JobRole_n	JobSatisfaction	MaritalStatus_n	MonthlyIncome	MonthlyRate	
NumCompaniesWorked	OverTime_n	PercentSalaryHike	PerformanceRating	RelationshipSatisfaction
StockOptionLevel	TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance YearsInCurrentRole	YearsSinceLastPromotion	YearsWithCurrManager
/distribution=exponential;PROBPLOT;
RUN;

/*Exponential Model with cutoff of p value as 0.05*/

PROC LIFEREG DATA=PROJECT.NEW_EMP;
  
MODEL YearsAtCompany*event(0) = Age BusinessTravel_n EnvironmentSatisfaction	JobSatisfaction	
	OverTime_n	 YearsInCurrentRole	YearsWithCurrManager  
/distribution=exponential;PROBPLOT;
RUN;

/*Weibull Model*/

PROC LIFEREG DATA=PROJECT.NEW_EMP;
  
MODEL YearsAtCompany*event(0) = Age BusinessTravel_n DailyRate	Department_n	DistanceFromHome	Education	EducationField_n	EnvironmentSatisfaction	
Gender_n	HourlyRate	JobInvolvement	JobLevel	JobRole_n	JobSatisfaction	MaritalStatus_n	MonthlyIncome	MonthlyRate	
NumCompaniesWorked	OverTime_n	PercentSalaryHike	PerformanceRating	RelationshipSatisfaction
StockOptionLevel	TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance YearsInCurrentRole	YearsSinceLastPromotion	YearsWithCurrManager
/distribution=weibull;PROBPLOT;
RUN;

/*Weibull Model with cutoff of p value as 0.05*/
PROC LIFEREG DATA=PROJECT.NEW_EMP;
  
MODEL YearsAtCompany*event(0) =  BusinessTravel_n DistanceFromHome	EnvironmentSatisfaction	
JobSatisfaction	MaritalStatus_n		MonthlyRate	NumCompaniesWorked	OverTime_n	
	TotalWorkingYears	YearsInCurrentRole	YearsWithCurrManager
/distribution=weibull;PROBPLOT;
RUN;

/*Lognormal Model*/

PROC LIFEREG DATA=PROJECT.NEW_EMP ;
  
MODEL YearsAtCompany*event(0) = Age BusinessTravel_n DailyRate	Department_n	DistanceFromHome	Education	EducationField_n	EnvironmentSatisfaction	
Gender_n	HourlyRate	JobInvolvement	JobLevel	JobRole_n	JobSatisfaction	MaritalStatus_n	MonthlyIncome	MonthlyRate	
NumCompaniesWorked	OverTime_n	PercentSalaryHike	PerformanceRating	RelationshipSatisfaction
StockOptionLevel	TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance YearsInCurrentRole	YearsSinceLastPromotion	YearsWithCurrManager
/distribution=lognormal  ;PROBPLOT ;
RUN;


/*Lognormal  Model with cutoff of p value as 0.05*/
PROC LIFEREG DATA=PROJECT.NEW_EMP ; 
  
MODEL YearsAtCompany*event(0) =  BusinessTravel_n DistanceFromHome	EnvironmentSatisfaction	JobSatisfaction	MaritalStatus_n	
NumCompaniesWorked	OverTime_n	TotalWorkingYears	WorkLifeBalance YearsInCurrentRole	YearsWithCurrManager
/distribution=lognormal;PROBPLOT ;
RUN;


DATA CompareModels; 
	L_exponential = -205.935;
	L_weibull = -78.133;
	L_lognormal = -73.896 ;
	
	LRTLE = -2*(L_lognormal - L_exponential);
	LRTEW = -2*(L_exponential - L_weibull);
	LRTLW = -2*(L_lognormal - L_weibull);

	p_valueLE = 1 - probchi(LRTLE,2);
	p_valueEW = 1 - probchi(LRTEW,1);
	p_valueLW = 1 - probchi(LRTLW,1);
RUN;


PROC PRINT DATA=CompareModels;
	FORMAT p_valueLE p_valueEW p_valueLW 6.2;
	TITLE 'PARAMETRIC MODEL COMPARISON NEW EMPL';
RUN;
/*Lognormal model is chosen for young employees*/

PROC LIFEREG DATA=PROJECT.NEW_EMP ;
  CLASS  BusinessTravel_n Department_n 	EducationField_n EnvironmentSatisfaction Gender_n
	JobSatisfaction 	RelationshipSatisfaction WorkLifeBalance;
MODEL YearsAtCompany*event(0) = Age BusinessTravel_n DailyRate	Department_n	DistanceFromHome	Education	EducationField_n	EnvironmentSatisfaction	
Gender_n	HourlyRate	JobInvolvement	JobLevel	JobRole_n	JobSatisfaction	MaritalStatus_n	MonthlyIncome	MonthlyRate	
NumCompaniesWorked	OverTime_n	PercentSalaryHike	PerformanceRating	RelationshipSatisfaction
StockOptionLevel	TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance YearsInCurrentRole	YearsSinceLastPromotion	YearsWithCurrManager
/distribution=lognormal  ;PROBPLOT ;
RUN;

/* Models for Old Employees*/

/*Exponential Model*/
PROC LIFEREG DATA=PROJECT.OLD_EMP;
  
MODEL YearsAtCompany*event(0) = Age BusinessTravel_n DailyRate	Department_n	DistanceFromHome	Education	EducationField_n	EnvironmentSatisfaction	
Gender_n	HourlyRate	JobInvolvement	JobLevel	JobRole_n	JobSatisfaction	MaritalStatus_n	MonthlyIncome	MonthlyRate	
NumCompaniesWorked	OverTime_n	PercentSalaryHike	PerformanceRating	RelationshipSatisfaction
StockOptionLevel	TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance YearsInCurrentRole	YearsSinceLastPromotion	YearsWithCurrManager
/distribution=exponential;PROBPLOT;
RUN;


PROC LIFEREG DATA=PROJECT.OLD_EMP;
  
MODEL YearsAtCompany*event(0) = Age BusinessTravel_n Department_n	DistanceFromHome EnvironmentSatisfaction	
JobInvolvement	MaritalStatus_n	NumCompaniesWorked	OverTime_n	TrainingTimesLastYear YearsInCurrentRole	YearsSinceLastPromotion
/distribution=exponential;PROBPLOT;
RUN;

/*Weibull Model*/
PROC LIFEREG DATA=PROJECT.OLD_EMP;
  
MODEL YearsAtCompany*event(0) = Age BusinessTravel_n DailyRate	Department_n	DistanceFromHome	Education	EducationField_n	EnvironmentSatisfaction	
Gender_n	HourlyRate	JobInvolvement	JobLevel	JobRole_n	JobSatisfaction	MaritalStatus_n	MonthlyIncome	MonthlyRate	
NumCompaniesWorked	OverTime_n	PercentSalaryHike	PerformanceRating	RelationshipSatisfaction
StockOptionLevel	TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance YearsInCurrentRole	YearsSinceLastPromotion	YearsWithCurrManager
/distribution=weibull;PROBPLOT;
RUN;


PROC LIFEREG DATA=PROJECT.OLD_EMP;
  
MODEL YearsAtCompany*event(0) = BusinessTravel_n Department_n	DistanceFromHome EnvironmentSatisfaction	
JobInvolvement	JobLevel	MaritalStatus_n 
NumCompaniesWorked	OverTime_n	TotalWorkingYears	TrainingTimesLastYear YearsInCurrentRole	YearsWithCurrManager
/distribution=weibull;PROBPLOT;
RUN;


/*Lognormal Model*/

PROC LIFEREG DATA=PROJECT.OLD_EMP;
  
MODEL YearsAtCompany*event(0) = Age BusinessTravel_n DailyRate	Department_n	DistanceFromHome	Education	EducationField_n	EnvironmentSatisfaction	
Gender_n	HourlyRate	JobInvolvement	JobLevel	JobRole_n	JobSatisfaction	MaritalStatus_n	MonthlyIncome	MonthlyRate	
NumCompaniesWorked	OverTime_n	PercentSalaryHike	PerformanceRating	RelationshipSatisfaction
StockOptionLevel	TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance YearsInCurrentRole	YearsSinceLastPromotion	YearsWithCurrManager
/distribution=lognormal;PROBPLOT;
RUN;

PROC LIFEREG DATA=PROJECT.OLD_EMP;
  
MODEL YearsAtCompany*event(0) = Age BusinessTravel_n 	Department_n EnvironmentSatisfaction	
JobInvolvement	JobLevel	JobSatisfaction	MaritalStatus_n		
NumCompaniesWorked	OverTime_n	TotalWorkingYears	TrainingTimesLastYear YearsInCurrentRole		YearsWithCurrManager
/distribution=lognormal;PROBPLOT;

DATA CompareModels_old; 
	L_exponential = -314.640;
	L_weibull = -176.786;
	L_lognormal = -174.004 ;
	
	LRTLE = -2*(L_lognormal - L_exponential);
	LRTEW = -2*(L_exponential - L_weibull);
	LRTLW = -2*(L_lognormal - L_weibull);

	p_valueLE = 1 - probchi(LRTLE,2);
	p_valueEW = 1 - probchi(LRTEW,2);
	p_valueLW = 1 - probchi(LRTLW,1);
RUN;


PROC PRINT DATA=CompareModels_old;
	FORMAT p_valueLE p_valueEW p_valueLW 6.2;
	TITLE 'PARAMETRIC MODEL COMPARISON FOR OLD EMPLOYEES';
RUN;

/*Lognormal model is chosen for old employees*/

PROC LIFEREG DATA=PROJECT.OLD_EMP;
  CLASS  BusinessTravel_n Department_n 	EducationField_n EnvironmentSatisfaction Gender_n
	JobSatisfaction 	RelationshipSatisfaction WorkLifeBalance;
MODEL YearsAtCompany*event(0) = Age BusinessTravel_n DailyRate	Department_n	DistanceFromHome	Education	EducationField_n	EnvironmentSatisfaction	
Gender_n	HourlyRate	JobInvolvement	JobLevel	JobRole_n	JobSatisfaction	MaritalStatus_n	MonthlyIncome	MonthlyRate	
NumCompaniesWorked	OverTime_n	PercentSalaryHike	PerformanceRating	RelationshipSatisfaction
StockOptionLevel	TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance YearsInCurrentRole	YearsSinceLastPromotion	YearsWithCurrManager
/distribution=lognormal;PROBPLOT;
RUN;



/* Can different events be combined or not*/

DATA PROJECT.TYPE1_DATA;
SET PROJECT.FERM;
EVENT = (Type=1);
EVENT_n='Event Type 1';

DATA PROJECT.TYPE2_DATA;
SET PROJECT.FERM;
EVENT = (Type=2);
EVENT_n='Event Type 2';
DATA PROJECT.TYPE3_DATA;
SET PROJECT.FERM;
EVENT = (Type=3);
EVENT_n='Event Type 3';
DATA PROJECT.TYPE4_DATA;
SET PROJECT.FERM;
EVENT = (Type=4);
EVENT_n='Event Type 4';
RUN;
DATA PROJECT.COMBINED_EVENTS;
SET PROJECT.TYPE1_DATA  PROJECT.TYPE2_DATA PROJECT.TYPE3_DATA PROJECT.TYPE4_DATA;
RUN;

PROC LIFETEST DATA =PROJECT.COMBINED_EVENTS PLOTS=LLS;
TIME YearsAtCompany*Event(0);
Strata EVENT_n/diff=all;
RUN;
/* Check if each coefficients for each event type is equal for unseparated model*/

PROC PHREG DATA = PROJECT.FERM;
  MODEL YearsAtCompany*type(0)=  Age BusinessTravel_n DailyRate	Department_n	DistanceFromHome	Education	EducationField_n	EnvironmentSatisfaction	
Gender_n	HourlyRate	JobInvolvement	JobLevel	JobRole_n	JobSatisfaction	MaritalStatus_n	MonthlyIncome	MonthlyRate	
NumCompaniesWorked	OverTime_n	PercentSalaryHike	PerformanceRating	RelationshipSatisfaction
StockOptionLevel	TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance YearsInCurrentRole	YearsSinceLastPromotion	YearsWithCurrManager
/TIES=EFRON;


PROC PHREG DATA = PROJECT.FERM;
  MODEL YearsAtCompany*type(0,1,2,3)=  Age BusinessTravel_n DailyRate	Department_n	DistanceFromHome	Education	EducationField_n	EnvironmentSatisfaction	
Gender_n	HourlyRate	JobInvolvement	JobLevel	JobRole_n	JobSatisfaction	MaritalStatus_n	MonthlyIncome	MonthlyRate	
NumCompaniesWorked	OverTime_n	PercentSalaryHike	PerformanceRating	RelationshipSatisfaction
StockOptionLevel	TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance YearsInCurrentRole	YearsSinceLastPromotion	YearsWithCurrManager;


PROC PHREG DATA = PROJECT.FERM;
  MODEL YearsAtCompany*type(0,1,3,4)=  Age BusinessTravel_n DailyRate	Department_n	DistanceFromHome	Education	EducationField_n	EnvironmentSatisfaction	
Gender_n	HourlyRate	JobInvolvement	JobLevel	JobRole_n	JobSatisfaction	MaritalStatus_n	MonthlyIncome	MonthlyRate	
NumCompaniesWorked	OverTime_n	PercentSalaryHike	PerformanceRating	RelationshipSatisfaction
StockOptionLevel	TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance YearsInCurrentRole	YearsSinceLastPromotion	YearsWithCurrManager;


PROC PHREG DATA = PROJECT.FERM;
  MODEL YearsAtCompany*type(0,1,2,4)=  Age BusinessTravel_n DailyRate	Department_n	DistanceFromHome	Education	EducationField_n	EnvironmentSatisfaction	
Gender_n	HourlyRate	JobInvolvement	JobLevel	JobRole_n	JobSatisfaction	MaritalStatus_n	MonthlyIncome	MonthlyRate	
NumCompaniesWorked	OverTime_n	PercentSalaryHike	PerformanceRating	RelationshipSatisfaction
StockOptionLevel	TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance YearsInCurrentRole	YearsSinceLastPromotion	YearsWithCurrManager;


PROC PHREG DATA = PROJECT.FERM;
  MODEL YearsAtCompany*type(0,2,3,4)=  Age BusinessTravel_n DailyRate	Department_n	DistanceFromHome	Education	EducationField_n	EnvironmentSatisfaction	
Gender_n	HourlyRate	JobInvolvement	JobLevel	JobRole_n	JobSatisfaction	MaritalStatus_n	MonthlyIncome	MonthlyRate	
NumCompaniesWorked	OverTime_n	PercentSalaryHike	PerformanceRating	RelationshipSatisfaction
StockOptionLevel	TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance YearsInCurrentRole	YearsSinceLastPromotion	YearsWithCurrManager;
RUN;



DATA LogRatioTest_ConstandNonConst;
	Nested = 1795.505;
	Type4 = 245.948;
	Type2 = 711.138;
    Type1 = 115.308;
	Type3 = 450.984;
	
	Total =Type1+Type2+Type3+Type4;
	Diff = Nested - Total;

	P_value = 1 - probchi(Diff,87); 
RUN;

PROC PRINT DATA = LogRatioTest_ConstandNonConst;
	FORMAT P_Value 5.3;
	TITLE 'Comparison of PHREG models by Type';
RUN;
/*Can we combine different event types together? Or use them separately*/


PROC PHREG DATA = PROJECT.FERM;
  MODEL YearsAtCompany*type(0,1,2)=  Age BusinessTravel_n DailyRate	Department_n	DistanceFromHome	Education	EducationField_n	EnvironmentSatisfaction	
Gender_n	HourlyRate	JobInvolvement	JobLevel	JobRole_n	JobSatisfaction	MaritalStatus_n	MonthlyIncome	MonthlyRate	
NumCompaniesWorked	OverTime_n	PercentSalaryHike	PerformanceRating	RelationshipSatisfaction
StockOptionLevel	TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance YearsInCurrentRole	YearsSinceLastPromotion	YearsWithCurrManager;


PROC PHREG DATA = PROJECT.FERM;
  MODEL YearsAtCompany*type(0,1,2,4)=  Age BusinessTravel_n DailyRate	Department_n	DistanceFromHome	Education	EducationField_n	EnvironmentSatisfaction	
Gender_n	HourlyRate	JobInvolvement	JobLevel	JobRole_n	JobSatisfaction	MaritalStatus_n	MonthlyIncome	MonthlyRate	
NumCompaniesWorked	OverTime_n	PercentSalaryHike	PerformanceRating	RelationshipSatisfaction
StockOptionLevel	TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance YearsInCurrentRole	YearsSinceLastPromotion	YearsWithCurrManager;


PROC PHREG DATA = PROJECT.FERM;
  MODEL YearsAtCompany*type(0,1,2,3)=  Age BusinessTravel_n DailyRate	Department_n	DistanceFromHome	Education	EducationField_n	EnvironmentSatisfaction	
Gender_n	HourlyRate	JobInvolvement	JobLevel	JobRole_n	JobSatisfaction	MaritalStatus_n	MonthlyIncome	MonthlyRate	
NumCompaniesWorked	OverTime_n	PercentSalaryHike	PerformanceRating	RelationshipSatisfaction
StockOptionLevel	TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance YearsInCurrentRole	YearsSinceLastPromotion	YearsWithCurrManager;
RUN;



DATA LogRatioTest_Subtypes;
	Nested = 740.861;
	first = 450.984;
	second = 245.948;

	Total =first+second;
	Diff = Nested - Total;

	P_value = 1 - probchi(Diff,58); 
RUN;

PROC PRINT DATA = LogRatioTest_Subtypes;
	FORMAT P_Value 5.3;
	TITLE 'Comparison of PHREG type models 3 and 4';
RUN;

PROC PHREG DATA = PROJECT.FERM;
  MODEL YearsAtCompany*type(0,2,3)=  Age BusinessTravel_n DailyRate	Department_n	DistanceFromHome	Education	EducationField_n	EnvironmentSatisfaction	
Gender_n	HourlyRate	JobInvolvement	JobLevel	JobRole_n	JobSatisfaction	MaritalStatus_n	MonthlyIncome	MonthlyRate	
NumCompaniesWorked	OverTime_n	PercentSalaryHike	PerformanceRating	RelationshipSatisfaction
StockOptionLevel	TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance YearsInCurrentRole	YearsSinceLastPromotion	YearsWithCurrManager;


PROC PHREG DATA = PROJECT.FERM;
  MODEL YearsAtCompany*type(0,2,3,1)=  Age BusinessTravel_n DailyRate	Department_n	DistanceFromHome	Education	EducationField_n	EnvironmentSatisfaction	
Gender_n	HourlyRate	JobInvolvement	JobLevel	JobRole_n	JobSatisfaction	MaritalStatus_n	MonthlyIncome	MonthlyRate	
NumCompaniesWorked	OverTime_n	PercentSalaryHike	PerformanceRating	RelationshipSatisfaction
StockOptionLevel	TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance YearsInCurrentRole	YearsSinceLastPromotion	YearsWithCurrManager;


PROC PHREG DATA = PROJECT.FERM;
  MODEL YearsAtCompany*type(0,2,3,4)=  Age BusinessTravel_n DailyRate	Department_n	DistanceFromHome	Education	EducationField_n	EnvironmentSatisfaction	
Gender_n	HourlyRate	JobInvolvement	JobLevel	JobRole_n	JobSatisfaction	MaritalStatus_n	MonthlyIncome	MonthlyRate	
NumCompaniesWorked	OverTime_n	PercentSalaryHike	PerformanceRating	RelationshipSatisfaction
StockOptionLevel	TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance YearsInCurrentRole	YearsSinceLastPromotion	YearsWithCurrManager;
RUN;



DATA LogRatioTest_Subtypes2;
	Nested = 479.558;
	fourth = 245.948;
	first = 115.308;

	Total =first+fourth;
	Diff = Nested - Total;

	P_value = 1 - probchi(Diff,58); 
RUN;

PROC PRINT DATA = LogRatioTest_Subtypes2;
	FORMAT P_Value 5.3;
	TITLE 'Comparison of PHREG type models 1 and 4';
RUN;

/*Merging type 3 and type 4*/

DATA PROJECT.FERM_UPDATED;
SET PROJECT.FERM;
IF Type=4 THEN DO;
Type=3;
END;
RUN;

DATA  PROJECT.FERM_UPDATED;  
	SET  PROJECT.FERM_UPDATED;
	IF type = 0 then DO;
		event = 0;
	END;
	ELSE DO;
		event = 1;
	END;

RUN;


/*Checking for hazard*/

PROC PHREG DATA =  PROJECT.FERM;
  MODEL YearsAtCompany*event(1)=  Age BusinessTravel_n DailyRate	Department_n	DistanceFromHome	Education	EducationField_n	EnvironmentSatisfaction	
Gender_n	HourlyRate	JobInvolvement	JobLevel	JobRole_n	JobSatisfaction	MaritalStatus_n	MonthlyIncome	MonthlyRate	
NumCompaniesWorked	OverTime_n	PercentSalaryHike	PerformanceRating	RelationshipSatisfaction
StockOptionLevel	TotalWorkingYears	TrainingTimesLastYear	WorkLifeBalance YearsInCurrentRole	YearsSinceLastPromotion	YearsWithCurrManager
/TIES=EFRON;
RUN;
/*Selecting the best model after variable removal*/

PROC PHREG DATA =  PROJECT.FERM;
  MODEL YearsAtCompany*event(1)=  Age DailyRate		Department_n JobRole_n
	NumCompaniesWorked	OverTime_n	PercentSalaryHike TotalWorkingYears  YearsInCurrentRole 	YearsSinceLastPromotion YearsWithCurrManager/TIES=EFRON;
RUN;


/*Does bonus affect employee turnover? If yes, how?*/
DATA PROJECT.FERM_BONUS;
SET PROJECT.FERM;
IF bonus_1= 'NA' THEN bonus_n1=.;ELSE bonus_n1=bonus_1;IF bonus_2= 'NA' THEN bonus_n2=.;ELSE bonus_n2=bonus_2;IF bonus_3= 'NA' THEN bonus_n3=.;ELSE bonus_n3=bonus_3;
IF bonus_4= 'NA' THEN bonus_n4=.;ELSE bonus_n4=bonus_4;IF bonus_5= 'NA' THEN bonus_n5=.;ELSE bonus_n5=bonus_5;IF bonus_6= 'NA' THEN bonus_n6=.;ELSE bonus_n6=bonus_6;
IF bonus_7= 'NA' THEN bonus_n7=.;ELSE bonus_n7=bonus_7;IF bonus_8= 'NA' THEN bonus_n8=.;ELSE bonus_n8=bonus_8;IF bonus_9= 'NA' THEN bonus_n9=.;ELSE bonus_n9=bonus_9;
IF bonus_10= 'NA' THEN bonus_n10=.;ELSE bonus_n10=bonus_10;IF bonus_11= 'NA' THEN bonus_n11=.;ELSE bonus_n11=bonus_11;IF bonus_12= 'NA' THEN bonus_n12=.;ELSE bonus_n12=bonus_12;
IF bonus_13= 'NA' THEN bonus_n13=.;ELSE bonus_n13=bonus_13;IF bonus_14= 'NA' THEN bonus_n14=.;ELSE bonus_n14=bonus_14;IF bonus_15= 'NA' THEN bonus_n15=.;ELSE bonus_n15=bonus_15;
IF bonus_16= 'NA' THEN bonus_n16=.;ELSE bonus_n16=bonus_16;IF bonus_17= 'NA' THEN bonus_n17=.;ELSE bonus_n17=bonus_17;IF bonus_18= 'NA' THEN bonus_n18=.;ELSE bonus_n18=bonus_18;
IF bonus_19= 'NA' THEN bonus_n19=.;ELSE bonus_n19=bonus_19;IF bonus_20= 'NA' THEN bonus_n20=.;ELSE bonus_n20=bonus_20;IF bonus_21= 'NA' THEN bonus_n21=.;ELSE bonus_n21=bonus_21;
IF bonus_22= 'NA' THEN bonus_n22=.;ELSE bonus_n22=bonus_22;IF bonus_23= 'NA' THEN bonus_n23=.;ELSE bonus_n23=bonus_23;IF bonus_24= 'NA' THEN bonus_n24=.;ELSE bonus_n24=bonus_24;
IF bonus_25= 'NA' THEN bonus_n25=.;ELSE bonus_n25=bonus_25;IF bonus_26= 'NA' THEN bonus_n26=.;ELSE bonus_n26=bonus_26;IF bonus_27= 'NA' THEN bonus_n27=.;ELSE bonus_n27=bonus_27;
IF bonus_28= 'NA' THEN bonus_n28=.;ELSE bonus_n28=bonus_28;IF bonus_29= 'NA' THEN bonus_n29=.;ELSE bonus_n29=bonus_29;IF bonus_30= 'NA' THEN bonus_n30=.;ELSE bonus_n30=bonus_30;
IF bonus_31= 'NA' THEN bonus_n31=.;ELSE bonus_n31=bonus_31;IF bonus_32= 'NA' THEN bonus_n32=.;ELSE bonus_n32=bonus_32;IF bonus_33= 'NA' THEN bonus_n33=.;ELSE bonus_n33=bonus_33;
IF bonus_34= 'NA' THEN bonus_n34=.;ELSE bonus_n34=bonus_34;IF bonus_35= 'NA' THEN bonus_n35=.;ELSE bonus_n35=bonus_35;IF bonus_36= 'NA' THEN bonus_n36=.;ELSE bonus_n36=bonus_36;
IF bonus_37= 'NA' THEN bonus_n37=.;ELSE bonus_n37=bonus_37;IF bonus_38= 'NA' THEN bonus_n38=.;ELSE bonus_n38=bonus_38;IF bonus_39= 'NA' THEN bonus_n39=.;ELSE bonus_n39=bonus_39;
IF bonus_40= 'NA' THEN bonus_n40=.;ELSE bonus_n40=bonus_40;
RUN;

DATA PROJECT.BONUS_FERM;
SET PROJECT.FERM_BONUS;
ARRAY bonus(*) bonus_n1-bonus_n39;
ARRAY bonussum(*) bonussum_1-bonussum_39;
bonussum_1=bonus_n1;
DO i=2 to 39;
bonussum(i)=(bonussum(i-1)*(i-1)+bonus(i))/i;
END;


PROC PHREG DATA =PROJECT.BONUS_FERM;
WHERE YearsAtCompany>1;
MODEL  YearsAtCompany*event(1) =Age DailyRate		Department_n JobRole_n
	NumCompaniesWorked	OverTime_n	PercentSalaryHike TotalWorkingYears  YearsInCurrentRole 	YearsSinceLastPromotion YearsWithCurrManager
total_bonus/TIES=EFRON;
ARRAY totbonus(*) bonussum_1-bonussum_39;
total_bonus=totbonus[YearsAtCompany-1];
RUN;



/*Are there any variables which affect hazards non-proportionally*/


PROC PHREG DATA =FERM_UPDATED;
MODEL  YearsAtCompany*event(1) =Age DailyRate		Department_n JobRole_n
	NumCompaniesWorked	OverTime_n	PercentSalaryHike TotalWorkingYears  YearsInCurrentRole 	YearsSinceLastPromotion YearsWithCurrManager/TIES=EFRON;
ASSESS PH/RESAMPLE;
RUN;


/*Fixing non-proportionality*/

DATA FERM_UPDATED_NON_PROP;
SET FERM_UPDATED;
AgeYearsWorked=Age*YearsAtCompany;
TotalWorkingYearsWorked= TotalWorkingYears*YearsAtCompany;
YearsInCurrentRoleWorked =	YearsInCurrentRole*YearsAtCompany;
YearsWithCurrManagerWorked =YearsWithCurrManager*YearsAtCompany;
RUN;


PROC PHREG DATA =FERM_UPDATED_NON_PROP;
MODEL  YearsAtCompany*event(1) =Age DailyRate		Department_n JobRole_n
	NumCompaniesWorked	OverTime_n	PercentSalaryHike TotalWorkingYears  YearsInCurrentRole 	YearsSinceLastPromotion YearsWithCurrManager 
AgeYearsWorked TotalWorkingYearsWorked YearsInCurrentRoleWorked YearsWithCurrManagerWorked/TIES=EFRON  ;
RUN;
/*Analyzing according to variables*/
PROC SGPLOT DATA =  PROJECT.FERM_UPDATED;
VBAR BusinessTravel_n / GROUP=event;
RUN;

PROC SGPLOT DATA =  PROJECT.FERM_UPDATED;
VBAR MaritalStatus_n/ GROUP=event;
RUN;

PROC SGPLOT DATA =  PROJECT.FERM_UPDATED;
VBAR Overtime_n/ GROUP=event;
RUN;

PROC SGPLOT DATA =  PROJECT.FERM_UPDATED;
VBAR YearsinCurrentrole/ GROUP=event;
RUN;

PROC SGPLOT DATA =  PROJECT.FERM_UPDATED;
VBAR Yearswithcurrentmanager/ GROUP=event;
RUN;
PROC SGPLOT DATA =  PROJECT.FERM_UPDATED;
VBAR Age/ GROUP=event;
RUN;
