# Neposredno klicanje SQL ukazov v R
library(dplyr)
library(dbplyr)
library(RPostgreSQL)

source("auth.R")
source("uvoz.r", encoding="UTF-8")

# Povezemo se z gonilnikom za PostgreSQL
drv <- dbDriver("PostgreSQL")
vstavljanje.osebe <- function(){

  # Uporabimo tryCatch,
  # da prisilimo prekinitev povezave v primeru napake
  tryCatch({
    # Vzpostavimo povezavo
    conn <- dbConnect(drv, dbname = db, host = host,
                      user = user, password = password)

    # Poizvedbo zgradimo s funkcijo build_sql
    # in izvedemo s funkcijo dbGetQuery


    for (i in 1:nrow(osebe)) {
      v <- osebe[i,]
      dbSendQuery(conn, build_sql("INSERT INTO osebe (uporabnisko_ime, ime, priimek, email, geslo, telefonska, prebivalisce)
                                  VALUES (", v[["uporabnisko_ime"]], ", ",
                                  v[["ime"]], ", ", v[["priimek"]],", ",
                                  v[["email"]], ", ", v[["geslo"]], ", ",
                                  v[["prebivalisce"]], ", ",
                                  v[["telefonska"]], ")",con = conn))
     }

    # Rezultat dobimo kot razpredelnico (data frame)
  }, finally = {
    # Na koncu nujno prekinemo povezavo z bazo,
    # saj preveč odprtih povezav ne smemo imeti
    dbDisconnect(conn)
    # Koda v finally bloku se izvede v vsakem primeru
    # - bodisi ob koncu izvajanja try bloka,
    # ali pa po tem, ko se ta konca z napako
  })
}
oseba_ <- vstavljanje.oseba()


vstavljanje.posiljke <- function(){

  # Uporabimo tryCatch,
  # da prisilimo prekinitev povezave v primeru napake
  tryCatch({
    # Vzpostavimo povezavo
    conn <- dbConnect(drv, dbname = db, host = host,
                      user = user, password = password)

    # Poizvedbo zgradimo s funkcijo build_sql
    # in izvedemo s funkcijo dbGetQuery

    for (i in 1:nrow(posiljke)){
      v <- posiljke[i, ]
      dbSendQuery(conn, build_sql("INSERT INTO posiljke (ID,teza, datum_oddaje, posiljatelj, naslovnik)
                                  VALUES ( ", v[["ID"]], ", ",
                                  v[["teza"]], ", ",
                                  as.Date(v[["datum_oddaje"]], format="%m/%d/%Y"),", ",
                                 # v[["datum_oddaje"]],", ",
                                  # as.Date( v[["datum_prispe"]],format="%m/%d/%Y"), ", ",
                                  # v[["datum_oddaje"]], ", ",
                                  v[["posiljatelj"]], ", ",
                                  v[["naslovnik"]], ")"))

    }
   #  YYYY-MM-DD
   #  "%Y-%m-%d"
   # as.Date("4/15/2018",format="%m/%d/%Y")
   #
   # s<- as.Date("4/15/2018")
    # CONVERT(varchar, getdate(), 23)
    # # Rezultat dobimo kot razpredelnico (data frame)
  }, finally = {
    # Na koncu nujno prekinemo povezavo z bazo,
    # saj preveč odprtih povezav ne smemo imeti
    dbDisconnect(conn)
    # Koda v finally bloku se izvede v vsakem primeru
    # - bodisi ob koncu izvajanja try bloka,
    # ali pa po tem, ko se ta konča z napako
  })
}
posiljke_ <- vstavljanje.posiljke()


vstavljanje.poste <- function(){

  tryCatch({
    # Vzpostavimo povezavo
    conn <- dbConnect(drv, dbname = db, host = host,
                      user = user, password = password)

    # Poizvedbo zgradimo s funkcijo build_sql
    # in izvedemo s funkcijo dbGetQuery



    for (i in 1:nrow(poste)){
      v <- poste[i, ]
      dbSendQuery(conn, build_sql("INSERT INTO poste (postna_stevilka, naziv_poste)
                                    VALUES (",v[["postna_stevilka"]], ", ",
                                              v[["naziv_poste"]], ")"))

    }
    # Rezultat dobimo kot razpredelnico (data frame)
  }, finally = {
    # Na koncu nujno prekinemo povezavo z bazo,
    # saj preveč odprtih povezav ne smemo imeti
    dbDisconnect(conn)
    # Koda v finally bloku se izvede v vsakem primeru
    # - bodisi ob koncu izvajanja try bloka,
    # ali pa po tem, ko se ta konča z napako
  })
}
poste_ <- vstavljanje.poste()

vstavljanje.vmesno_nahajalisce <- function(){

  # Uporabimo tryCatch,
  # da prisilimo prekinitev povezave v primeru napake
  tryCatch({
    # Vzpostavimo povezavo
    conn <- dbConnect(drv, dbname = db, host = host,
                      user = user, password = password)

    # Poizvedbo zgradimo s funkcijo build_sql
    # in izvedemo s funkcijo dbGetQuery

    for (i in 1:nrow(vmesno_nahajalisce)){
      v <- vmesno_nahajalisce[i, ]
      dbSendQuery(conn, build_sql("INSERT INTO vmesno_nahajalisce (id_posiljke, vmesni_datum, vmesna_posta)
                                    VALUES (", v[["ID"]], ", ",as.Date(v[["vmesni_datum"]], format="%m/%d/%Y"), ", ",v[["vmesna_posta"]], ")"))

    }
    # Rezultat dobimo kot razpredelnico (data frame)
  }, finally = {
    # Na koncu nujno prekinemo povezavo z bazo,
    # saj preveč odprtih povezav ne smemo imeti
    dbDisconnect(conn)
    # Koda v finally bloku se izvede v vsakem primeru
    # - bodisi ob koncu izvajanja try bloka,
    # ali pa po tem, ko se ta konča z napako
  })
}
vmesno_nahajalisce_ <- vstavljanje.vmesno_nahajalisce

vstavljanje.koncno_nahajalisce <- function(){

  # Uporabimo tryCatch,
  # da prisilimo prekinitev povezave v primeru napake
  tryCatch({
    # Vzpostavimo povezavo
    conn <- dbConnect(drv, dbname = db, host = host,
                      user = user, password = password)

    # Poizvedbo zgradimo s funkcijo build_sql
    # in izvedemo s funkcijo dbGetQuery

    for (i in 1:nrow(koncno_nahajalisce)){
      v <- koncno_nahajalisce[i, ]
      dbSendQuery(conn, build_sql("INSERT INTO koncno_nahajalisce (id_posiljke, datum_prispe, posta_prispetja)
                                  VALUES (", v[["id_posiljke"]], ",
                                  ",v[["datum_prispe"]], ",
                                  ",v[["posta_prispetja"]], ")",con = conn))

    }
    # Rezultat dobimo kot razpredelnico (data frame)
  }, finally = {
    # Na koncu nujno prekinemo povezavo z bazo,
    # saj preveč odprtih povezav ne smemo imeti
    dbDisconnect(conn)
    # Koda v finally bloku se izvede v vsakem primeru
    # - bodisi ob koncu izvajanja try bloka,
    # ali pa po tem, ko se ta konča z napako
  })
  }
koncno_nahajalisce_ <- vstavljanje.koncno_nahajalisce
