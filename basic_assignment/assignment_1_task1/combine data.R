# combine data

# load packages
library(tidyverse)
library(rstudioapi)
library(lubridate)

# set working directory
setwd(dirname(getActiveDocumentContext()$path))
# load the cat data
cat_data <- read_delim("data/data_fin.csv", delim = ";")
program_data <- read_csv("data/cleaned_programs.csv")

# join data

data <- cat_data %>% 
  left_join(program_data, by = c("X1" = "id")) %>% 
  select(-X1, -What.programme.are.you.in.)

data_rename <- data %>% 
  rename(ml = Have.you.taken.a.course.on.machine.learning.,
         ir = Have.you.taken.a.course.on.information.retrieval.,
         stats = Have.you.taken.a.course.on.statistics.,
         db = Have.you.taken.a.course.on.databases.,
         gender = What.is.your.gender.,
         chocolate = Chocolate.makes.you.....,
         birthday = birthday.x,
         neighbors = neighbors.x,
         good_day_1 = What.makes.a.good.day.for.you..1..,
         good_day_2 = What.makes.a.good.day.for.you..2..,
         program = clean_program) %>% 
  relocate(program)