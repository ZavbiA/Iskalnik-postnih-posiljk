library(shiny)
library(dplyr)
#library(dbplyr)
library(RPostgreSQL)
library(hash)
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
  userID <- reactiveVal() 
  dbGetQuery(conn, "SET CLIENT_ENCODING TO 'utf8'; SET NAMES 'utf8'") #poskusim resiti rezave s sumniki
  
  cancel.onSessionEnded <- session$onSessionEnded(function() {
    dbDisconnect(conn) #ko zapremo shiny naj se povezava do baze zapre
  })
  output$signUpBOOL <- eventReactive(input$signup_btn, 1)
  outputOptions(output, 'signUpBOOL', suspendWhenHidden=FALSE)  # Da omogoca skrivanje/odkrivanje
  observeEvent(input$signup_btn, output$signUpBOOL <- eventReactive(input$signup_btn, 1))
  
  
  
  
  
#-------------------------------------------------------------------------------------------------
     
#Sign in protokol
observeEvent(input$signin_btn,
               {signInReturn <- sign.in.user(input$userName, input$password)
               if(signInReturn[[1]]==1){
                 userID(signInReturn[[2]])
                 output$signUpBOOL <- eventReactive(input$signin_btn, 2)
                 loggedIn(TRUE)
                 # userID <- input$userName
                 # upam da se tu userID nastavi na pravo vrednosst 
               }else if(signInReturn[[1]]==0){
                 showModal(modalDialog(
                   title = "Error during sign in",
                   paste0("An error seems to have occured. Please try again."),
                   easyClose = TRUE,
                   footer = NULL
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

  
  
  
  
  
  
  
  
  # sign in funkcija
  sign.in.user <- function(username, pass){
    # Return a list. In the first place is an indicator of success:
    # 1 ... success
    # 0 ... error
    # -10 ... wrong username
    # The second place represents the userid if the login info is correct,
    # otherwise it's NULL
    success <- 0
    uporabnikID <- NULL
    tryCatch({
      drv <- dbDriver("PostgreSQL")
      conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
      userTable <- tbl(conn, "osebe")
      obstoj <- 0
      # obstoj = 0, ce username in geslo ne obstajata,  1 ce obstaja
      uporabnik <- username
      geslo <- pass
      hashGesla <- (userTable %>% filter(uporabnisko_ime == uporabnik) %>% collect() %>% pull(hash))[[1]]
      if(checkpw(geslo, hashGesla)){

        obstoj <- 1
      }
      if(obstoj == 0){
        success <- -10
      }else{
        uporabnikID <- (userTable %>% filter(uporabnisko_ime == uporabnik) %>%
                          collect() %>% pull(id))[[1]]
        success <- 1
      }
    },warning = function(w){
      print(w)
    },error = function(e){
      print(e)
    }, finally = {
      dbDisconnect(conn)
      return(list(success, uporabnikID))
    })
  }

  
  #  iz baze bomo uvozili vse mozne posiljke za uporabnika
  
  # uvoz_posiljk <- function(username){
  #   q_datum_oddaje_posiljatelj <- dbGetQuery("SELECT datum_oddaje FROM posiljke WHERE posiljatelj =", username,con = conn)
  #   q_datum_prispe_posiljatelj <- dbGetQuery("SELECT datum_oddaje FROM posiljke WHERE naslovnik =", username,con = conn)
  # 
  # 
  #   
  # }
  # observe ({
  #   updateTextInput(session,"posiljke","Posiljke",
  #                     choices = uvoz_posiljk
  #   )
  #   
  # })
  
  
## oddane posiljke
  # output$oddane.posiljke <- renderUI({
  #   oddane_posiljke = dbGetQuery(conn, build_sql("SELECT id_posiljke, datum_oddaje, datum_prispe FROM posiljke WHERE posiljatelj =" userID + " ORDER BY datum_oddaje", con = conn))
  #   selectInput("oddane",
  #               label = "Oddane posiljke:",
  #               choices = setNames(oddane_posiljke$id_posiljke, oddane_posiljke$datum_oddaje,oddane_posiljke$datum_prispe)
  #   )
  # })
  # 
  # 
  # output$prejete.posiljke <- renderUI({
  #   oddane.posiljke = dbGetQuery(conn, build_sql("SELECT id_posiljke, datum_oddaje, datum_prispe FROM posiljke WHERE naslovnik ="+ userID + " ORDER BY datum_oddaje", con = conn))
  #   
  # })
  
  
  # komentar
  observeEvent(input$poslji,{
    ideja <- renderText({input$sporocilo})
    sql2 <- build_sql("INSERT INTO komentar (uporabnisko_ime,besedilo,datum)
                      VALUES(",userID,",", input$sporocilo,",", ",NOW())", con = conn)  
    data2 <- dbGetQuery(conn, sql2)
    data2
    shinyjs::reset("komentiranje") # reset po vpisu komentarja
  })

    
  
  # najdi.komentar <- reactive({
  #   input$poslji
  #   validate(need(!is.null(input$vojna), "Izberi vojno!"))
  #   sql_komentar <- build_sql("SELECT ime AS \"Uporabnik\", besedilo AS \"Komentar\", cas AS \"Cas\" FROM komentar
  #                           WHERE vojna_id =",input$vojna, con = conn)
  #   komentarji <- dbGetQuery(conn, sql_komentar)
  #   validate(need(nrow(komentarji) > 0, "Ni komentarjev."))
  #   komentarji
    
  
  # output$komentiranje <- DT::renderDataTable(DT::datatable(najdi.komentar()) %>%
                                               # DT::formatDate("Cas", method="toLocaleString"))
  
  

  
#-------------------------------------------------------------------------------------------------
  

  
  
 }) #ne zbriši

