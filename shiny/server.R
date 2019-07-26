library(shiny)
library(dplyr)
#library(dbplyr)
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
      
#Sign in 
  
observeEvent(input$signin_btn,
               {signInReturn <- sign.in.user(input$userName, input$password)
               if(signInReturn ==1){
                 # userID(signInReturn[[2]])
                 output$signUpBOOL <- eventReactive(input$signin_btn, 2)
                 loggedIn(TRUE)
               }else if(signInReturn[[1]]==0){
                 showModal(modalDialog(
                   title = "Error during sign in",
                   paste0("Error occured. Please try again."),
                   easyClose = TRUE,
                   footer = TRUE
                 ))
               }else{
                 showModal(modalDialog(
                   title = "Wrong Username/Password",
                   paste0("Username or/and password incorrect"),
                   easyClose = TRUE,
                   footer = NULL
                 ))
               }
               })
  
# Sign in function
# preveri_sign.in<- function(username, pass){
#   success <- 0
#   
# }

  
  
# geslo dobimo iz funkcije probi.upor.ime.geslo- če se ujema s pass je OK - pravilno geslo, drugače pa ni Ok,
  # dodati moramo še funkcijo ki preveri če sploh obstaja tako uporabniško ime
sign.in.user <- function(username, pass){
  obstoj <- 0
  geslo <- probi.upor.ime.geslo(username,pass)
  if (geslo == pass){
    obstoj <-1
  }
  returnValue(obstoj)
}

    # Return a list. In the first place is an indicator of success:
    # 1 ... success
    # 0 ... error
    # -10 ... wrong username
    # The second place represents the userid if the login info is correct,
    # otherwise it's NULL
  #   success <- 0
  #   uporabnikID <- NULL
  #   tryCatch({
  #     drv <- dbDriver("PostgreSQL")
  #     conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
  #     userTable <- tbl(conn, "uporabnik")
  #     obstoj <- 0
  #     # obstoj = 0, ce username in geslo ne obstajata,  1 ce obstaja
  #     uporabnik <- username
  #     geslo <- pass
  #     hashGesla <- (userTable %>% filter(username == uporabnik) %>% collect() %>% pull(hash))[[1]]
  #     if(checkpw(geslo, hashGesla)){
  #       obstoj <- 1
  #     }
  #     if(obstoj == 0){
  #       success <- -10
  #     }else{
  #       uporabnikID <- (userTable %>% filter(username == uporabnik) %>%
  #                         collect() %>% pull(id))[[1]]
  #       success <- 1
  #     }
  #   },warning = function(w){
  #     print(w)
  #   },error = function(e){
  #     print(e)
  #   }, finally = {
  #     dbDisconnect(conn)
  #     return(list(success, uporabnikID))
  #   })
  # }
  # 
  # pridobi.ime.uporabnika <- function(userID){
  #   # Pridobi ime vpisanega glede na userID
  #   tryCatch({
  #     drv <- dbDriver("PostgreSQL")
  #     conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
  #     sqlInput<- build_sql("SELECT uporabnisko_ime FROM osebe WHERE id=",userID, con = conn)
  #     userid <- dbGetQuery(conn, sqlInput)
  #   },finally = {
  #     dbDisconnect(conn)
  #     return(unname(unlist(userid)))
  #   }
  #   )
  # }
#   
# // ta funkcija dobi geslo glede na uporabnisko ime
  probi.upor.ime.geslo <- function(userName, password){
    tryCatch({
      drv <- dbDriver("PostgreSQL")
      conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
      sqlInput<- build_sql("SELECT geslo FROM osebe WHERE uporabnisko_ime=",userName, con = conn)
      user_pass <- dbGetQuery(conn, sqlInput)
      
    },finally = {
      dbDisconnect(conn)
      # ta funkcija spodaj unlist user_pass ne dela... rade bi dobile samo vrednosti
      return(unname(unlist(user_pass)))
    }
    )
    
  }
  
  

  
  
  
  
  # Login/logout button in header
  # observeEvent(input$dashboardLogin, {
  #   if(loggedIn()){
  #     output$signUpBOOL <- eventReactive(input$signin_btn, 0)
  #     userID <- reactiveVal()
  #   }
  #   loggedIn(ifelse(loggedIn(), FALSE, TRUE))
  # })
  # 
  # output$logintext <- renderText({
  #   if(loggedIn()) return("Logout here.")
  #   return("Login here")
  # })
  # 
  # output$dashboardLoggedUser <- renderText({
  #   if(loggedIn()) return(paste("Welcome,", pridobi.ime.uporabnika(userID())))
  #   return("")
  # })
  # 
  
  
  # output$izborPoste <- renderUI({
  #   
  #   izbira_poste=dbGetQuery(conn, build_sql("SELECT posiljatelj FROM posiljke"))
  #   Encoding(izbira_poste[,1])="UTF-8" #vsakic posebej je potrebno character stolpce spremeniti v pravi encoding.
  # 
  #   selectInput("posiljatelj",
  #                           label = "Izberite posto:",
  #                           choices = izbira_poste,
  #                           selected = "129912621" #bo vsaj tti pošiljatttelj izbran
  #               )
  # })


  
  
  

  
#-------------------------------------------------------------------------------------------------
  

  
  
}) #ne zbriši

