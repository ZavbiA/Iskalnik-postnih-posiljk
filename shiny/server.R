library(shiny)
library(dplyr)
library(dbplyr)
library(RPostgreSQL)
#library(dbplyr)

#ČE TI KDAJ NAPIŠE  DA SI PRESEGEL MAX POVEZAV, ZAŽENI TO:
#RPostgreSQL::dbDisconnect(RPostgreSQL::dbListConnections(RPostgreSQL::PostgreSQL())[[1]]) 

source("auth_public.R")

#Za probleme s sumniki uporabi:
original.locale <- Sys.getlocale(category="LC_CTYPE")       ## "English_Slovenia.1252" pri meni
Sys.setlocale("LC_CTYPE", "Slovenian_Slovenia.1250")     #to popravi sumnike


shinyServer(function(input, output,session) {
  # Vzpostavimo povezavo
  drv <- dbDriver("PostgreSQL") 
  conn <- dbConnect(drv, dbname = db, host = host,
                       user = user, password = password)
  dbGetQuery(conn, "SET CLIENT_ENCODING TO 'utf8'; SET NAMES 'utf8'") #poskusim resiti rezave s sumniki
  
  cancel.onSessionEnded <- session$onSessionEnded(function() {
    dbDisconnect(conn) #ko zapremo shiny naj se povezava do baze zapre
  })
  
  
#-------------------------------------------------------------------------------------------------
      
#ZAVIHEK POSTA
  
  output$izborPoste <- renderUI({
    
    izbira_poste=dbGetQuery(conn, build_sql("SELECT posiljatelj FROM posiljke"))
    Encoding(izbira_poste[,1])="UTF-8" #vsakic posebej je potrebno character stolpce spremeniti v pravi encoding.
  
    selectInput("posiljatelj",
                            label = "Izberite posto:",
                            choices = izbira_poste,
                            selected = "129912621" #bo vsaj tti pošiljatttelj izbran
                )
  })


  
  
  

  
#-------------------------------------------------------------------------------------------------
  

  
  
}) #ne zbriši

