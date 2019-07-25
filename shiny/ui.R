library(shiny)


shinyUI(fluidPage( 
                  
  vpisniPanel <- tabPanel("SignIn", value="signIn",
                          fluidPage(
                            HTML('<body background = "https://raw.githubusercontent.com/ZavbiA/Iskalnik-postnih-posiljk/master/slike/digital-mail-2-1.jpg"></body>'),
                            fluidRow(
                              column(width = 12,
                                     align = "center",
                                     textInput("userName","User name", value= "", placeholder = "User name"),
                                     passwordInput("password","Password", value = "", placeholder = "Password"),
                                     actionButton("signin_btn", "Sign In"),
                                     actionButton("signup_btn", "Sign Up"))
                    
                              
                            ))),
  
  
registracijaPanel <- tabPanel("SignUp", value = "signUp",
                                fluidPage(
                                  fluidRow(
                                    column(width = 12,
                                           align="center",
                                           textInput("SignUpUserName","* Username", value= "", placeholder = "Only Latin characters."),
                                           passwordInput("SignUpPassword","* Password", value= "", placeholder = "Only Latin characters."),
                                           actionButton("signup_btnBack", "Back"),
                                           actionButton("signup_btnSignUp", "Sign Up")
                                    )
                                  )
                                )
  )
  


  

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

)
)


