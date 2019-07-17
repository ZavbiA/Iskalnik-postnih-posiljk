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
delete_table <- function(){
  # Uporabimo funkcijo tryCatch,
  # da prisilimo prekinitev povezave v primeru napake
  tryCatch({
    # Vzpostavimo povezavo z bazo
    conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
    
    # Ce tabela obstaja, jo zbrisemo, ter najprej zbrisemo tiste,
    # ki se navezujejo na druge
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS oseba CASCADE"))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS posta CASCADE"))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS posiljka CASCADE"))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS nahajalisce CASCADE"))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS posiljatelj CASCADE"))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS naslovnik CASCADE"))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS nahajalisce CASCADE"))
  }, finally = {
    dbDisconnect(conn)
  })
}


#Funkcija, ki ustvari tabele
create_table <- function(){
  # Uporabimo tryCatch (da se povezemo in bazo in odvezemo)
  # da prisilimo prekinitev povezave v primeru napake
  tryCatch({
    # Vzpostavimo povezavo
    conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
    
    # Glavne tabele
    osebe <- dbSendQuery(conn, build_sql("CREATE TABLE osebe (
                                              uporabnisko_ime INTEGER PRIMARY KEY,
                                              ime text NOT NULL,
                                               priimek text NOT NULL,
                                               tel_st INTEGER NOT NULL,
                                               email text NOT NULL,
                                             naslov text NOT NULL,
                                         odda INTEGER NOT NULL)"))
    
   poste <- dbSendQuery(conn, build_sql("CREATE TABLE poste(
                                         postna_stevilka INTEGER REFERENCES oseba(odda),
                                          kraj text NOT NULL)"))

   posiljke <- dbSendQuery(conn, build_sql("CREATE TABLE posiljke(
                                         id_posiljke INTEGER PRIMARY KEY,
                                         teza INTEGER NOT NULL,
                                         odkupnina INTEGER NOT NULL,
                                         datum_oddaje DATE NOT NULL,
                                        naslovnik INTEGER REFERENCES oseba(emso)),
                                           posiljatelj INTEGER REFERENCES oseba(emso)"))
                           


     # vmesno_nahajalisce <- dbSendQuery(conn, build_sql("CREATE TABLE vmesno_nahajalisce(
     # 
     #                                                   vmesni_kraj INTEGER REFERENCES posta(emso)
     #                                                   vmesna_postaja 
     # )")
     
                                         

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
    # saj prevec odprtih povezav ne smemo imeti
    dbDisconnect(conn) #PREKINEMO POVEZAVO
    # Koda v finally bloku se izvede, preden program konca z napako
  })
}
insert_data <- function(){
  tryCatch({
    conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
    
    dbWriteTable(conn, name="osebe", osebe, append=T, row.names=FALSE)
    dbWriteTable(conn, name="posiljke", posiljke, append=T, row.names=FALSE)
  
  }, finally = {
    dbDisconnect(conn) 
    
  })
}


pravice <- function(){
  # Uporabimo tryCatch,(da se povezemo in bazo in odvezemo)
  # da prisilimo prekinitev povezave v primeru napake
  tryCatch({
    # Vzpostavimo povezavo
    conn <- dbConnect(drv, dbname = db, host = host,#drv=s cim se povezujemo
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

#pravice()
#delete_table()
#create_table()
#insert_data()
