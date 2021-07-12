/****************************************************************************
*
* Project : BIOS 645 Course
*
* Program name : Homework 6
* 
* Date created : 2021-03-23
*
*
****************************************************************************/

ods rtf file = '/home/u41545557/Bios511/Output/Homework6.rtf';


/* 
  Imports the txt file into a work dataset
*/
proc import datafile = '/home/u41545557/Bios511/Data/Swiss_fertility.txt'
 out = swiss
 dbms = dlm 
 replace;
 getnames=yes;
 delimiter = '09'x;
run;


/* First, get simple descriptive statistics for each variable in the dataset. 
	I had to do 'infant.mortality'n because it lets sas know that this "string" is actually a variable.
	The fertility variable ranges between 35 to 92.5 and has a mean of 70.14. The median is similar to the mean of 70.4, meaning the distribution is symmetric. Because the skewness is -.486, the distribution seems to be slightly skewed to the left.
The examination variable ranges bewteen 3 and 37 with a mean of 16.49 and a median of 16.0. The distribution also looks to be symmetric and the skewness of .476 indicates that the distribution is slightly skewed to the right.
The agriculture variable has a minimum of 1.2 and a maximum of 89.7. The mean is 50.66 and the median is 54.1, so the distribution is positively skewed.
The education variable has a minimum of 1 and a maximum of 53 and the mean is 10.98 and the meian is 8.0. The distribution looks to be positively skewed and the skewness value of 2.421 also supports this.
The catholic variable has a minimum of 2.15 and a maximum of 100. The mean is 41.14 and the median is 15.14, so the distribution is postively skewed. 
The infant.mortality variable has a minimum of 10.8 and a maximum of 26.60 and a mean of 19.94. The median is 20.0 so the median is similar to the mean and this indicates that the distribution is symmetric.  
*/
PROC MEANS DATA=swiss N MIN MEDIAN MAX MEAN STD SKEW KURT MAXDEC=3;
	* MAXDEC= limits decimal places printed;
	VAR fertility examination agriculture education catholic 'infant.mortality'n;
RUN;

*Run proc sgplot to see the distribution of the data;
*The distribution of the fertility variable seems to be mostly normal, but most of the values do fall between 60 and 80.;
PROC SGPLOT DATA=swiss;
	HISTOGRAM fertility;
	DENSITY fertility /TYPE=NORMAL;  * draws a normal distribution over histogram;
RUN;

*The distribution of the examination variable seems to be almost uniform with a couple of values near 30 and 40. The values are truncated at a value between 0 and 5.;
PROC SGPLOT DATA=swiss;
	HISTOGRAM examination;
	DENSITY examination /TYPE=NORMAL;  * draws a normal distribution over histogram;
RUN;

*The distribution of the agriculture variable seems to be slightly skewed to the left with most of the values being between 50 and 75.;
PROC SGPLOT DATA=swiss;
	HISTOGRAM agriculture;
	DENSITY agriculture /TYPE=NORMAL;  * draws a normal distribution over histogram;
RUN;

*The distribution of the education variable seems to be skewed to the right with almost all of the values being between 0 and 20. There is a high peak between 0 and 20.;
PROC SGPLOT DATA=swiss;
	HISTOGRAM education;
	DENSITY education /TYPE=NORMAL;  * draws a normal distribution over histogram;
RUN;

*The distribution of the catholic variable seems to be bimodal with two peaks at 0 and 100. There are a couple of values between these two peaks.;
PROC SGPLOT DATA=swiss;
	HISTOGRAM catholic;
	DENSITY catholic /TYPE=NORMAL;  * draws a normal distribution over histogram;
RUN;

*The distribution of the infant.mortality variable seems to be mostly normal with the main peak being in the center at the value 20.;
PROC SGPLOT DATA=swiss;
	HISTOGRAM 'infant.mortality'n;
	DENSITY 'infant.mortality'n /TYPE=NORMAL;  * draws a normal distribution over histogram;
RUN;



/* Problem 1: First, regress fertility rates onto all variables except education. */
PROC REG DATA=swiss PLOTS=(RESIDUALS(SMOOTH));
	MODEL fertility = agriculture examination catholic 'infant.mortality'n / CLB;
run;

*There seems to be some heteroskedasticity and potential outliers due to the Cook's D graph. The qq-plot does not
really follow a 45 degree line so, I will examine the residuals to see if any data points should be excluded when regressing.;
PROC REG DATA=swiss NOPRINT;
	MODEL fertility = agriculture examination catholic 'infant.mortality'n / CLB;
	OUTPUT OUT=work.swiss_resid RESIDUAL=resids;
RUN;

*This step gives bigger qq-plots and lets you see which observations are extreme observations;
PROC UNIVARIATE DATA=swiss_resid;
	VAR resids;
	QQPLOT resids;  * added a larger qq-plot for good measure;
RUN;

/*There are two data points that might need to be excluded to create a better model and those data points are the 
municipalities 45, 46, and 47 (V. De Geneve, Rive Droite, and Rive Gauche) as they have residual values of -23.92, -22.65, and -14.96, respectively. 
The other residual values are mostly between 12 and -12. 

I will refit the model with the extreme observation deleted.  
*/
PROC REG DATA=swiss_resid PLOTS=(RESIDUALS(SMOOTH));
	MODEL fertility = agriculture examination catholic 'infant.mortality'n / CLB;
	WHERE resids BETWEEN -13 AND 15;
RUN;



/* Problem 2: I will fit a regression model for fertility rates onto every variable, including education. */
PROC REG DATA=swiss PLOTS=(RESIDUALS(SMOOTH));
	MODEL fertility = education agriculture examination catholic 'infant.mortality'n / CLB;
