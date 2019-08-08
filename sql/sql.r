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
                                              telefonska text NOT NULL
                                             )", con = conn))
    
    dbSendQuery(conn, build_sql("CREATE TABLE poste (
                                            postna_stevilka INTEGER PRIMARY KEY,
                                            naziv_poste text NOT NULL)", con = conn))
    
    dbSendQuery(conn, build_sql("CREATE TABLE posiljke (
                                               ID INTEGER PRIMARY KEY,
                                               teza INTEGER NOT NULL,
                                               datum_oddaje DATE NOT NULL,
                                              posiljatelj text REFERENCES osebe(uporabnisko_ime),
                                              naslovnik text REFERENCES osebe(uporabnisko_ime))", con = conn))
    
    
    dbSendQuery(conn, build_sql("CREATE TABLE vmesno_nahajalisce (
                                                        ID INTEGER PRIMARY KEY,
                                                        vmesni_datum DATE NOT NULL,
                                                        vmesna_posta INTEGER REFERENCES poste(postna_stevilka))", con = conn))
    
    dbSendQuery(conn, build_sql("CREATE TABLE koncno_nahajalisce (
                                ID INTEGER PRIMARY KEY,
                                datum_prispe DATE NOT NULL,
                                posta_prispetja INTEGER REFERENCES poste(postna_stevilka))", con = conn))
    
    
    dbSendQuery(conn, build_sql("CREATE TABLE sporocilo (
                              id SERIAL PRIMARY KEY,
                              uporabnisko_ime text REFERENCES osebe(uporabnisko_ime),
                              besedilo text,
                              cas TIMESTAMP )", con = conn))
    
    
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
    
    dbSendQuery(conn, build_sql("GRANT CONNECT ON DATABASE sem2019_spelao TO anjazk WITH GRANT OPTION", con = conn))
    dbSendQuery(conn, build_sql("GRANT CONNECT ON DATABASE sem2019_spelao TO ajdas WITH GRANT OPTION", con = conn))
    
    dbSendQuery(conn, build_sql("GRANT ALL ON SCHEMA public TO anjazk WITH GRANT OPTION", con= conn))
    dbSendQuery(conn, build_sql("GRANT ALL ON SCHEMA public TO ajdas WITH GRANT OPTION", con= conn))
    
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL TABLES IN SCHEMA public TO anjazk WITH GRANT OPTION",con= conn))
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL TABLES IN SCHEMA public TO ajdas WITH GRANT OPTION",con= conn))
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL TABLES IN SCHEMA public TO spelao WITH GRANT OPTION",con= conn))
    
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anjazk WITH GRANT OPTION",con= conn))
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO ajdas WITH GRANT OPTION",con= conn))
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO spelao WITH GRANT OPTION",con= conn))
    
    dbSendQuery(conn, build_sql("GRANT CONNECT ON DATABASE sem2019_spelao TO javnost",con= conn))
    dbSendQuery(conn, build_sql("GRANT SELECT ON ALL TABLES IN SCHEMA public TO javnost",con= conn))
    
    
    
  }, finally = {
    # Na koncu nujno prekinemo povezavo z bazo,
    # saj prevec odprtih povezav ne smemo imeti
    dbDisconnect(conn) #PREKINEMO POVEZAVO
    # Koda v finally bloku se izvede, preden program konca z napako
  })
}

pravice()
