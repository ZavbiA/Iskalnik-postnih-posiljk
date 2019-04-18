require(readxl)
library(dplyr)


#Uvoz
obcine <- read_excel("Seznam.xls")
obcine <- obcine[-c(1,2),-c(1,4)]
names(obcine) <- c('postna_st', 'posta')
