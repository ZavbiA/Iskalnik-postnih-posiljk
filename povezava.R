library(RPostgreSQL)
library(dplyr)
library(dbplyr)

#Uvoz:
source("auth.R", encoding="UTF-8")
#source("auth_public.R", encoding="UTF-8")
source("uvoz.r", encoding="UTF-8")

# Povezemo se z gonilnikom za PostgreSQL
drv <- dbDriver("PostgreSQL") 

# Funkcija za brisanje tabel
# Funkcija za brisanje tabel
delete_table <- function(){
  # Uporabimo funkcijo tryCatch,
  # da prisilimo prekinitev povezave v primeru napake
  tryCatch({
    # Vzpostavimo povezavo z bazo
    conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
    
    # Èe tabela obstaja, jo zbrišemo, ter najprej zbrišemo tiste,
    # ki se navezujejo na druge
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS oseba CASCADE"))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS posta CASCADE"))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS posiljka  CASCADE"))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS nahajalisce CASCADE"))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS posiljatelj  CASCADE"))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS naslovnik CASCADE"))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS nahajalisce CASCADE"))
  }, finally = {
    dbDisconnect(conn)
  })
}


#Funkcija, ki ustvari tabele
create_table <- function(){
  # Uporabimo tryCatch (da se poveÅ¾emo in bazo in odveÅ¾emo)
  # da prisilimo prekinitev povezave v primeru napake
  tryCatch({
    # Vzpostavimo povezavo
    conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
    
    # Glavne tabele
    oseba <- dbSendQuery(conn, build_sql("CREATE TABLE oseba (
                                              emso INTEGER PRIMARY KEY,
                                              ime text NOT NULL,
                                               priimek text NOT NULL,
                                               tel_st INTEGER NOT NULL,
                                               email text NOT NULL,
                                             naslov text NOT NULL,
                                         odda INTEGER NOT NULL)"))
    
   posta <- dbSendQuery(conn, build_sql("CREATE TABLE posta(
                                         postna_stevilka INTEGER REFERENCES oseba(odda),
                                          kraj text NOT NULL)"))

   posiljka <- dbSendQuery(conn, build_sql("CREATE TABLE posiljka(
                                         id_posiljke INTEGER PRIMARY KEY,
                                         teza INTEGER NOT NULL,
                                         odkupnina INTEGER NOT NULL,
                                         datum_oddaje DATE NOT NULL,
                                        naslovnik INTEGER REFERENCES oseba(emso)),
                                           posiljatelj INTEGER REFERENCES oseba(emso)"))
                           


     nahajalisce <- dbSendQuery(conn, build_sql("CREATE TABLE nahajalisce(
                                         id_posiljke INTEGER REFERENCES posiljka(id_posiljke),
                                        datum DATE references posiljka(datum_oddaje )"))


    dbSendQuery(conn, build_sql("GRANT ALL ON ALL TABLES IN SCHEMA public TO ajdas WITH GRANT OPTION"))
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL TABLES IN SCHEMA public TO  anjazk WITH GRANT OPTION"))
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL TABLES IN SCHEMA public TO spelao WITH GRANT OPTION"))

    dbSendQuery(conn, build_sql("GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO ajdas WITH GRANT OPTION"))
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anjazk WITH GRANT OPTION"))
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO spelao WITH GRANT OPTION"))

    dbSendQuery(conn, build_sql("GRANT CONNECT ON DATABASE sem2018_ajdas TO javnost"))
    dbSendQuery(conn, build_sql("GRANT SELECT ON ALL TABLES IN SCHEMA public TO javnost"))

  },
finally = {
    # Na koncu nujno prekinemo povezavo z bazo,
    # saj preveÄ odprtih povezav ne smemo imeti
    dbDisconnect(conn) #PREKINEMO POVEZAVO
    # Koda v finally bloku se izvede, preden program konÄa z napako
  })
}
insert_data <- function(){
  tryCatch({
    conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
    
    dbWriteTable(conn, name="oseba", osebe, append=T, row.names=FALSE)
    dbWriteTable(conn, name="posiljka", posiljkee, append=T, row.names=FALSE)
  
  }, finally = {
    dbDisconnect(conn) 
    
  })
}


pravice <- function(){
  # Uporabimo tryCatch,(da se povežemo in bazo in odvežemo)
  # da prisilimo prekinitev povezave v primeru napake
  tryCatch({
    # Vzpostavimo povezavo
    conn <- dbConnect(drv, dbname = db, host = host,#drv=s èim se povezujemo
                      user = user, password = password)
    
    dbSendQuery(conn, build_sql("GRANT CONNECT ON DATABASE sem2018_ajdas TO anjazk WITH GRANT OPTION"))
    dbSendQuery(conn, build_sql("GRANT CONNECT ON DATABASE sem2018_ajdas TO spelao WITH GRANT OPTION"))
    
    dbSendQuery(conn, build_sql("GRANT ALL ON SCHEMA public TO anjazk WITH GRANT OPTION"))
    dbSendQuery(conn, build_sql("GRANT ALL ON SCHEMA public TO spelao WITH GRANT OPTION"))
    
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL TABLES IN SCHEMA public TO anjazk WITH GRANT OPTION"))
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL TABLES IN SCHEMA public TO ajdas WITH GRANT OPTION"))
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL TABLES IN SCHEMA public TO spelao WITH GRANT OPTION"))
    
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anjazk WITH GRANT OPTION"))
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO ajdas WITH GRANT OPTION"))
    dbSendQuery(conn, build_sql("GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO spelao WITH GRANT OPTION"))
    
    dbSendQuery(conn, build_sql("GRANT CONNECT ON DATABASE sem2018_ajdas TO javnost"))
    dbSendQuery(conn, build_sql("GRANT SELECT ON ALL TABLES IN SCHEMA public TO javnost"))
    
    
    
  }, finally = {
    # Na koncu nujno prekinemo povezavo z bazo,
    # saj preveè odprtih povezav ne smemo imeti
    dbDisconnect(conn) #PREKINEMO POVEZAVO
    # Koda v finally bloku se izvede, preden program konèa z napako
  })
}

pravice()
delete_table()
create_table()
insert_data()