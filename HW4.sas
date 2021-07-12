/****************************************************************************
*
* Project : BIOS 645 Course
*
* Program name : Homework 4
* 
* Author : Esther Mun  
*
* Date created : 2021-03-2
*
*
****************************************************************************/
ods rtf file = '/home/u41545557/Bios511/Output/Homework4.rtf';

/* Imports steroid levels txt file into SAS as a temporary work document. */
proc import datafile = "/home/u41545557/Bios511/Data/Women's_steroid_levels.txt"  
 out = steroid
 dbms = dlm 
 replace;
 getnames=yes;
 delimiter = '09'x;
run;

/* First, look and explore the dataset. */
* Look at the simple statistics to see the overview of what the data looks like;
PROC MEANS DATA=steroid N MIN MEDIAN MAX MEAN STD SKEW KURT MAXDEC=3;
	* MAXDEC= limits decimal places printed;
	VAR steroid age;
RUN;

/*Look at the histograms to see the distributions of the data and see if they follow a normal distribution.
  Can also see if the data is truncated and where most of the data fall */
PROC SGPLOT DATA=steroid;
	HISTOGRAM steroid;
	DENSITY steroid /TYPE=NORMAL;  * draws a normal distribution over histogram;
RUN;

PROC SGPLOT DATA=steroid;
	HISTOGRAM age;
	DENSITY age /TYPE=NORMAL;  * draws a normal distribution over histogram;
RUN;

* Correlation for relationship;
PROC CORR DATA=steroid;
	VAR steroid age;
RUN;
* .78 so positive relationship. so as their age increases, people have higher steroid levels. ;

/* Run a simple linear regression model of steroid on age */
* CLB option 95% includes confidence intervals ;
* Also added lack of fit test;
PROC REG DATA=steroid
         PLOTS=(RESIDUALS(SMOOTH));
	MODEL steroid = age /LACKFIT CLB;
RUN;

* Based on the LOWESS fit, there does seem to be curvature but there also is not a lot of data ;
* So, I will have to look at the residual plots, qq-plot, and Cook's D values.;

*scatter overlay on linear regression model. This overlay and LOWESS curve shows that the linear model does not fit and the data seem to have a curve in it.;
PROC SGPLOT DATA=steroid;
	SCATTER X=age Y=steroid;
	REG X=age Y=steroid;
	LOESS X=age Y=steroid; * this statement overlays;
                                     * a lowess fit;
RUN;


/*  Try adding another term */
* Could argue it is okay but histogram is a bit concerning.;

/* 
this code will create a new dataset that also has squared
terms
*/
DATA steroid2;       * the new dataset is made by;
	SET steroid;    * reading in the original; 
	age2 = age**2; * then adding 1new vars by;
	   * squaring the original ones;
RUN;

/* PROC PRINT DATA=steroid2; */
/* RUN; */


/* 
Here I re-fit these models with both the original X variable,
and the squared term
*/

PROC REG DATA=steroid2 PLOTS=(RESIDUALS(SMOOTH));
	MODEL steroid= age age2 /LACKFIT; 
run;	
 
 
 *overlays scatterplot and model;
PROC SGPLOT DATA=steroid2;
	SCATTER X=age Y=steroid;
	REG X=age Y=steroid;
	LOESS X=age Y=steroid; * this statement overlays;
                                     * a lowess fit;
RUN;


/* 
this code will create a new dataset that also has x^3 term.
*/
DATA steroid3;       * the new dataset is made by;
	SET steroid2;    * reading in the original; 
	age3 = age**3; * then adding 1new vars by;
	   * squaring the original ones;
RUN;

/* PROC PRINT DATA=steroid3; */
/* RUN; */


/* 
Here I re-fit these models with both the original X, X^2, and X^3 variables.

*/

PROC REG DATA=steroid3 PLOTS=(RESIDUALS(SMOOTH));
	MODEL steroid= age age2 age3 /LACKFIT CLB; 
run;	




 ods rtf close;