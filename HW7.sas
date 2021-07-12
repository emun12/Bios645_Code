/****************************************************************************
*
* Project : BIOS 645 Course
*
* Program name : Homework 7
* 
*
* Date created : 2021-03-30
*
*
****************************************************************************/

ods rtf file = '/home/u41545557/Bios511/Output/Homework7.rtf';


/* 
  Imports the txt file into a work dataset
*/
proc import datafile = '/home/u41545557/Bios511/Data/Tooth_growth.txt'
 out = tooth
 dbms = dlm 
 replace;
 getnames=yes;
 delimiter = '09'x;
run;

*there is an interaction if interaction term is significant. VIF correlated? don't drop singular term from the model.;
*standardize. new variable ;
*proc corr: type & dose are uncorrelated. check for collinearity. if uncorrelated, then no collinearity in model? ;

/* I created a new datatset with the dummy variable that has the numeric variables for the type variable.
	I created an interaction term between type and dose. */
data tooth_new;
	set tooth;
		IF type='VC' THEN typeNum = 1; 
		ELSE typeNum = 0;
		*Created dummy variable to convert vc = 1 and OJ = 0 for type;
	
	interaction = typeNum * dose;
	*Creates an interaction term between type and dose;
Run;


*I checked if the dummy variable, typeNum, matched the original type variable and it does. ;
PROC FREQ DATA=tooth_new;
	TABLES typeNum*type /NOROW NOCOL NOPERCENT;
RUN;

/* I will conduct descriptive statistics for each variable. 
	The histogram for dose indicates that there are 3 main doses. The histogram for length is not normal
	as it skews to the right and there is a peak between 20-30. The scatterplot with the LOWESS line shows
	the direction of the relationship between dose and length which is that as dose increases, so does length.
	
*/
PROC SGPLOT DATA=tooth_new;
	HISTOGRAM dose;
	DENSITY   dose /TYPE=NORMAL;
PROC SGPLOT DATA=tooth_new;
	HISTOGRAM length;
	DENSITY   length  /TYPE=NORMAL;
PROC SGPLOT DATA=tooth_new;
	VBOX dose /CATEGORY=typeNum;
PROC SGPLOT DATA=tooth_new;
	VBOX length  /CATEGORY=typeNum;
PROC SGPLOT DATA=tooth_new;
	SCATTER X=dose Y=length;
	REG     X=dose Y=length /NOMARKERS;
	LOESS   X=dose Y=length /NOMARKERS;
RUN;


/* The mean for dose is 1.167 and it ranges from .5 to 2. The median is 1.0 and the standard deviation is .629. 
The skewness indicates that there is a slight skew in the distribution but the tails are fairly large as indicated by kurtosis.
The mean for length is 18.813 and the median is 19.250 so there is a slight skew in the distribution.
 The minimum is 4.2 and the maximum is 33.9.
The mean for typeNum is .5 and the median is .5 so the distribution is symmetrical. 
The minimum is 0 and the maximum is 1. Since this variable only has two potential values of 1 and 0, the means procedure does not give a lot more information.
The mean, min, median, and max are all the same for the dose variable when the class is typeNum. 
The mean, min, median, and max differ for the length variable when the class is typeNum. 
When typeNum is 0, the mean is 20.663 and the median is 22.7 so there is skewness in the distribution. 
The min is 8.2 and the max is 30.9. When typeNum is 1, the mean is 16.963 and the median is 16.5 so there may be slight skewness but it seems to be mostly symmetrical. 
The min is 4.2 and the max is 33.9.
  */
PROC MEANS DATA=tooth_new N MIN MEDIAN MAX  MEAN STD SKEW KURT MAXDEC=3;                                       
	VAR dose length typeNum;
PROC MEANS DATA=tooth_new N MIN MEDIAN MAX  MEAN STD SKEW KURT MAXDEC=3;                                       
	VAR   dose;
	CLASS typeNum;
PROC MEANS DATA=tooth_new N MIN MEDIAN MAX  MEAN STD SKEW KURT MAXDEC=3;                                        
	VAR   length;
	CLASS typeNum;
RUN;



/* I will regress length onto typeNum and dose without the interaction variable and then I will regress length
	onto both variables and include the interaction variable.
	When regressing without the interaction variable, the residual plot shows some heteroskedasticity and the qq-plot does
	not directly follow the 45 degree line. The Cook's D graph shows that there may be some potential extreme observations.
	The residual by regressors graph look fine.
	But, when including the interaction variable, the residual plot does not look to be heteroskedastic and the qq-plot follows
	the 45 degree line better as the tails are not as curved outwards. The residual by regressors graph looks fine but there are 
	points in which most of the values are clustered. The Cook's D graph does still show that there may be some potential extreme observations but 
	for the most part, since the y-axis values are so small, the Cook's D graph looks fine.
	The VIFs for the regression model with the interaction looks fine as the VIFs are all under 10. 
*/
PROC REG DATA=tooth_new PLOTS=(RESIDUALS);
		 * notice here I need to use the numeric ;
	MODEL length = typeNum dose /VIF;  
