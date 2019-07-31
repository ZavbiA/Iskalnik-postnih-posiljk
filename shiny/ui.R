
source("server.R")
source("../lib/libraries.r")

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

iskalnikPosiljk <-
  tabItems(
    tabItem(
      tabName = "oddane",
      fluidRow(sidebarPanel(
        # uiOutput(oddane.posiljke)
      ))
    ),
    tabItem(
      tabName = "prejete",
      fluidRow(sidebarPanel(
        # uiOutput(prejete.posiljke)
      ))
      
    ),
    tabItem(
      tabName = "sporocilo",
      fluidRow(
        sidebarPanel(
          textInput("sporocilo", "Poslji sporocilo", placeholder = "Sporocilo"),
          actionButton(inputId ="poslji", label = "Pošlji"),
          verbatimTextOutput("value")),
        mainPanel(p("V primeru tezav, pustite sporočilo skupaj z imenom in priimkom ter številko poštne številke."),
                  DT::dataTableOutput("komentiranje")
          
                     )
        
      )
      
    )
    
  )


ui <- fluidPage(
  theme = shinytheme("cyborg"),

  titlePanel("Pošta FMF"),
  
  sidebarLayout(
    sidebarPanel(
      
      menuItem("Pomoč uporabnikom",tabName = "pomoc"),
      menuItem("Navodila",tabName = "navodila")
    ),
    
    mainPanel(
     
      conditionalPanel(condition = "output.signUpBOOL!='1' && output.signUpBOOL!='2'",#&& false", 
                       vpisniPanel)
       ,
      conditionalPanel(condition = "output.signUpBOOL=='2'",
                        titlePanel("Pregled vaših pošiljk"),
                       tabsetPanel(
                         tabPanel("Poslane pošiljke", tableOutput("oddane.posiljke")), 
                         tabPanel("Prejete pošiljke", tableOutput("prejete.posiljke")) 
                         
                       
      #                  # ,
      #                  # iskalnikPosiljk
      #                  
                       
                       
      )
    )
  )
 )
)
  
  
  
#   dashboardPage(
#     dashboardHeader(title="Pošta FMF"),
#     dashboardSidebar(
#       menuItem("Pomoč uporabnikom",tabName = "pomoc"),
#       menuItem("Navodila",tabName = "navodila")
#       ),
#     dashboardBody(
#     conditionalPanel(condition = "output.signUpBOOL!='1' && output.signUpBOOL!='2'",#&& false", 
#                      vpisniPanel),
#     conditionalPanel(condition = "output.signUpBOOL=='2'",
#                     dashboardPage(
#                     dashboardHeader(title =  "Pregled vasih posiljk")),
#                     dashboardSidebar(
#                       menuItem("Pomoč uporabnikom",tabName = "pomoc"),
#                       menuItem("Navodila",tabName = "navodila")
#                       
#                     ),
#                     dashboardBody(iskalnikPosiljk)
# 
#     
#       
#     )
# 
#     )
# )
# )
#   
# 
# 
# 
# 
# 





 

# body<-mainPanel(
#   tabItems(
#     tabItem(tabName = "Sledenje posiljke",
#             fluidRow(sidebarPanel(
#               uiOutput("")
#             )))
#     ,
#     tabItem(tabName = "Pomoc uporabnikom")
#            
# )
# )
# 
#   
# fluidPage(useShinyjs(),
#           conditionalPanel(condition = "output.signInBOOL!='0' && output.signInBOOL!='-10'",#&& false", 
#                            vpisniPanel),       # UI panel za vpis
#           conditionalPanel(condition = "output.signUpBOOL=='1'",
#                            # Panel, ko je bila uspesna registracija
#                            titlePnael("Sledenje pošiljke"),
#                            sidebarLayout(
#                              sidebarPanel(
#                                actionButton("pomoc", "Pomoc Uporabnikom"),
#                                width = 4
#                                
#                              )),
#                            mainPanel()
#                            
#                            ),
#           theme="bootstrap.css"
# )
# 
#   

  # mainPanel(
  #   tabsetPanel(
  #     tabPanel("Iskanje po postah",
  # 
  #            sidebarPanel(
  #               uiOutput("izborPoste")
  #              ),
  #             mainPanel(tableOutput("posiljke")) #iz kere tabele vn pobira
  #     )
  # )
  # )



