library(readxl)
library(dplyr)
library(readr)
library(digest)

#Najprej uvozimo seznam post.
poste <- read.csv2(file = "seznam_1.csv")
#odstranimo nekaj ponavljajocih se post (Lj, Mb, Kp), da lahko uporabimo vektorske funkcije
poste <- poste[-c(201:240),]
poste <- poste[-c(273:282),]
poste <- poste[-c(159:161),]
colnames(poste) <- c("postna_stevilka", "naziv_poste")

#Nato uvozimo tabelo osebe
osebe <- read.csv('osebe.csv')
#Pretvorimo stolpca uporabnisko_ime in telefonska v tip numeric:
osebe$uporabnisko_ime <- gsub("-", "", osebe$uporabnisko_ime) %>% parse_number()
# osebe$uporabnisko_ime <- toString(osebe$uporabnisko_ime)
osebe$telefonska <- gsub("-", "", osebe$telefonska) %>% parse_number()

#Stolpec geslo spremenimo, da to niso vec prava gesla, ampak hash.
osebe$geslo <- sapply(osebe$geslo, digest, algo="md5")

#Dodamo in premesamo stolpec prebivalisce.
osebe$prebivalisce <- sample(poste$naziv_poste)
#Ta vrstica nekaj naredi, da to ni vec tabela?
is.table(osebe)

#Zgeneriramo se tabelo posiljke, 10 000 podatkov.
posiljke <- read.csv('posiljkee.csv')

#Stolpca datum_postaja in datum_prispe pretvorimo v tip date:
posiljke$datum_oddaje <- as.character(posiljke$datum_oddaje)
posiljke$datum_prispe <- as.character(posiljke$datum_prispe)
posiljke$vmesna_postaja <- as.character(posiljke$vmesna_postaja)
posiljke$datum_oddaje <- parse_date(posiljke$datum_oddaje, format = "%m/%d/%Y")
posiljke$datum_prispe <- parse_datetime(posiljke$datum_prispe, format = "%m/%d/%Y %I:%M %p")
posiljke$vmesna_postaja <- parse_datetime(posiljke$vmesna_postaja, format = "%m/%d/%Y %I:%M %p")

#K tabeli posiljke smo dodale posiljatelja in naslovnika, od koder lahko tudi
#razberemo vstopno in izstopno mesto posiljke.
posiljke$posiljatelj <- osebe$uporabnisko_ime
posiljke$naslovnik <- sample(osebe$uporabnisko_ime) #spet premesamo stolpec

#Kjer je vmesni datum 0, damo tudi da tudi vmesni kraj 0,
#saj je posiljka sla direktno od posiljatelja k naslovniku, ni se vmes ustavljala
posiljke$vmesni_kraj <- sample(poste$postna_stevilka)

#Naredimo se tabelo za vmesno nahajalisce.
vmesno_nahajalisce <- posiljke
vmesno_nahajalisce <- vmesno_nahajalisce[,-c(2,3,5,6,7)]
#zbrišemo vrstice, kjer pišiljka nima vmesnega nahajališča
vmesno_nahajalisce <- vmesno_nahajalisce[-c(1:1500),]
names(vmesno_nahajalisce) <- c('ID','vmesni_datum','vmesna_posta')

#Zdaj lahko izbrisemo vmesno postajo iz tabele posiljke.
posiljke <- posiljke[,-c(4,8)]

#Naredimo novo tabelo koncno_nahajalisce
koncno_nahajalisce <- posiljke
koncno_nahajalisce<-koncno_nahajalisce[,-c(2,3,5)]
koncno_nahajalisce<-koncno_nahajalisce[-c(1:4000),]
#namesto naslovnika želimo imeti napisano prebivališče
koncno_nahajalisce$kraj_prispetja = osebe$prebivalisce[match(koncno_nahajalisce$naslovnik,osebe$uporabnisko_ime)]
#namesto prebivališča želimo meti napisano poštno steviko, kamor posiljka prispe
koncno_nahajalisce$posta_prispetja = poste$postna_stevilka[match(koncno_nahajalisce$kraj_prispetja,poste$naziv_poste)]
koncno_nahajalisce<-koncno_nahajalisce[,-c(3,4)]

#zbrisemo datum prispe iz tabele posiljke, ker je v drugi tabeli koncno nahajalisce
posiljke <- posiljke[,-c(4)]
