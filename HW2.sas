/****************************************************************************
*
* Project : BIOS 645 Course
*
* Program name : Homework 1
*
*
* Date created : 2021-02-01
*
*
****************************************************************************/
ods rtf file = '/home/u41545557/Bios511/Output/Homework2.rtf';

/* 
  Imports the txt file into a work dataset
*/
proc import datafile = '/home/u41545557/Bios511/Data/Chinese_health_&_family_life_study.txt'
 out = chinese
 dbms = dlm 
 replace;
 getnames=yes;
 delimiter = '09'x;
run;

/* 1: Univariate descriptives for the A_height and R_height variables. Since these are continuous variables, proc means and 
proc sgplot will be used. */
title1'Simple Descriptive Statistics for the height of the Responding Women';
PROC MEANS DATA=chinese N MIN MEDIAN MAX MEAN STD SKEW KURT MAXDEC=3;
	* MAXDEC= limits decimal places printed;
	VAR R_height;
RUN;

title1'Histogram and Density Curve for the Distribution of the height of the Responding Women ';
PROC SGPLOT DATA=chinese;
	HISTOGRAM R_height;
	DENSITY R_height /TYPE=NORMAL;  * draws a normal distribution over histogram;
RUN;

title1"Simple Descriptive Statistics for the height of the Responding Women's partner";
PROC MEANS DATA=chinese N MIN MEDIAN MAX MEAN STD SKEW KURT MAXDEC=3;
	* MAXDEC= limits decimal places printed;
	VAR A_height;
RUN;

title1"Histogram and Density Curve for the Distribution of the height of the Responding Women's partner";
PROC SGPLOT DATA=chinese;
	HISTOGRAM A_height;
	DENSITY A_height /TYPE=NORMAL;  * draws a normal distribution over histogram;
RUN;

*Clears out previous titles;
title;

/* 2: Regress A on R and R on A  and show that these processes do not give the same result. */
PROC REG DATA=chinese PLOTS=NONE;
	MODEL A_height = R_height;
PROC REG DATA=chinese PLOTS=NONE;
	MODEL R_height = A_height;
RUN;

DATA _NULL_;
	b0 = 106.75232;
	b1 = 0.30694;
	new_b0 = -b0/b1;
	new_b1 = 1/b1;
	PUT "The converted intercept is: " new_b0;
	PUT "The converted slope is:        " new_b1;
RUN;
/*
The converted intercept is: -347.7953998
The converted slope is:  3.2579657262     
*/



/* 3: Correlate A and R,  turn them into z-scores, and regress z(A) onto z(R). Show that the slope value is equivalent to the correlation.    */
* turn raw data into z-scores;
*This standardizes the data; 
PROC STANDARD DATA=chinese MEAN=0 STD=1 OUT=chinese_two;
RUN;
* I won't use NOSIMPLE to check standardization;
PROC CORR DATA=chinese_two;  
	VAR R_height A_height;
PROC REG DATA=chinese_two PLOTS=NONE;
	MODEL A_height=R_height;
RUN;
* the slope equals the correlation;
*The slope value is 0.32386 and it equals the correlation value of 0.32386;



/* 4: Regress A onto R and suppress the intercept. Then show that without the intercept, the line is biased. */

*Regresses without intercept;
PROC REG DATA=chinese PLOTS=NONE;
	MODEL A_height=R_height /NOINT;
RUN;

/*
Here I confirm that the regression line w/ the intercept
goes though the mean, but without intercept, then it is biased.
*/
DATA _NULL_;
	x = 159.291;
	b =  1.07386;
	y_hat = x*b;
	y = 171.167;
	PUT "The predicted y at x-bar is: " y_hat;
	PUT "The observed y-bar is:       " y;
RUN;

DATA _NULL_;
	x  = 159.291;
	b0 = 116.73728;
	b1 = 0.34170;
	y_hat = b0 + x*b1;
	y = 171.167;
	PUT "The predicted y at x-bar is: " y_hat;
	PUT "The observed y-bar is:       " y;
RUN;

/* 
Suppressed intercept:
The predicted y at x-bar is: 171.05623326
The observed y-bar is:       171.167

With intercept fitted:
The predicted y at x-bar is: 171.1670147
The observed y-bar is:       171.167
*/


/* 5: Regress A onto R */
PROC REG DATA=chinese PLOTS=NONE;
	MODEL A_height = R_height;
run;	


* 95% CI & ANOVA table ; 
PROC REG DATA=chinese;
	MODEL A_height=R_height /CLB;
RUN; 
 
*The 95% confidence interval for the slope is (0.29167, 0.39173).; 


ods rtf close;


