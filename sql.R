# Neposredno klicanje SQL ukazov v R
library(dplyr)
library(dbplyr)
library(RPostgreSQL)

source("auth.R")

# Povezemo se z gonilnikom za PostgreSQL
drv <- dbDriver("PostgreSQL")

# Uporabimo tryCatch,
# da prisilimo prekinitev povezave v primeru napake
tryCatch({
  # Vzpostavimo povezavo
  conn <- dbConnect(drv, dbname = db, host = host,
                    user = user, password = password)
})  
  # Poizvedbo zgradimo s funkcijo build_sql
  # in izvedemo s funkcijo dbGetQuery
#   znesek <- 1000
#   t <- dbGetQuery(conn, build_sql("SELECT * FROM transakcija
#                                   WHERE znesek >", znesek, "
#                                   ORDER BY znesek, id", con=conn))
#   # Rezultat dobimo kot razpredelnico (data frame)
#   
#   # Vstavimo se eno transakcijo
#   i <- round(runif(1, 1, nrow(t)))
#   print("Storniramo transkacijo:")
#   print(t[i,])
#   znesek <- -t[i, "znesek"]
#   racun <- t[i, "racun"]
#   opis <- paste("Storno:", t[i, "opis"])
#   
#   # Pošljemo poizvedbo
#   dbSendQuery(conn, build_sql("INSERT INTO transakcija (znesek, racun, opis)
#                               VALUES (", znesek, ", ", racun, ", ", opis, ")", con=conn))
# }, finally = {
#   # Na koncu nujno prekinemo povezavo z bazo,
#   # saj prevec odprtih povezav ne smemo imeti
#   dbDisconnect(conn)
#   # Koda v finally bloku se izvede v vsakem primeru
#   # - bodisi ob koncu izvajanja try bloka,
#   # ali pa po tem, ko se ta konca z napako
# })