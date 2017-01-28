#La funzione myFunction fa da main allo script
myFunction <- function(inputFile, organism, outputFile){
  controls(inputFile, organism, outputFile)
}

#La funzione controls controlla che gli input dati dall'utente siano corretti
controls <- function(control1, control2, control3){ 
  errs <- 'Errore: '
  counter <- 0
  if(!file.exists(control1) || tools::file_ext(control1) != 'txt'){
    errs <- paste(errs, 'il file ', control1, 'non esiste o non è di tipo .txt')
    counter <- 1
  }
  if(is.null(control2) || control2 != "Uomo" && control2 != "Topo" && control2 != "Ratto"){
    errs <- paste(errs, control2, " è un input invalido, scegliere un organismo tra Uomo, Topo o Ratto")
    counter <- 1
  }
  if(counter == 1){
    stop(errs)
  }
}


  library('GEOquery')
  library('GEOmetadb')
  if(!file.exists('GEOmetadb.sqlite')){
    getSQLiteFile()
  }
  con <- dbConnect(SQLite(),'GEOmetadb.sqlite')
  geo_tables <- dbListTables(con)
  gsm <- dbGetQuery(con,"SELECT DISTINCT gsm FROM gsm WHERE title LIKE '%human%' AND title LIKE '%breast%' AND title LIKE '%cancer%';")
  numGSM <-nrow(gsm)
  gse <- dbGetQuery(con,"SELECT DISTINCT gse FROM gse WHERE title LIKE '%human%' AND title LIKE '%breast%' AND title LIKE '%cancer%';")


