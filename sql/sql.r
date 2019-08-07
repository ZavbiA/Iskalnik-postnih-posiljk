#Neposredno klicanje SQL ukazov v R.
library(RPostgreSQL)
library(dplyr)
library(dbplyr)

source("auth.R", encoding="UTF-8")
source("uvoz.R", encoding="UTF-8")

# Povezemo se z gonilnikom za PostgreSQL
drv <- dbDriver("PostgreSQL") 

tryCatch({
    # Vzpostavimo povezavo
    conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
    
    # Glavne tabele
    dbSendQuery(conn, build_sql("CREATE TABLE osebe (
                                              uporabnisko_ime text PRIMARY KEY,
                                              ime text NOT NULL,
                                              priimek text NOT NULL,
                                              email text NOT NULL,
                                              geslo text NOT NULL,
                                              telefonska text NOT NULL)"))
    
    dbSendQuery(conn, build_sql("CREATE TABLE poste (
                                            postna_stevilka INTEGER PRIMARY KEY,
                                            naziv_poste text NOT NULL)"))
    
    dbSendQuery(conn, build_sql("CREATE TABLE posiljke (
                                               id_posiljke INTEGER PRIMARY KEY,
                                               teza INTEGER NOT NULL,
                                               datum_oddaje DATE NOT NULL,
                                              datum_prispe DATE,
                                              naslovnik text REFERENCES osebe(uporabnisko_ime),
                                              posiljatelj text REFERENCES osebe(uporabnisko_ime))"))
    
    
    
    dbSendQuery(conn, build_sql("CREATE TABLE vmesno_nahajalisce (
                                                        id_posiljke INTEGER PRIMARY KEY,
                                                        vmesni_datum DATE NOT NULL,
                                                        vmesni_kraj INTEGER REFERENCES poste(postna_stevilka))"))
    
    dbSendQuery(conn, build_sql("CREATE TABLE sporocilo (
                              id SERIAL PRIMARY KEY,
                              uporabnisko_ime INTEGER,
                              besedilo text,
                              cas TIMESTAMP )"))
    
    
},
  finally = {
    # Na koncu nujno prekinemo povezavo z bazo,
    # saj prevec odprtih povezav ne smemo imeti
    dbDisconnect(conn) #PREKINEMO POVEZAVO
    # Koda v finally bloku se izvede, preden program konca z napako
})

pravice <- function(){
  # Uporabimo tryCatch,(da se povezemo in bazo in odvezemo)
  # da prisilimo prekinitev povezave v primeru napake
  tryCatch({
    # Vzpostavimo povezavo
    conn <- dbConnect(drv, dbname = db, host = host,
                      user = user, password = password)
    
    dbSendQuery(conn, build_sql("GRANT CONNECT ON DATABASE sem2019_spelao TO anjazk WITH GRANT OPTION"))
    dbSendQuery(conn, build_sql("GRANT CONNECT ON DATABASE sem2019_spelao TO ajdas WITH GRANT OPTION"))
    
    dbSendQuery(conn, build_sql("GRANT ALL ON SCHEMA public TO anjazk WITH GRANT OPTION"))
    dbSendQuery(conn, build_sql("GRANT ALL ON SCHEMA public TO ajdas WITH GRANT OPTION"))
    
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL TABLES IN SCHEMA public TO anjazk WITH GRANT OPTION"))
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL TABLES IN SCHEMA public TO ajdas WITH GRANT OPTION"))
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL TABLES IN SCHEMA public TO spelao WITH GRANT OPTION"))
    
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anjazk WITH GRANT OPTION"))
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO ajdas WITH GRANT OPTION"))
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO spelao WITH GRANT OPTION"))
    
    dbSendQuery(conn, build_sql("GRANT CONNECT ON DATABASE sem2019_spelao TO javnost"))
    dbSendQuery(conn, build_sql("GRANT SELECT ON ALL TABLES IN SCHEMA public TO javnost"))
    
    
    
  }, finally = {
    # Na koncu nujno prekinemo povezavo z bazo,
    # saj prevec odprtih povezav ne smemo imeti
    dbDisconnect(conn) #PREKINEMO POVEZAVO
    # Koda v finally bloku se izvede, preden program konca z napako
  })
}

pravice()
