library(readxl)
library(dplyr)

#Najprej uvozimo seznam post.
poste <- read.csv2(file = "seznam_1.csv")
#odstranimo nekaj ponavljajocih se post (Lj, Mb, Kp), da lahko uporabimo vektorske funkcije
poste <- poste[-c(201:240),]
poste <- poste[-c(273:282),]
poste <- poste[-c(159:161),]
colnames(poste) <- c("postna_st", "naziv_poste")

#Nato uvozimo tabelo osebe
osebe <- read.csv('osebe.csv')

#Treba je pretvoriti stolpca uporabnisko_ime in telefonska v numeric.

osebe$prebivalisce <- sample(poste$posta) #Premesamo stolpec posta

#Zgeneriramo se tabelo posiljke, 10 000 podatkov.
posiljke <- read.csv('posiljkee.csv')

#k tabeli posiljke smo dodali posiljatelja in naslovnika, od koder lahko tudi razberemo
#vstopno in izstopno mesto posiljke
posiljke$posiljatelj <- osebe$uporabnisko_ime
posiljke$naslovnik <- sample(osebe$uporabnisko_ime) #spet premesamo stolpec

#stolpec datum, datum_postaja in datum_prispe moramo pretvorit v date?

#kjer je vmesni datum 0, damo tudi da tudi vmesni kraj 0,
#saj je posiljka sla direktno od posiljatelja k naslovniku, ni se vmes ustavljala
posiljke$vmesni_kraj <- sample(poste$postna_st)

#Naredimo se tabelo za vmesno nahajalisce.
vmesno_nahajalisce <- posiljke
vmesno_nahajalisce <- vmesno_nahajalisce[,-c(2,3,5,6,7)]

#Zdaj lahko izbrisemo vmesno postajo iz tabele posiljke.
posiljke <- posiljke[,-c(4,8)]
