# R Workshop for ESA - April 6, 2021
# Instructor: harrison Dekker, URI Libraries and AI Lab
# Contact: hdekker@uri.edu

# Attribution: This lesson was adapted from https://rpubs.com/NickCHK/RTeach2020

################################################################################
## SETUP
################################################################################

install.packages(c("tidyverse", "stargazer", "jtools", "swirl"))

################################################################################
## DATA OBJECT TYPES
################################################################################

# There are a bunch of data object types. But the main ones to think about…
mynumber <- 1
mycharacter <- 'one'
myfactor <- factor(1, labels = 'one')

# R variable names can contain a period and you'll see this used a lot in code 
# samples found in textbooks, etc.
my.logical <- TRUE

# Show the current contents of a variable
mynumber

## Challenges
# 1. How would you change the value of mynumer to 100?
# 2. What happens if you add mynumber and mycharacter

################################################################################
## VECTORS
################################################################################

# We naturally combine multiple observations of the same type into vectors. 
# c() concatenates things together

# create a variable containing a vector
vector <- c(1, 10, 2, 3)

# other vector examples
1:10
factor(c(1, 1, 2, 2, 1), labels = c('one', 'two'))
c(vector, c(6, 7))

# You can access pieces of a vector using other vectors… numeric vectors to pick 
# indices, or logical vectors to include/exclude!
vec <- 11:20
vec[c(1, 5, 9)]
vec[rep(c(TRUE,FALSE),5)]

# Challenges
# 1. Write the code to assign a vector containing the series 100 through 200 to
#    a variable called myseries.
# 2. Create a vector containing the words: apples, oranges, bananas

################################################################################
## LISTS AND DATA.FRAMES
################################################################################

# A list is a very flexible R object that is basically a bunch of objects (such as vectors) 
# stuck together in a bigger object. You can pull out the sub-objects with [[]] or $. 
# Most of the time, strange complex objects output by functions (like regression 
# objects) are just lists

my.list <- list(a = 1:10, b = 11:20, c = 'hello')
my.list[['a']]
my.list$c

# Most of the time you’ll be working with data frames (unless you’re working with ts), 
# which are just lists that are made up of vectors of the same length

my.df <- data.frame(a = 1:10, b = 11:20, c = rep('hello',10))
my.df$d <- sample(c(TRUE, FALSE), 10, replace = TRUE)
head(my.df)

# Challenge
# Use the summary() function to generate summary statistics from your my.df data frame.

################################################################################
## FUNCTIONS
################################################################################  

# You will commonly want to pull variables out to run them through functions
# Keep in mind that many R functions need you to explicitly handle NAs

mean(my.df$d)
my.df$d[1] <- NA
mean(my.df$d)
mean(my.df$d, na.rm = TRUE)

data("CO2")

################################################################################
## GETTING DATA
################################################################################
# - LOTS of built-in data sets for writing class examples
# - Do data( and see what pops up. Many in packages too - see the Ecdat package, and this list
# - read.csv() to get CSV files, or in the haven package, read_dta(), read_csv(), etc. 
#   See also the foreign package. Note all of these can take a URL instead of a file on the system
# - Lots of packages designed to get fresh data into R, for example World Bank data has a few APIs. 
#   See list on nickchk.com/econometrics.html#Rdata.

## MANIPULATING DATA
# - Recommendation: Use the tidyverse package, which is a sort of alternate basis for using R
# - Tends to think about data manipulation in the way that economists think about it
# - The pipe %>% puts the left-hand thing as the first argument of the right-hand thing
# - Handles missing values better than base R
# - Consistent syntax
# - “tibble”s are just data.frames with a few extra bells and whistles
# - Comes with ggplot2 and functions for working with strings

## dplyr
# - dplyr is a package that comes with the tidyverse for manipulating data
# - It is based on chaining together simple “verbs”:
#   mutate() to create new variables
#   arrange() to sort data
#   filter() to pick observations and select() to pick variables
#   group_by() to perform subsequent calculations within-group (and ungroup() when done)
#   summarize() to collapse the data to the group level
# - MANY other, lesser, commands (including join functions (i.e. merge) and in 
#   tidyr the pivot functions (reshape) - see the Data Wrangling swirl() or cheat sheet)

# Example 1
library(tidyverse)
load("data/atusact.rda")
head(atusact)
str(atusact)
summary(atusact)
# Make sure to overwrite old data so it updates!
# Get two-digit and four-digit activity codes
# Keep just personal care activities
atusact <- atusact %>% 
  ungroup() %>%
  mutate(two.digit.activity = floor(tiercode/10000),
         four.digit.activity = floor(tiercode/100)) %>% 
  filter(two.digit.activity == 1)

