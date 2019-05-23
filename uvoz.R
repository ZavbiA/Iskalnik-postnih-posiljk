
library(readxl)
#library(dplyr)


#Uvoz NA MOJEM KOMPU NI DEDALO read_excel PA SM ZATO V csv SPREMENILA SPODAJ
#obcine <- read_excel("Seznam.xls")
#obcine <- obcine[-c(1,2),-c(1,4)]
#names(obcine) <- c('postna_st', 'posta')

poste <- read.csv2('seznam 2.csv')
poste <- poste[-c(1,2),-c(1,4)]
names(poste) <- c('postna_st', 'posta')

#odstranimo nekaj ponavljajočih se post (Lj, Mb, Kp), d alahko uporabimo vekotrske funkcije
poste <- poste[-c(201:240),]
poste <- poste[-c(273:282),]
poste <- poste[-c(159:161),]

osebe <- read.csv('osebe.csv')
osebe$prebivalisce <- sample(poste$posta)

#prva baza, samo 1000 podatkov -premalo
#posiljka <- read.csv('posiljka.csv')

#novo zgenerirana baza, 10 000 podatkov - boljše
posiljke <- read.csv('posiljkee.csv')

#k tabeli posiljke smo dodali posiljatelja in naslovnika, od koder lahko tudi razberemo
#vstopno in izstopno mesto posiljke
posiljke$posiljatelj <- osebe$uporabnisko_ime
posiljke$naslovnik <- sample(osebe$uporabnisko_ime)

#kjer je vmesni datum 0, damo tudi da tudi vmesni kraj 0,
#saj je pošiljka šla direktno od posiljatelja k naslovniku, ni se vmes ustavljala
posiljke$vmesni_kraj <- sample(poste$postna_st) 
