#La funzione myFunction fa da main allo script
myFunction <- function(){
  library('tcltk')
  input <- tclvalue(tkgetOpenFile(filetypes = "{ {Text Files} {.txt} }"))
  stopifnot(input != "")
}

myFunction()


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


