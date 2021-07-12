/****************************************************************************
*
* Project : BIOS 645 Course
*
* Program name : Homework 5
* 
* Author : Esther Mun 
*
* Date created : 2021-03-09
*
*
****************************************************************************/

ods rtf file = '/home/u41545557/Bios511/Output/Homework5.rtf';


/* 
  Imports the txt file into a work dataset
*/
proc import datafile = '/home/u41545557/Bios511/Data/Pima_fasting_glucose.txt'
 out = pima
 dbms = dlm 
 replace;
 getnames=yes;
 delimiter = '09'x;
run;

/* proc print data = pima; */
/* run; */


/*
First, look through univariate and bivariate descriptives. ALso, look at 
simple statistics for each variable.
*/
* Creates histogram plot with density curves for each variable to look at the distribution of data for each variable;
PROC SGPLOT DATA=pima;
	HISTOGRAM glucose;
	DENSITY   glucose /TYPE=NORMAL;
RUN;	
PROC SGPLOT DATA=pima;
	HISTOGRAM pregnancies;
	DENSITY   pregnancies /TYPE=NORMAL;
RUN;
PROC SGPLOT DATA=pima;
	HISTOGRAM dia_bp;
	DENSITY   dia_bp /TYPE=NORMAL;
RUN;	
PROC SGPLOT DATA=pima;
	HISTOGRAM skin_fold;
	DENSITY   skin_fold/TYPE=NORMAL;
RUN;	
PROC SGPLOT DATA=pima;
	HISTOGRAM bmi;
	DENSITY   bmi /TYPE=NORMAL;
RUN;	
PROC SGPLOT DATA=pima;
	HISTOGRAM age;
	DENSITY   age /TYPE=NORMAL;
RUN;

/* *; */
/* PROC SGPLOT DATA=pima; */
/* 	SCATTER X=x1 Y=y; */
/* 	REG     X=x1 Y=y; */
/* 	LOESS   X=x1 Y=y /NOMARKERS; */
/* RUN;	 */
/* PROC SGPLOT DATA=pima; */
/* 	SCATTER X=x2 Y=y; */
/* 	REG     X=x2 Y=y; */
/* 	LOESS   X=x2 Y=y /NOMARKERS;   */
/* RUN;	 */
/* 	 */
* Creates a table of simple statistics for each variable;	
PROC MEANS DATA=pima N MIN MEDIAN MAX MEAN STD SKEW KURT MAXDEC=3;
	VAR glucose pregnancies dia_bp skin_fold bmi age;
RUN;


/*Now, conduct a multiple regression model.
Look at the residual plots to determine if this is a good model and if anything needs to be changed.  
*/

PROC REG DATA=pima PLOTS=(RESIDUALS(SMOOTH));
	MODEL glucose = pregnancies dia_bp skin_fold bmi age;
RUN;
 

*Next, I will refit the model and add residuals to the dataset;
 
PROC REG DATA=pima NOPRINT;
	MODEL glucose = pregnancies dia_bp skin_fold bmi age;
	OUTPUT OUT=work.pima_resid RESIDUAL=resids;
RUN;

/* proc print data=work.pima_resid; */
/* run; */

*This step gives bigger qq-plots and lets you see which observations are extreme observations;
PROC UNIVARIATE DATA=pima_resid;
	VAR resids;
	QQPLOT resids;  * added a larger qq-plot for good measure;
RUN;
*The observation on row 8 with a value of 87.96 has an extreme observation based on the rest of the data;


/* Creates a table to just see the extreme observation */
DATA pima_resid2;
	SET pima_resid;
	id = _N_;    * this adds a row number I can use;
	IF id = 8 THEN
		OUTPUT;  * i.e., I'm dropping all other rows;
RUN;
/* PROC PRINT DATA=pima_resid2; */
/* RUN; */



/*
I will refit the model with the extreme observation deleted.  
*/
PROC REG DATA=pima_resid PLOTS=(RESIDUALS(SMOOTH));
	MODEL glucose = pregnancies dia_bp skin_fold bmi age;
	WHERE resids BETWEEN -80 AND 80;
RUN;
/* After getting rid of the extreme observation, the residual by regressor plots with the LOWESS lines look to be following a straight
horizontal line. The qq-plot follows the 45 degree line and the Cook's D graph has a spike but the y axis values are relatively small.
*/

/* 
We can compare the betas & their SE's for the two models. 
The intercept value decreases for the model without the extreme observation.


            int   (SE)  	
full		55.26 (8.6)	    
w/o outs    53.57 (8.55)	
*/







ods rtf close;

