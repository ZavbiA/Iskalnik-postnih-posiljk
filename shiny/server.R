library(shiny)
library(dplyr)
library(RPostgreSQL)
library(hash)
library(digest)
# source("../lib/libraries.R")
#library(dbplyr)

#ČE TI KDAJ NAPISE  DA SI PRESEGEL MAX POVEZAV, ZAZENI TO:
RPostgreSQL::dbDisconnect(RPostgreSQL::dbListConnections(RPostgreSQL::PostgreSQL())[[1]]) 

#source("auth.R") #skopiraj svojo auth.R datoteko v mapo shiny
#source("auth_public.R")

#Za probleme s sumniki uporabi:
original.locale <- Sys.getlocale(category="LC_CTYPE")       ## "English_Slovenia.1252" pri meni
Sys.setlocale("LC_CTYPE", "Slovenian_Slovenia.1250")     #to popravi sumnike


shinyServer(function(input, output, session) {
  # Vzpostavimo povezavo
  drv <- dbDriver("PostgreSQL") 
  conn <- dbConnect(drv, dbname = db, host = host,
                       user = user, password = password)
  userID <- reactiveVal()
  dbGetQuery(conn, "SET CLIENT_ENCODING TO 'utf8'; SET NAMES 'utf8'") #poskusim resiti tezave s sumniki
  
  cancel.onSessionEnded <- session$onSessionEnded(function() {
    dbDisconnect(conn) #ko zapremo shiny naj se povezava do baze zapre
  })
  output$signUpBOOL <- eventReactive(input$signup_btn, 1)
  outputOptions(output, 'signUpBOOL', suspendWhenHidden=FALSE)  # Da omogoca skrivanje/odkrivanje
  observeEvent(input$signup_btn, output$signUpBOOL <- eventReactive(input$signup_btn, 1))
  
  
 uporabnik <- reactive({
    user <- userID()
    validate(need(!is.null(user), "Potrebna je prijava!"))
    user
  })
  
#-------------------------------------------------------------------------------------------------
     
#Sign in protokol
observeEvent(input$signin_btn,
               {signInReturn <- sign.in.user(input$userName, input$password)
               if(signInReturn[[1]]==1){
                 userID(signInReturn[[2]])
                 
                 output$signUpBOOL <- eventReactive(input$signin_btn, 2)
                 # loggedIn(TRUE)
                 # userID <- input$userName
                 # upam da se tu userID nastavi na pravo vrednost 
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
      hashGesla <- (userTable %>% filter(uporabnisko_ime == uporabnik) %>% collect() %>% pull(geslo))[[1]]
      print(hashGesla)
      pass1 <- digest(pass, algo="md5")
      print(pass1)
      #uporabnik vpise svoje originalno geslo, sistem pa ga prevede v hash in preveri,
      #ce se ujema s tabelo
      if(pass1 == hashGesla){
        obstoj <- 1
        uporabnikID <- (userTable %>% filter(uporabnisko_ime==uporabnik) %>%
                          collect() %>% pull(uporabnisko_ime))[[1]]

      }
      if(obstoj == 0){
        success <- -10
      }else{
        uporabnikID <- (userTable %>% filter(uporabnisko_ime==uporabnik) %>%
                          collect() %>% pull(uporabnisko_ime))[[1]]
        
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
 oddane <- reactive({
    oddane_posiljke_data <- dbGetQuery(conn, build_sql("SELECT  posiljke.ID AS \"Stevilka posiljke\", posiljke.datum_oddaje AS \"Datum oddaje\",
                                                      vmesno_nahajalisce.vmesni_datum  AS \"Datum prihoda na vmesno postajo\",
                                                      vmesno_nahajalisce.vmesna_posta  AS \"Vmesna postaja\", 
                                                      koncno_nahajalisce.datum_prispe  AS \"Datum prispele posiljke na vaso destinacijo\", 
                                                      koncno_nahajalisce.posta_prispetja  AS \"Posta kjer se posiljka nahaja\"
                                                      FROM posiljke
                                                      FULL JOIN vmesno_nahajalisce ON posiljke.ID = vmesno_nahajalisce.ID
                                                      FULL JOIN koncno_nahajalisce ON posiljke.ID = koncno_nahajalisce.ID
                                                      WHERE posiljatelj =", uporabnik(),con = conn))
    # oddane_posiljke_data$`Datum prihoda na vmesno postajo` <- as.Date(as.POSIXct(oddane_posiljke_data$`Datum prihoda na vmesno postajo`))
    # oddane_posiljke_data$`Datum oddaje` <- as.Date(as.POSIXct(oddane_posiljke_data$`Datum oddaje`))
    # oddane_posiljke_data$`Datum prispele posiljke na vaso destinacijo` <- as.Date(as.POSIXct(oddane_posiljke_data$`Datum prispele posiljke na vašo destinacijo`))
    # 
    
  })
 output$oddane.posiljke <- DT :: renderDataTable({
   tabela = oddane()
   validate(need(nrow(tabela)>0, "ni podatkov"))
   DT::datatable(tabela)%>%DT::formatDate(c('Datum oddaje', 'Datum prihoda na vmesno postajo', 'Datum prispele posiljke na vaso destinacijo'), method = "toLocaleDateString") %>% DT::formatStyle(columns = c('Stevilka posiljke','Datum oddaje','Datum prihoda na vmesno postajo', 'Vmesna postaja', 'Datum prispele posiljke na vaso destinacijo','Posta kjer se posiljka nahaja'), color = 'black')
   
   
   })

  
## prejete posiljke 
prejete<- reactive({
    prejete.posiljke_data <- dbGetQuery(conn, build_sql("SELECT  posiljke.ID AS \"Stevilka posiljke\", posiljke.datum_oddaje AS \"Datum oddaje\",
                                                      vmesno_nahajalisce.vmesni_datum  AS \"Datum prihoda na vmesno postajo\",
                                                      vmesno_nahajalisce.vmesna_posta  AS \"Vmesna postaja\", 
                                                      koncno_nahajalisce.datum_prispe  AS \"Datum prispele posiljke na vaso destinacijo\", 
                                                      koncno_nahajalisce.posta_prispetja  AS \"Posta kjer se posiljka nahaja\"
                                                      FROM posiljke
                                                      FULL JOIN vmesno_nahajalisce ON posiljke.ID = vmesno_nahajalisce.ID
                                                      FULL JOIN koncno_nahajalisce ON posiljke.ID = koncno_nahajalisce.ID
                                                      WHERE naslovnik =", uporabnik(),con = conn))
    # prejete.posiljke_data$`Datum prihoda na vmesno postajo` <- as.Date(as.POSIXct(prejete.posiljke_data$`Datum prihoda na vmesno postajo`))
    # prejete.posiljke_data$`Datum oddaje` <- as.Date(as.POSIXct(prejete.posiljke_data$`Datum oddaje`))
    # prejete.posiljke_data$`Datum prispele posiljke na vaso destinacijo` <- as.Date(as.POSIXct(prejete.posiljke_data$`Datum prispele posiljke na vaso destinacijo`))
    # 

    })
  output$prejete.posiljke <- DT :: renderDataTable({
    tabela = prejete()
    validate(need(nrow(tabela)>0, "ni podatkov"))
    DT::datatable(tabela)%>%DT::formatDate(c( 'Datum oddaje', 'Datum prihoda na vmesno postajo', 'Datum prispele posiljke na vaso destinacijo'), method = "toLocaleDateString") %>% DT::formatStyle(columns = c('Stevilka posiljke', 'Datum oddaje','Datum prihoda na vmesno postajo', 'Vmesna postaja', 'Datum prispele posiljke na vaso destinacijo','Posta kjer se posiljka nahaja'), color = 'black')
    
 
  
  })
  
  
  # komentar
  observeEvent(input$poslji,{
    ideja <- renderText({input$sporocilo})
    sql2 <- build_sql("INSERT INTO sporocilo (uporabnisko_ime,besedilo,cas)
                      VALUES(",uporabnik(),",", input$sporocilo,",", "NOW())", con = conn)  
    data2 <- dbGetQuery(conn, sql2)
    data2
    shinyjs::reset("sporocilo_") 
  })

    
  
najdi.komentar <- reactive({
    input$poslji
    sql_komentar <- build_sql("SELECT uporabnisko_ime AS \"Uporabnik\", besedilo AS \"Sporocilo\", cas AS \"Cas\" FROM sporocilo
                            WHERE uporabnisko_ime =",uporabnik(), con = conn)
    komentarji <- dbGetQuery(conn, sql_komentar)
    validate(need(nrow(komentarji) > 0, "Niste poslali še nubenega sporočila"))
    # validate(need( nrow(komentarji) == 0, "Spodaj so vaša že poslana sporočila" ))
    
    komentarji
  })
    
# output$sporocilo_<- DT::renderDataTable( DT::datatable(najdi.komentar()) %>%DT::formatDate("Cas", method="toLocaleString"))%>%DT::formatStyle(columns = c('Uporabnik', 'Sporocilo','Cas'), color = 'black')
output$sporocilo_<- DT::renderDataTable( DT::datatable(najdi.komentar()) %>% DT::formatDate("Cas", method="toLocaleString") %>% DT::formatStyle(columns = c('Uporabnik', 'Sporocilo','Cas'), color = 'black') )
  

})
#-------------------------------------------------------------------------------------------------
  
 #ne zbriši