run;
*Compared this regression model to the first regression model;
/* PROC REG DATA=swiss PLOTS=(RESIDUALS(SMOOTH)); */
/* 	MODEL fertility = agriculture examination catholic 'infant.mortality'n / CLB; */
/* run; */

/* Based on the Cook's D graph and residual by regressors graphs, there may be an extreme observation that could be excluded
to improve the model. I will create a dataset that looks at the residuals. 
The municipalities with a residual value that stands out amongst the other values are Sierre with a value of 15.32 and Rive Gauche with a value of -15.27.
While there is another value that has a larger residual value (Porrentruy with a value of -14.40), when refitting a model without these 3 values,
the model looks to be overfitted since the qq-plot does not follow a horizontal line and the residual by regressors plot seem to be overfitted. 
I will refit the regression model without these extreme observations. 
*/

PROC REG DATA=swiss NOPRINT;
	MODEL fertility = education agriculture examination catholic 'infant.mortality'n / CLB;
	OUTPUT OUT=work.swiss_resid2 RESIDUAL=resids;
RUN;

*This step gives bigger qq-plots and lets you see which observations are extreme observations;
PROC UNIVARIATE DATA=swiss_resid2;
	VAR resids;
	QQPLOT resids;  * added a larger qq-plot for good measure;
RUN;

PROC REG DATA=swiss_resid2 PLOTS=(RESIDUALS(SMOOTH));
	MODEL fertility = education agriculture examination catholic 'infant.mortality'n / CLB;
	WHERE resids BETWEEN -15 AND 15;
RUN;




/* Problem 3: I will create an interaction term between the education and catholic variables.
I created a dataset called swiss_new that has the interaction variable. */
data swiss_new;
	set swiss;
	
	interact = education*catholic;
run;

/*I will fit a regression model with this interaction term.
The residual by predicted value graph does not exhibit heteroscedasticity and the qq-plot mainly follows the 45 degree line but the ends of the graph slightly curve.
The Cook's D graph looks fine but there may be some extreme observations that could be excluded to improve the model. 
The residual by regressors graphs with the LOWESS Smooth curves mainly follow the horizontal line.	
*/
PROC REG DATA=swiss_new PLOTS=(RESIDUALS(SMOOTH));
	MODEL fertility = education catholic interact / CLB;
RUN;

/*I will create a dataset with the residuals to see if any observations should be excluded.
The observation Glane with a value of 14.297 could be excluded.
I will refit the model without this observation.
The refitted model's residual by predicted values does not exhibit heteroscedasticity and the qq-plots follow the 45 degree line.
The Cook's D graph looks fine even if there are values that are above the warning line because the y-axis values are small. 
The residual by regressors graphs look fine and do not extremely differ from the graphs produced by the regression model that includes this observation.    
*/
PROC REG DATA=swiss_new NOPRINT;
	MODEL fertility = education catholic interact / CLB;
	OUTPUT OUT=work.swiss_resid3 RESIDUAL=resids;
RUN;


PROC REG DATA=swiss_resid3 PLOTS=(RESIDUALS(SMOOTH));
	MODEL fertility = education catholic interact / CLB;
	WHERE resids BETWEEN -15 AND 14;
RUN;



/*  To interpret the model with the interaction term, I will calculate the derivative and slope. 
I will also pick arbitrary low and high values of 0 and 100. 
B0 = intercept
B1 = education variable
B2 = catholic variable
B3 = interaction term

         derivative =      B1 +       B3*x2j 
         derivative = -0.40447 + -0.00989*x2j 

         intercept =       B0 +      B2*x2j 
         intercept = 70.82866 + 0.17741*x2j 
       
*/
DATA _NULL_;
	* I arbitrarily decided the low & high;
    *  values would be 0 & 100;
	low    = -0.40447 + -0.00989*0; 
	* the mean is obviously 50;
	mean   =  -0.40447 + -0.00989*50; 
	high   =  -0.40447 + -0.00989*100;
	low_i  = 70.82866 + 0.17741*0;  
	mean_i = 70.82866 + 0.17741*50; 
	high_i = 70.82866 + 0.17741*100;
	PUT "intercept at catholic=0  = " low_i;
	PUT "    slope at catholic=0  =  " low;
	PUT "intercept at catholic=50 = " mean_i;
	PUT "    slope at catholic=50 = " mean;
	PUT "intercept at catholic=100 = " high_i;
	PUT "    slope at catholic=100 = " high;
RUN;
/* 
 intercept at catholic=0  = 70.82866
     slope at catholic=0  =  -0.40447
 intercept at catholic=50 = 79.69916
     slope at catholic=50 = -0.89897
 intercept at catholic=100 = 88.56966
     slope at catholic=100 = -1.39347

Now let's make a new dataset with predicted values at
specified levels of x2 
*/

DATA interaction_plot_data;
	SET swiss_resid3;
	low  = 70.82866 + -0.40447*education;
	mean = 79.69916 + -0.89897*education;
	high = 88.56966 + -1.39347*education;
RUN;

/* PROC PRINT DATA=interaction_plot_data; */
/* RUN; */

* Creates a plot plot that shows how the relationship between education and fertility changes depending on the level of the catholic variable;
PROC SGPLOT DATA=interaction_plot_data;
	* if you prefer, you can make the plot;
	* without the data ;
	SCATTER X=education Y=fertility   /          LEGENDLABEL="data";  
	REG     X=education Y=low  /NOMARKERS LEGENDLABEL="catholic = 0";
	REG     X=education Y=mean /NOMARKERS LEGENDLABEL="catholic = 50";
	REG     X=education Y=high /NOMARKERS LEGENDLABEL="catholic = 100";
RUN;




ods rtf close;
