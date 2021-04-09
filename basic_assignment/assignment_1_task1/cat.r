library(tidyverse)
data <- read.csv2("/Users/caterina/Desktop/Data Mining/Assignment/DataMining/basic_assignment/assignment_1_task1/data/final/data_clean.csv", sep=",")
attach(data)
summary(data)

# univariate EDA
pie(table(program), labels = names(program))
pie(table(ml), labels = names(ml))
pie(table(ir), labels = names(ir))
pie(table(stats), labels = names(stats))
pie(table(db), labels = names(db))
pie(table(gender), labels = names(gender))
hist(table(chocolate), labels = names(chocolate))
hist(stress)

# bivariate EDA
boxplot(stress~gender)
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
  select(ml,ir,db,stats)
dataset_courses <- as(dataset_courses, "transactions")

# Fitting model
# Training Apriori on the dataset
set.seed = 220 # Setting seed
associa_rules = apriori(data = dataset_courses, 
                        parameter = list(support = 0.01, 
                                         confidence = 0.5))

# support --> how frequently the itemset appears in the dataset 
# confidence --> how often the rule has been found to be true

# Plot
itemFrequencyPlot(dataset_courses, topN = 10)
# the highest frequency is taking statistcs, followed by not taking ir and taking ml


# Visualising the results
inspect(sort(associa_rules, by = 'lift')[1:10])
plot(associa_rules, method = "graph", 
     measure = "confidence", shading = "lift")


# what led to have not followed an ir course
associa_rules_ir <-  apriori(data = dataset_courses, 
                             parameter = list(support = 0.01, confidence = 0.5),
                             appearance = list (rhs="ir=0"), control = list (verbose=F))

rules_conf <- sort(associa_rules_ir, by="confidence", decreasing=TRUE) # 'high-confidence' rules.
inspect(head(rules_conf))
plot(associa_rules_ir, method = "graph", 
     measure = "confidence", shading = "lift")
plot(associa_rules_ir, method = "paracoord", 
     measure = "confidence", shading = "lift")

# what not following an ir course lead to
associa_rules_ir <-  apriori(data = dataset_courses, 
                             parameter = list(support = 0.01, confidence = 0.5),
                             appearance = list (lhs="ml=yes",rhs="ir=0"), control = list (verbose=F))

rules_conf <- sort(associa_rules_ir, by="confidence", decreasing=TRUE) # 'high-confidence' rules.
inspect(head(rules_conf))
plot(associa_rules_ir, method = "graph", 
     measure = "confidence", shading = "lift")
plot(associa_rules_ir, method = "paracoord", 
     measure = "confidence", shading = "lift")





