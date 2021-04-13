library(tidyverse)
library(rstudioapi)
# set working directory
setwd(dirname(getActiveDocumentContext()$path))
data <- read.csv2("data/final/data_clean.csv", sep=",")
attach(data)
summary(data)
dim(data)

# univariate EDA
pie(table(program))
pie(table(ml))
pie(table(ir))
pie(table(stats))
pie(table(db))
pie(table(gender))
hist(table(chocolate))
hist(stress)

# bivariate EDA
boxplot(stress~gender)
boxplot(stress~stats)
boxplot(stress~ml)
boxplot(stress~ir)
boxplot(stress~db)
boxplot(stress~chocolate)

boxplot(rn~gender)
summary(aov(rn~gender))

boxplot(rn~ml)
boxplot(rn~ir)
boxplot(rn~db)
boxplot(rn~chocolate)

plot(table(chocolate, gender))

plot(gain[gain<101], stress[gain<101])

hist(bed_time)

#### Association ####
library(arules)
library(arulesViz)

dataset_courses <- data %>%
  select(ml,ir,db,stats) %>% 
  filter(ir!="unknown", stats !="unknown", db!="unknown")

dataset_courses <- as(dataset_courses, "transactions")

# Fitting model
# Training Apriori on the dataset
associa_rules = apriori(data = dataset_courses, 
                        parameter = list(support = 0.01, 
                                         confidence = 0.5))

# support --> how frequently the itemset appears in the dataset 
# confidence --> how often the rule has been found to be true

# Plot
itemFrequencyPlot(dataset_courses, topN = 10)
# the highest frequency is taking statistcs, followed by not taking ir and taking ml


# Visualising the results
inspect(sort(associa_rules, by = 'lift'))
plot(associa_rules, method = "graph", 
     measure = "confidence", shading = "lift")


# ir=0 led to follow what other courses
associa_rules_ir <-  apriori(data = dataset_courses, 
                             parameter = list(support = 0.02, confidence = 0.5),
                             appearance = list(default="rhs", lhs="ir=0"), control = list (verbose=F))

rules_conf <- sort(associa_rules_ir, by="confidence", decreasing=TRUE) # 'high-confidence' rules.
inspect(head(rules_conf))
plot(associa_rules_ir, method = "graph", 
     measure = "confidence", shading = "lift")
plot(associa_rules_ir, method = "paracoord", 
     measure = "confidence", shading = "lift")
plot(associa_rules_ir)

# what other courses where followed for having ir=0
associa_rules_ir <-  apriori(data = dataset_courses, 
                             parameter = list(support = 0.2, confidence = 0.5),
                             appearance = list (rhs="ir=0"), control = list (verbose=F))

rules_conf <- sort(associa_rules_ir, by="confidence", decreasing=TRUE) # 'high-confidence' rules.
inspect(head(rules_conf))
plot(associa_rules_ir, method = "graph", 
     measure = "confidence", shading = "lift")
plot(associa_rules_ir, method = "paracoord", 
     measure = "confidence", shading = "lift")

# what other courses where followed for having stats = yes
associa_rules_ir <-  apriori(data = dataset_courses, 
                             parameter = list(support = 0.2, confidence = 0.5),
                             appearance = list (default="lhs", rhs="ml=yes"), control = list (verbose=F))

rules_conf <- sort(associa_rules_ir, by="confidence", decreasing=TRUE) # 'high-confidence' rules.
inspect(head(rules_conf))
plot(associa_rules_ir, method = "graph", 
     measure = "confidence", shading = "lift")
plot(associa_rules_ir, method = "paracoord", 
     measure = "confidence", shading = "lift")


##### stress and courses ####
dataset_courses <- data %>%
  filter(ir!="unknown", stats !="unknown", db!="unknown")  %>%
  mutate(stress_level = case_when(
    stress >= 0 & stress <=33 ~ "low",
    (stress > 33 & stress <=66) ~ "mid",
    stress > 66 & stress <=100 ~ "high",
    is.na(stress) ~ "NA",
    TRUE ~ "Other"
  ),
  IR = case_when(
    ir =="0"~"no",
    ir=="1"~"yes"),
  DB = case_when(
    db =="nee"~"no",
    db=="ja"~"yes"),
  Stat = case_when(
    stats =="sigma"~"no",
    stats=="mu"~"yes")) %>% 
  select(ML=ml,IR,DB,Stat, stress_level)

dataset_courses <- as(dataset_courses, "transactions")

# Fitting model
# Training Apriori on the dataset
associa_rules = apriori(data = dataset_courses, 
                        parameter = list(support = 0.01, confidence = 0.5),
                        appearance = list (default="lhs", rhs="stress_level=mid"), control = list (verbose=F))

itemFrequencyPlot(dataset_courses, topN = 10)
# the highest frequency is taking statistcs, followed by not taking ir and taking ml


# Visualising the results
inspect(head(sort(associa_rules, by = 'lift')))
plot(associa_rules, method = "graph", 
     measure = "confidence", shading = "lift")

# what  courses were followed for having a specific stress level
associa_rules = apriori(data = dataset_courses, 
                        parameter = list(support = 0.01, confidence = 0.5),
                        appearance = list(default="lhs", rhs=c("stress_level=low", "stress_level=mid", "stress_level=high")))

# Visualising the results
inspect(sort(associa_rules, by = 'confidence'))

plot(associa_rules, method = "graph", 
     measure = "confidence", shading = "lift")



#### Regression ####
library(VGAM)

dataset_courses <- data %>%
  filter(ir!="unknown", stats !="unknown", db!="unknown")  %>%
  mutate(stress_level = case_when(
    stress >= 0 & stress <=33 ~ "low",
    (stress > 33 & stress <=66) ~ "mid",
    stress > 66 & stress <=100 ~ "high",
    is.na(stress) ~ "NA",
    TRUE ~ "Other"
  ),
  IR = case_when(
    ir =="0"~"no",
    ir=="1"~"yes"),
  DB = case_when(
    db =="nee"~"no",
    db=="ja"~"yes"),
  Stat = case_when(
    stats =="sigma"~"no",
    stats=="mu"~"yes")) %>% 
  select(ML=ml,IR,DB,Stat, stress_level)

vglm1 <- vglm(stress_level~1, data = dataset_courses, family=cumulative(parallel=TRUE))
summary(vglm1)

# https://www.kirenz.com/post/2020-05-14-r-association-rule-mining/