RUN;

PROC REG DATA=tooth_new PLOTS=(RESIDUALS(SMOOTH));
	MODEL length=typeNum dose interaction /VIF;
RUN;


/* Since we will include the interaction term, we can determine the relationship between length and dose depending on
the typeNum variable (0 = VC, 1 = OJ).
I will use sas as a calculator to plot the regression model over the actual data.

*/
DATA _NULL_;
	B_0    = 11.550;
	B_typeNum =  23.07615;
	B_dose  =  14.03017;
	B_int  =  -8.72828;

	* for treatment;
	treat_int   = B_0   + B_typeNum;
	treat_slope = B_dose + B_int;

	PUT "Mean of control group when dose=0:                       "
        B_0;
	PUT "Mean of treatment group when dose=0:                     "
        treat_int;
	PUT "Slope of dose-length relationship for control group:    "
        B_cov;
	PUT "Slope of dose-length relationship for treatment group:   "
        treat_slope;
RUN;

/*
 Mean of control group when dose=0:                       11.55
 Mean of treatment group when dose=0:                     34.62615
 Slope of dose-length relationship for control group:    14.03017
 Slope of dose-length relationship for treatment group:   5.30189

*/


/*
Then I created the y-hat values that correspond to those by copying the betas from the output.
*/
DATA y_hats;
	DO i = -2 to 2 by 0.5;
		x_plot  = i;
		y_cond  = 11.550 + 14.03017*x_plot;
		y_treat = 34.62615 + 5.30189*x_plot;
		DROP i;
	   	OUTPUT;
	END;
RUN;

/*
I had to create a combined dataset so that I can use this to overlay the model onto the data.
Some values are missing since each line does not match up to each other in both datasets.
*/
DATA tooth_combined;
	SET tooth_new y_hats;
	IF typeNum=1 THEN treat_x = dose;  
	IF typeNum=1 THEN treat_y = length;
	* there is no 'else' clause, when cond!=1, ;
    * there is a missing datum ;
RUN;


PROC SGPLOT DATA=tooth_combined;
    * this is a scatterplot of the original data ;
	SCATTER X=dose Y=length;  
	* I overplot the treated patients in a different color;
	SCATTER X=treat_x Y=treat_y 
            /MARKERATTRS=(COLOR=red 
                          SYMBOL=circlefilled);  

	* SERIES will connect the points created above w/ lines.;
	SERIES X=x_plot Y=y_cond;        
	SERIES X=x_plot Y=y_treat /LINEATTRS=(COLOR=red);
RUN;


/*  To interpret the model with the interaction term, I will calculate the derivative and slope.  */
/* I will also pick arbitrary low and high values of 0 and 2.  */


PROC REG DATA=tooth_new PLOTS=(RESIDUALS(SMOOTH));
	MODEL length=typeNum dose interaction /VIF;
RUN;
DATA _NULL_;
	* I arbitrarily decided the low & high;
    *  values would be 0 & 5;
low = -8.255 + 3.90429 * 0;
/* mean = -8.255 +   3.90429 * 2.5; */
high = -8.255  +  3.90429 * 2;
low_i = 11.550 + 7.81143 * 0;
/* mean_i = 11.550 + 7.81143 * 2; */
high_i = 11.550 + 7.81143 * 2;

	PUT "intercept at type=1 = " low_i;
	PUT "    slope at type=0  =  " low;
	PUT "intercept at type=1 = " high_i;
	PUT "    slope at type=2 = " high;

RUN;


/* 
 intercept at type=1 = 11.55
     slope at type=0  =  -8.255
 intercept at type=1 = 27.17286
     slope at type=2 = -0.44642
*/


/* This dataset will have the lines that will be used to plot the relationship between dose and length depending on the interaction term. */

DATA tooth_new2;
	SET tooth_new;
	low  = 11.55 + -8.255*dose;
/* 	mean = 31.078575 + 1.505725*dose; */
	high = 27.17286 + -0.44642*dose;
RUN;


/* Creates a plot that shows how the relationship between length of teeth and dosage of vitamin C depending on the type of vitamin C variable
I only did type = 0 and type = 1 because type can either be VC or OJ.
*/
PROC SGPLOT DATA=tooth_new2;

	SCATTER X=dose Y=length  /          LEGENDLABEL="data";  
	REG     X=dose Y=low  /NOMARKERS LEGENDLABEL="type=0";
	REG     X=dose Y=high /NOMARKERS LEGENDLABEL="type=1";
RUN;



ods rtf close;
