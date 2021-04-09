# dplyr cheat sheet
library(tidyverse)
library(lubridate)

opi_tmp <- read.csv2("/Users/caterina/Desktop/Data Mining/Assignment/DataMining/basic_assignment/assignment_1_task1/data/ODI-2021.csv", sep=",")
head(opi_tmp)

y <- opi_tmp %>% 
  mutate(date = dmy(`When is your birthday (date)?`)) %>% 
  select(`When is your birthday (date)?`, date)



# cleaning of the birthday data
# all the dates that don't have the year are set as null
# format of the date: "dd-mm-yyyy"
bd <- opi_tmp[,9]
first <- dmy(bd)
print(first)
print(bd)
dd <- as.data.frame(c(first, bd))
print(dd)
write.table(first, "/Users/caterina/Desktop/Data Mining/Assignment/DataMining/basic_assignment/assignment_1_task1/data/date.txt")


date <- read.table("/Users/caterina/Desktop/Data Mining/Assignment/DataMining/basic_assignment/assignment_1_task1/data/date.txt")
print(date)

bed_time <- opi_tmp[,15]
print(bed_time)
bed <- hm(bed_time)
#write.table(bed, "/Users/caterina/Desktop/Data Mining/Assignment/DataMining/basic_assignment/assignment_1_task1/data/bed_time.txt")


bed_time_correct <- read.table("/Users/caterina/Desktop/Data Mining/Assignment/DataMining/basic_assignment/assignment_1_task1/data/bed_time.txt", fill = TRUE)
data <- read_csv2("/Users/caterina/Desktop/Data Mining/Assignment/DataMining/basic_assignment/assignment_1_task1/data/bed_time.txt")
print(bed_time_correct)

# check random number between 1-10
rn <- as.integer(opi_tmp[,14])
for (i in 1:length(rn)){
  if (rn[i]>=1 && rn[i]<= 10 || is.na(rn[i])) {rn[i]=rn[i]}
  else rn[i] = NA
}
print(rn)

# check 100 euros
write.table(opi_tmp[,13], "/Users/caterina/Desktop/Data Mining/Assignment/DataMining/basic_assignment/assignment_1_task1/data/gain.txt")
gain <- read.table("/Users/caterina/Desktop/Data Mining/Assignment/DataMining/basic_assignment/assignment_1_task1/data/gain.txt")
options(digits=3)
gain_c <- round(as.double(unlist(gain)), digits=3)
print(gain_c)

for (i in 1:length(gain)){
  if (is.na(gain[i])) {gain[i]=gain[i]}
  else gain[i] = as.double(gain[i])
}
print(gain)


# check stress
stress <- as.integer(opi_tmp[,12])
for (i in 1:length(stress)){
  if (stress[i]>=0 && stress[i]<= 100 || is.na(stress[i])) {stress[i]=stress[i]}
  else stress[i] = NA
}
print(stress)
summary(stress)

# check neighbours
write.table(opi_tmp[,10], "/Users/caterina/Desktop/Data Mining/Assignment/DataMining/basic_assignment/assignment_1_task1/data/neigh.txt")
neigh <- read.table("/Users/caterina/Desktop/Data Mining/Assignment/DataMining/basic_assignment/assignment_1_task1/data/neigh.txt")
print(neigh)

beddd <-bed_time_correct %>% 
  unite(bed_time, c("V2", "V3", "V4"), sep = " ")%>% 
  filter(V1!="x")

new_data <- as.data.frame(c(opi_tmp[1:313,1:8], birthday = date, neighbors = neigh, stand = list(opi_tmp[,11]), 
                            stress = list(stress), gain = list(gain_c), rn = list(rn), bed_time = list(beddd$bed_time),  opi_tmp[,16:17]))
dim(new_data)
head(new_data)
col.names = c("Timestamp", "prgramme", "ML_course",
              "IR_course", "stat_course", "DB_course",
              "gender", "chocolate", "birthday", "neighbors",
              "stand_up", "stress", "gain", "rn", "bed_time",
              "good_1", "good_2")
X <- c(opi_tmp[,1:8], date, neigh, opi_tmp[,11], 
  stress, gain_c, rn, beddd$bed_time, opi_tmp[,16:17])
new_data <- as.data.frame(X)

write.csv2(new_data, "/Users/caterina/Desktop/Data Mining/Assignment/DataMining/basic_assignment/assignment_1_task1/data/data_fin.csv")
summary(new_data)






