data <- read.csv2("/Users/caterina/Desktop/Data Mining/Assignment/DataMining/basic_assignment/assignment_1_task1/data/final/data_clean.csv", sep=",")
attach(data)
summary(data)

pie(table(program), labels = names(program))
pie(table(ml), labels = names(ml))
pie(table(ir), labels = names(ir))
pie(table(stats), labels = names(stats))
pie(table(db), labels = names(db))
pie(table(gender), labels = names(gender))
hist(table(chocolate), labels = names(chocolate))
hist(stress)

boxplot(stress~gender)
boxplot(stress~ml)
boxplot(stress~ir)
boxplot(stress~db)
boxplot(stress~chocolate)

boxplot(rn~gender)
boxplot(rn~ml)
boxplot(rn~ir)
boxplot(rn~db)
boxplot(rn~chocolate)

plot(gain[gain<101], stress[gain<101])

hist(bed_time)
