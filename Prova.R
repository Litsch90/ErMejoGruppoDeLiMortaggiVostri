#Seleziona il file di input dalla lista di file disponibili e lo ritorna
select <- function(){
  input <- tclvalue(tkgetOpenFile(title="Selezionare il file di input", filetypes = "{ {Text Files} {.csv} }"))
  if(input == ""){
    
  }
  return(input)
}

#Questa funzione è da finire
cerca <- function(specie, key){
  library('GEOquery')
  library('GEOmetadb')
  if(!file.exists('GEOmetadb.sqlite')){
    getSQLiteFile()
  }
  con <- dbConnect(SQLite(),'GEOmetadb.sqlite')
  geo_tables <- dbListTables(con)
  query <-paste("
    SELECT count(*) ",
    "FROM",
             "  gsm JOIN gse_gsm ON gsm.gsm=gse_gsm.gsm",
             "  JOIN gse ON gse_gsm.gse=gse.gse",
             "  JOIN gse_gpl ON gse_gpl.gse=gse.gse",
             "  JOIN gpl ON gse_gpl.gpl=gpl.gpl",
             "WHERE", 
            " gpl.organism LIKE '%", specie, "%' AND",
            " (gse.title LIKE '%", key, "%' OR",
            " gse.summary LIKE '%", key, "%');")
  gsm <- dbGetQuery(con, query)
  return(gsm)
  gse <- dbGetQuery(con,"SELECT DISTINCT gse FROM gse WHERE title LIKE '%human%' AND title LIKE '%breast%' AND title LIKE '%cancer%';")
}

#Crea una fiestra con tre radiobutton per selezionare una specie tra uomo, topo e ratto, poi passa il valore selezionato alla funzione cerca (default "human")
radio <- function(){
  inputBox <- tktoplevel()
  rb1 <- tkradiobutton(inputBox)
  rb2 <- tkradiobutton(inputBox)
  rb3 <- tkradiobutton(inputBox)
  rbValue <- tclVar("human")
  tkconfigure(rb1,variable=rbValue,value="human")
  tkconfigure(rb2,variable=rbValue,value="mouse")
  tkconfigure(rb3,variable=rbValue,value="rat")
  tkgrid(tklabel(inputBox,text="Which spece you want to analize?"))
  tkgrid(tklabel(inputBox,text="Human "),rb1)
  tkgrid(tklabel(inputBox,text="Mouse "),rb2)
  tkgrid(tklabel(inputBox,text="Rat "),rb3)
  
  #Una volta premuto il tasto ok dalla finestra di dialogo, invia il valore selezionato ad un'altra funzione
  onOK <- function(){
    rbVal <<- as.character(tclvalue(rbValue))
    tkdestroy(inputBox)
  }
  
  OK.but <- tkbutton(inputBox,text="OK",command=onOK)
  tkgrid(OK.but)
  tkfocus(inputBox)
}


#Qua iniziano i comandi che vengono eseguiti appena lanciato lo script
library('tcltk')
rbVal <- ""
result <- ""
output1 <- file.create(paste("Prova_", format(Sys.time(), format="%Y-%m-%d%H%M"), ".txt"))
input <- select()
inputArray <- read.table(input, sep = ",")
radio()
for (counter in inputArray){
	result <- c(result, cerca(rbVal, inputArray[counter]))
}







  