# Example 2
# Get mean and SD of time spent in each of those activities
atusact_summary <- atusact %>%
  # Group into the different four-digit activities
  group_by(four.digit.activity) %>%
  # And summarize
  summarize(mean.dur = mean(dur, na.rm = TRUE),
            sd.dur = sd(dur, na.rm = TRUE)) %>%
  # Arrange by most often
  arrange(-mean.dur)
atusact_summary  

################################################################################
# REGRESSIONS
################################################################################

# IMPORTANT: Regression functions in R create regression objects

# Inputs: a formula object, a data set, options
# Outputs: a regression object, generally intended to be stored and then run through some other function
# To-do: look at the outcome! summary(regression.object) often a good option. Even better is stargazer(regression.object)
# To-do: make use of the regression! Perhaps run it through predict(), or get relevant statistics from it with $
#   Some of the relevant statistics are in the summary() not the regression object itself

load("data/atusresp.rda")
my.reg <- lm(hourly_wage ~ hh_size + work_hrs_week, data = atusresp)
my.reg2 <- lm(hourly_wage ~ hh_size + work_hrs_week + ptft, data = atusresp)
reg.predictions <- predict(my.reg)


my.reg
summary(my.reg)
summary(my.reg)$r.squared

# Significance stars are a common headache - note standards don’t match econ in default regression output
summary(my.reg)

################################################################################
## Regression Tables
################################################################################

# stargazer is a popular option. Print table to the screen with type='text', or to a turn-in-able file with type = 'html', out = 'filename.html'. All of its defaults are what economists would expect

library(stargazer)
stargazer(my.reg, my.reg2, type = 'text', keep = c('hh_size', 'ptft'))

# another option is jtools
# - handles weird regression types
# - summ() allows you to do robust SEs and VIFs easily, plus standardized coefs. - export_summs() prints tables to file (although no VIFs there).
# - effect_plot() for easy ggplot2 regression-scatterplot graphing (including regressions with nonlinear models / effects, controls, categorical predictors)
# - plot_coefs() for easy dot-and-CI plots of regression coefs.
# - Note summ() won’t do sig stars. export_summs() will, although you must set them to econ levels by hand.

library(jtools)
export_summs(my.reg, my.reg2, robust = TRUE, stars = c(`***` = 0.01, `**` =
                                                         0.05, `*` = 0.1), coefs = 'hh_size')

## Regression Graphs in jtools
data(mtcars)
carsreg <- lm(mpg~hp+I(hp^2)+cyl, data = mtcars)
effect_plot(carsreg, pred = hp, plot.points = TRUE, interval = TRUE)

plot_coefs(my.reg, my.reg2)

################################################################################
# Regression Formulas
################################################################################

# - outcome ~ independent.variable + independent.variable
# - Factor variables will automatically be turned to dummies. Can do y ~ x + factor(z) to be sure
# - Interactions with *, y ~ x*z, or just-interaction-not-individual with :, y ~ x + x:z
# - Full interaction sets: y ~ (x1 + x2 + x3)^2 gives all two-way interactions, ^3 adds on the three-way
# - Functions can go straight in: ln(y) ~ x
# - Do calculations on variables first with I(): I(y == 1) ~ I(x^2)
# - Lots of variables? y~. regresses on everything in the data but y. In the tidyverse, 
#   combine this with “tidyselect” helpers like select(starts_with('gdp_'))


## Regression Commands

# - lm() is standard OLS
# - Time series: see the packages dynlm, forecast, tseries
# - Pretty much all micro (robust SEs, clustering, IV, fixed effects) can be done with the estimatr (lm_robust(), iv_robust()) or lfe (felm()) packages. Former has easier syntax but is less powerful and doesn’t work with stargazer() - use jtools (export_summs()) or huxtable (huxreg()) instead.
# - Joint F-tests with linearHypothesis() in car
# - For anything: google “R my-thing” or “rstats my-thing”

################################################################################
# GRAPHING
################################################################################

# ggplot2 (ggplot()) is very much a top-tier graphing tool
# Each graph consists of: data, an aes()thetic (~axes), and a geometry (what you draw)
# Not actually too difficult to use; syntax for advanced styling can be difficult, but shouldn’t be too necessary for UGs. Stuff like legends and text styling can be made easier with the ggeasy package.

mtcars <- mtcars %>% 
  mutate(Transmission = factor(am, labels = c("Automatic", "Manual")))
ggplot(mtcars, aes(x = hp, y = mpg, shape = Transmission, color = Transmission)) + geom_point() + 
  theme_minimal() +
  geom_smooth(method = 'lm') + 
  labs(x = "Horsepower", y = "Miles per Gallon", title = "MPG vs. HP")

data("economics")
plot <- ggplot(economics, aes(x = date, y = unemploy/pop)) + geom_line() + theme_bw() +
  labs(x = "Month", y = "Unemployment")
plot
