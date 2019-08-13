
source("server.R")
source("../lib/libraries.R")

vpisniPanel <- tabPanel("SignIn", value="signIn",
                        fluidPage(
                          HTML('<body background = "https://raw.githubusercontent.com/ZavbiA/Iskalnik-postnih-posiljk/master/slike/digital-mail-2-1.jpg"></body>'),
                          fluidRow(
                            column(width = 12,
                                   align = "center",
                                   textInput("userName","User name", value= "", placeholder = "User name"),
                                   passwordInput("password","Password", value = "", placeholder = "Password"),
                                   actionButton("signin_btn", "Sign In")
                            )
                            
                            
                          )))


ui <- fluidPage(
  theme = shinytheme("cyborg"),

  titlePanel("Pošta FMF"),
  
  sidebarLayout(
    sidebarPanel(

      menuItem("Pomoč uporabnikom",tabName = "pomoc", icon = icon("sporociloo")) ,
      menuItem("Navodila",tabName = "navodila", icon = icon("navodila")),
      menuItem("Poštna statistika",tabName = "statistika", icon = icon("stat"))
    ),

    mainPanel(
     
      conditionalPanel(condition = "output.signUpBOOL!='1' && output.signUpBOOL!='2'",#&& false", 
                       vpisniPanel),
      conditionalPanel(condition = "output.signUpBOOL=='2'",
                        titlePanel("Pregled vaših pošiljk"),
                        tabsetPanel(
                         tabPanel("Poslane pošiljke", DT::dataTableOutput("oddane.posiljke")), 
                         tabPanel("Prejete pošiljke", DT::dataTableOutput("prejete.posiljke")),
                         tabPanel("Pomoč uporabnikom", 
                                  textInput("sporocilo", "Poslji sporocilo", placeholder = "Sporocilo"),
                                  actionButton(inputId ="poslji", label = "Pošlji"),
                                  DT::dataTableOutput("sporocilo_")
                                  )
                                  # verbatimTextOutput("value")),
                                  
                                  # DT::dataTableOutput("sporocilo_")
                         )
                       
                       )
      # tabPanel(tabName = "pomoc", h2("Pusti sporoči") )
                         
               
                       
                       
      )
    )
  )
 


  




