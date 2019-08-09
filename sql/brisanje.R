# Neposredno klicanje SQL ukazov v R
library(dplyr)
library(dbplyr)
library(RPostgreSQL)
source("libraries.r")
source("auth.R")
source("uvoz.r", encoding="UTF-8")

# Povezemo se z gonilnikom za PostgreSQL
drv <- dbDriver("PostgreSQL")

# Uporabimo tryCatch,
# da prisilimo prekinitev povezave v primeru napake
tryCatch({
  # Vzpostavimo povezavo
  conn <- dbConnect(drv, dbname = db, host = host,
                    user = user, password = password)
  
  # Poizvedbo zgradimo s funkcijo build_sql
  # in izvedemo s funkcijo dbGetQuery
  dbSendQuery(conn, build_sql("DROP TABLE sporocilo CASCADE", con = conn))
  dbSendQuery(conn, build_sql("DROP TABLE poste CASCADE", con = conn))
  dbSendQuery(conn, build_sql("DROP TABLE posiljke CASCADE", con = conn))
  dbSendQuery(conn, build_sql("DROP TABLE vmesno_nahajalisce CASCADE", con = conn))
  dbSendQuery(conn, build_sql("DROP TABLE osebe CASCADE", con = conn))
  dbSendQuery(conn, build_sql("DROP TABLE koncno_nahajalisce CASCADE", con = conn))

  #CASCADE zato da zbrise tabelo tudi ce je odvisna od ene druge
  # Rezultat dobimo kot razpredelnico (data frame)
}, finally = {
  conn <- dbConnect(drv, dbname = db, host = host,
                    user = user, password = password)
  # Na koncu nujno prekinemo povezavo z bazo,
  # saj preveč odprtih povezav ne smemo imeti
  dbDisconnect(conn)
  # Koda v finally bloku se izvede v vsakem primeru
  # - bodisi ob koncu izvajanja try bloka,
  # ali pa po tem, ko se ta konca z napako
})
