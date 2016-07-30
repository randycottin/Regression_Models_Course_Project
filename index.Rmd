#### Coursera : Regression Models - Course Project

## Exploring Motor Trend Car Road Tests 

### Executive Summary

In this project, we work for Motor Trend (a magazine about the automobile industry) and we will analyze the <code>mtcars</code> data set. Looking at a data set of a collection of cars (which contains 32 observations), they are interested in exploring the relationship between a set of variables and miles per gallon <code>mpg</code> (outcome). They are particularly interested in the following two questions:

- Is an automatic or manual transmission better for <code>mpg</code>?
- Quantifying how different is the <code>mpg</code> between 'Automatic' and 'Manual' transmissions?

### Data Preprocessing and Transformations

First of all, we load the data set, perform the necessary data transformations by factoring the some variables and look the data:

```{r loading, cache=TRUE}
data(mtcars)
mtcars$cyl <- factor(mtcars$cyl)
mtcars$vs <- factor(mtcars$vs)
mtcars$gear <- factor(mtcars$gear)
mtcars$carb <- factor(mtcars$carb)
mtcars$am <- factor(mtcars$am,labels=c('Automatic','Manual'))
str(mtcars)
```

### Exploratory Analysis

We explored various relationships between variables of interest and the outcome. Initially, we plot the relationships between all the variables of the dataset (see plot 2 in the Appendix). From the plot 1 we notice that variables like <code>cyl</code>, <code>disp</code>, <code>hp</code>, <code>drat</code>, <code>wt</code>, <code>vs</code> and <code>am</code> seem to have some strong correlation with <code>mpg</code>. We will use linear models to quantify that in the next section. 

Additionally we plot a boxplot of the variable <code>mpg</code> when <code>am</code> is 'Automatic' or 'Manual' (see plot 3 in the Appendix). This plot shows that the <code>mpg</code> incresases when the transmission is 'Manual'.

### Regression Analysis

In this section we will build linear regression models based on the different variables of interest and try to find out the best model fit. We will compare it with the base model which we have using <b>ANOVA</b>. After model selection, we will perform an analysis of residuals.

### Build the Model

Based on plot 2 there are several variables seem to have high correlation with <code>mpg</code>. We willl build an initial model with all the variables as predictors and perfom stepwise model selection to select significant predictors for the final model. This is taken by the <b>step</b> method, which runs <code>lm</code> multiple times to build multiple regression models and select the best variables from them, using both <b>forward selection</b> and <b>backward elimination</b> methods by the <b>AIC</b> algorithm:

```{r modelling, cache=TRUE, results='hide'}
mod_init <- lm(mpg ~ ., data = mtcars)
mod_best <- step(mod_init, direction = "both")

```

As we can see, the best model obtained from the above computations have <code>cyl</code>, <code>wt</code>, <code>hp</code> and <code>am</code> as relevant variables:

```{r bestmodel, cache=TRUE}
summary(mod_best)
```
We can see that the adjusted R<sup>2</sup> value is equal to 0.84 which is the maximum obtained considering all combinations of variables. Therefore we can conclude that more than 84% of the variability is explained by this model.

Now, using ANOVA, we will compare the base model with only <code>am</code> as the predictor variable and the best model obtained above:

```{r comparemodel, cache=TRUE}
mod_base <- lm(mpg ~ am, data = mtcars)
anova(mod_best, mod_base)
```
Looking at this result, the p-value obtained is highly significant, and we reject the null hypothesis that the confounder variables <code>cyl</code>, <code>hp</code> and <code>wt</code> do not contribute to the accuracy of the model.

### Analysis of the Residuals and Diagnostics

Now we explore the residual plots of our regression model and also compute some of the regression diagnostics for our model to find out some interesting leverage points (often called as outliers) in the data set:

```{r plot_residuals,  fig.width=10, fig.height=10}
par(mfrow=c(2,2))
plot(mod_best, which=1)
plot(mod_best, which=2)
plot(mod_best, which=3)
plot(mod_best, which=5)
```

From these plots we can conclude the following:

- The Residuals vs Fitted plot shows random points on the plot that verifies the independence condition.
- In the Normal Q-Q plot the points mostly fall on the line indicating that the residuals are normally distributed.
- In the Scale-Location plot the points are in a constant band pattern, indicating constant variance.
- Finally, the Residuals vs Leverage plot shows some points of interest (outliers or leverage points) are in the top right corner.

Now we will compute some regression diagnostics of our model to find out these interesting leverage points. We compute top three points in each case of influence measures.

```{r leverage, cache=TRUE}
lev <- hatvalues(mod_best)
tail(sort(lev),3)
inf <- dfbetas(mod_best)
tail(sort(inf[,6]),3)
```
Looking at this result we see that they the same cars shown in the residual plots.

###  Statistical Inference

Finally, we will perform a t-test assuming that the transmission data has a normal distribution and we will see that the manual and automatic transmissions are significatively different:

```{r ttest, cache=TRUE}
t.test(mpg ~ am, data = mtcars)
```

### Conclusions

From the <code>summary(mod_best)</code> we can conclude the following:

- Miles per gallon <code>mpg</code> will increase by 1.81 in cars with 'Manual' transmission compared to cars with 'Automatic' transmission (adjusted by <code>hp</code>, <code>cyl</code>, and <code>wt</code>). So, the conclusion for Motor Trend Magazine is: 'Manual' transmission is better for <code>mpg</code>.
- Miles per gallon <code>mpg</code> will decrease by 2.5  for every 1000 lb of increase in <code>wt</code> (adjusted by <code>hp</code>, <code>cyl</code>, and <code>am</code>).
- Miles per gallon <code>mpg</code> decreases with increase of <code>hp</code>.
- Miles per gallon <code>mpg</code> will decrease by a factor of 3 and 2.2 if number of cylinders <code>cyl</code> increases from 4 to 6 and 8, respectively (adjusted by <code>hp</code>, <code>wt</code>, and <code>am</code>).

## Appendix

As we shown in Exploratoy Analysis section we explored various relationships between variables of interest and the outcome. We plot the relationships between all the variables of the dataset:

```{r scatterplot, fig.width=11, fig.height=11, cache=TRUE, warning=FALSE, cache.lazy=FALSE, message=FALSE}
library(car)
scatterplot.matrix(~mpg+cyl+disp+hp+drat+wt+qsec+vs+am+gear+carb, data=mtcars,
   main="Plot 2: Scatterplot Matrix")
```

   
Additionally we plot a boxplot of the variable <code>mpg</code> when <code>am</code> is 'Automatic' or 'Manual':

```{r boxplot,  fig.width=6, fig.height=6}
boxplot(mpg ~ am, data=mtcars, main="Plot 3: Miles per gallon by Transmission type",
   xlab="Transmission type", ylab="Miles Per Gallon") 
```
