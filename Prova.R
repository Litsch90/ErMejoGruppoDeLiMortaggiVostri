#Seleziona il file di input dalla lista di file disponibili
select <- function(){
  tkmessageBox(message="Select the input file")
  input <- tclvalue(tkgetOpenFile(filetypes = "{ {Text Files} {.txt} }"))
  stopifnot(input != "")
  return(input)
}

#Crea una radiobuttons con le razze da selezionare
radio <- function(){
  tt <- tktoplevel()
  rb1 <- tkradiobutton(tt)
  rb2 <- tkradiobutton(tt)
  rb3 <- tkradiobutton(tt)
  rbValue <- ""
  tkconfigure(rb1,variable=rbValue,value="human")
  tkconfigure(rb2,variable=rbValue,value="mouse")
  tkconfigure(rb3,variable=rbValue,value="rat")
  tkgrid(tklabel(tt,text="Which spece you want to analize?"))
  tkgrid(tklabel(tt,text="Human "),rb1)
  tkgrid(tklabel(tt,text="Mouse "),rb2)
  tkgrid(tklabel(tt,text="Rat "),rb3)
  
  onOK <- function(){
    rbVal <- as.character(tclvalue(rbValue))
    tkdestroy(tt)
    cerca(rbVal)
  }
  
  OK.but <- tkbutton(tt,text="OK",command=onOK)
  tkgrid(OK.but)
  tkfocus(tt)
}

#Questa funzione è da finire
cerca <- function(specie){
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
}

#Qua iniziano i comandi che vengono eseguiti appena lanciato lo script
library('tcltk')
input <- select()
radio()



  


