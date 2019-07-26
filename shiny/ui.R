library(shiny)
library(shinydashboard)
source("server.R")


library(shiny)
library(shinydashboard)


vpisniPanel <- tabPanel("SignIn", value="signIn",
                        fluidPage(
                          HTML('<body background = "https://raw.githubusercontent.com/ZavbiA/Iskalnik-postnih-posiljk/master/slike/digital-mail-2-1.jpg"></body>'),
                          fluidRow(
                            column(width = 12,
                                   align = "middle",
                                   textInput("userName","User name", value= "", placeholder = "User name"),
                                   passwordInput("password","Password", value = "", placeholder = "Password"),
                                   actionButton("signin_btn", "Sign In")
                            )
                            
                            
                          )))



shinyUI(
  dashboardPage(
    dashboardHeader(title="Pošta FMF"),
    dashboardSidebar(
      menuItem("Pomoč uporabnikom",tabName = "pomoc"),
      menuItem("Navodila",tabName = "navodila")),
    dashboardBody(vpisniPanel),
    conditionalPanel(condition = "output.signUpBOOL=='1'",
                     # Panel, ko je bila uspesna registracija
                     titlePanel("Sledenje pošiljke"))
                       

    )
  )










 

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



