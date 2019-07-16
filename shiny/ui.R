library(shiny)


shinyUI(fluidPage( 
                  
  
  titlePanel("Brskalnik po postah"),

  mainPanel(
    tabsetPanel(
      tabPanel("Iskanje po postah",

             sidebarPanel(
                uiOutput("izborPoste")
               ),
              mainPanel(tableOutput("posiljke")) #iz kere tabele vn pobira
      )
  )
  )

))


