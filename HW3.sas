/****************************************************************************
*
* Project : BIOS 645 Course
*
* Program name : Homework 3
* 
*
* Date created : 2021-02-14
*
*
****************************************************************************/
ods rtf file = '/home/u41545557/Bios511/Output/Homework3.rtf';

/* Imports smoke and cancer txt file into SAS as a temporary work document. */
proc import datafile = '/home/u41545557/Bios511/Smoke_&_cancer.txt'
 out = smoke
 dbms = dlm 
 replace;
 getnames=yes;
 delimiter = '09'x;
run;

/* First, look and explore the dataset. 
   Note that variables lung and cig have a high mean, median, max, and min.
   The rest of the variables have smaller numbers for mean, median, max, and min. */
PROC MEANS DATA=smoke N MIN MEDIAN MAX MEAN STD SKEW KURT MAXDEC=3;
	* MAXDEC= limits decimal places printed;
	VAR cig blad lung kid leuk;
RUN;

/* Run proc sgplot on the two variables we are focusing on.
	Note that distribution of cig is somewhat normal but most of the data falls between 20 and 30.
	The distribution of lung is slightly skewed to the left. */
PROC SGPLOT DATA=smoke;
	HISTOGRAM cig;
	DENSITY cig /TYPE=NORMAL;  * draws a normal distribution over histogram;
RUN;

PROC SGPLOT DATA=smoke;
	HISTOGRAM lung;
	DENSITY lung /TYPE=NORMAL;  * draws a normal distribution over histogram;
RUN;

/* Find a regression model for cancer rates onto cigarette sales. */
PROC REG DATA=smoke PLOTS=NONE;
	MODEL lung = cig;
run;

*Regression model that gives 95% CI and ANOVA table;
PROC REG DATA=smoke ;
	MODEL lung = cig / CLB;
run;


/* First, I tried to change the model by transforming it */

* this code will create a new dataset that is transformed;
/* DATA smoke2; */
/* 	SET smoke;             */
/* 	y_ln  = log(lung);    * I'll try the log & the reciprocal; */
/* 	y_rcp = 1/lung;            */
/* RUN; */


/* *These re-fit the models with the transformed versions; */

/* PROC REG DATA=smoke2; */
/* 	MODEL y_ln=cig; */
/* RUN; */

/* PROC REG DATA=smoke2; */
/* 	MODEL y_rcp=cig; */

/* RUN; */
/* After reviewing the qq plots and residual plots of these transformed models, they do not look like they made the model better.
	Instead, the qq plots and residual plots seem to be worse so I will not be using these transformed models as the final model. */



/* Next, I wanted to take out certain points that look like outliers. I did this by looking at the CooksD values.
	The proc reg statement below creates an output dataset that has the cooks D values and I saw that three values where
	the data points seem to be outliers. Those data points are at lines 15 and 25 and correspond with the states LA and NE.
	The third data point is at line 32 for the state PE. 
	I then excluded these three points by only showing the regression model where the CooksD value is less than .06
*/


PROC REG DATA=smoke NOPRINT;
	MODEL lung=cig;
	* this output statement will save;
	* a new dataset w/ Cook's Ds listed;
	OUTPUT OUT=model_CooksD COOKD=cd; 
	* note I'm saving this in the WORK directory; 
RUN;

*potential problem becase high CD for data point 25=NE & another point at so refit model to leave out this point;


PROC REG DATA=model_CooksD;  
	MODEL lung=cig / CLB;
	WHERE cd < .06;      
RUN;



ods rtf close;
