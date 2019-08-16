
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
      menuItem("Navodila",tabName = "navodila", selected = TRUE),
      menuItem("Poslane posiljke", tabName = "poslane", selected = FALSE),
      menuItem("Prejete posiljke", tabName = "prejete", selected = FALSE),
      menuItem("Pomoč uporabnikom" ,tabName = "pomoc", selected = FALSE) ,
      menuItem("Poštna statistika",tabName = "statistika", icon = icon("stat"))
    ),

    mainPanel(
     
      conditionalPanel(condition = "output.signUpBOOL!='1' && output.signUpBOOL!='2'",#&& false", 
                       vpisniPanel),
      conditionalPanel(condition = "output.signUpBOOL=='2'",
                        titlePanel("Pregled vaših pošiljk"),
                        tabItems(
                          tabItem(tabName= "navodila",
                                  helpText("V levem meniju izberite, če želite videti svoje poslane pošiljke oziroma vaše prejete pošiljke. Če želite pustiti pošti FMF sporočilo, izberite pomoč in tam pustite sporočilo.")),
                         tabItem(tabName = "poslane", 
                                 mainPanel(DT::dataTableOutput("oddane.posiljke"))), 
                         tabItem(tabName= "prejete",
                                 mainPanel(DT::dataTableOutput("prejete.posiljke"))),
                         tabItem(tabName = "pomoc",
                                 mainPanel(
                                  textInput("sporocilo", "Poslji sporocilo", placeholder = "Sporocilo"),
                                  actionButton(inputId ="poslji", label = "Pošlji"),
                                  DT::dataTableOutput("sporocilo_")
                                  )
                         ),
                         tabItem(tabName = "statistika",
                                 h2("Stevilo posiljk na posamezni posti"),
                                 selectInput("postna_stevilka", label ="Izberite postno stevilko",
                                             choices = sort(unique(poste$postna_stevilka))),
                                 mainPanel(plotOutput("stevilo_posiljk")
                                 ) )
                         
                                  # verbatimTextOutput("value")),
                                  
                                  # DT::dataTableOutput("sporocilo_")
                         )
                       
                       )
      # tabPanel(tabName = "pomoc", h2("Pusti sporoči") )
                         
               
                       
                       
      )
    )
  )
 


  




