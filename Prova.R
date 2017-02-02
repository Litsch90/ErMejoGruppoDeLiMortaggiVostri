Prova <- function(outName){
  
  #Seleziona il file di input dalla lista di file disponibili e lo ritorna
  select <- function(){
    write("created 'select' variable (function).",file = logFile,sep="",append = TRUE)
    input <- tclvalue(tkgetOpenFile(title="Selezionare il file di input", filetypes = "{ {Text Files} {.txt} }"))
    write("created 'input' variable internal to the 'select' function.",file = logFile,sep="",append = TRUE)
    if(input == ""){
      
    }
    return(input)
  }
  
  #Crea una fiestra con tre radiobutton per selezionare una specie tra uomo, topo e ratto, poi passa il valore selezionato alla funzione cerca (default "human")
  radio <- function(){
    write("created 'radio' variable(function).",file = logFile,sep="",append = TRUE)
    inputBox <- tktoplevel()
    write("created 'inputBox' variable internal to the 'radio' function.",file = logFile,sep="",append = TRUE)
    rb1 <- tkradiobutton(inputBox)
    write("created 'rb1' variable internal to the 'radio' function.",file = logFile,sep="",append = TRUE)
    rb2 <- tkradiobutton(inputBox)
    write("created 'rb2' variable internal to the 'radio' function.",file = logFile,sep="",append = TRUE)
    rb3 <- tkradiobutton(inputBox)
    write("created 'rb3' variable internal to the 'radio' function.",file = logFile,sep="",append = TRUE)
    rbValue <- tclVar("Homo sapiens")
    write("created 'rbValue' variable internal to the 'radio' function.",file = logFile,sep="",append = TRUE)
    tkconfigure(rb1,variable=rbValue,value="Homo sapiens")
    tkconfigure(rb2,variable=rbValue,value="Mus musculus")
    tkconfigure(rb3,variable=rbValue,value="Rattus norvegicus")
    tkgrid(tklabel(inputBox,text="Which spece you want to analize?"))
    tkgrid(tklabel(inputBox,text="Human "),rb1)
    tkgrid(tklabel(inputBox,text="Mouse "),rb2)
    tkgrid(tklabel(inputBox,text="Rat "),rb3)
    
    #Una volta premuto il tasto ok dalla finestra di dialogo, invia il valore selezionato ad un'altra funzione
    onOK <- function(){
      write("created 'onOK' variable (function) internal to the 'radio' function.",file = logFile,sep="",append = TRUE)
      rbVal <<- as.character(tclvalue(rbValue))
      tkdestroy(inputBox)
    }
    
    OK.but <- tkbutton(inputBox,text="OK",command=onOK)
    write("created 'OK.but' variable internal to the 'radio' function.",file = logFile,sep="",append = TRUE)
    tkgrid(OK.but)
    tkfocus(inputBox)
  }
  
  #Questa funzione è da finire
  cerca <- function(specie, key){
    write("created 'cerca' variable (function).",file = logFile,sep="",append = TRUE)
    library('GEOquery')
    library('GEOmetadb')
    if(!file.exists('GEOmetadb.sqlite')){
      getSQLiteFile()
    }
    con <- dbConnect(SQLite(),'GEOmetadb.sqlite')
    write("created 'con' variable internal to the 'cerca' function.",file = logFile,sep="",append = TRUE)
    geo_tables <- dbListTables(con)
    write("created 'geo_tables' variable internal to the 'cerca' function.",file = logFile,sep="",append = TRUE)
    query <-paste("
                  SELECT count(*) ",
                  "FROM",
                  "  gsm JOIN gse_gsm ON gsm.gsm=gse_gsm.gsm",
                  "  JOIN gse ON gse_gsm.gse=gse.gse",
                  "  JOIN gse_gpl ON gse_gpl.gse=gse.gse",
                  "  JOIN gpl ON gse_gpl.gpl=gpl.gpl",
                  "WHERE", 
                  " gpl.organism LIKE '", specie, "' AND",
                  " gse.title LIKE '%", key, "%' OR",
                  " gse.summary LIKE '%", key, "%';")
    write("created 'query' variable internal to the 'cerca' function.",file = logFile,sep="",append = TRUE)
    if(key == inputArray[1]){
      gsm <<- as.character(dbGetQuery(con, query)) 
    }
    else{
      gsm <<- as.character(c(gsm, dbGetQuery(con, query))) 
    }
    #gse <- dbGetQuery(con,"SELECT DISTINCT gse FROM gse WHERE title LIKE '%human%' AND title LIKE '%breast%' AND title LIKE '%cancer%';")
  }
  
  #Questa funzione scrive i risultati dello script in un file di output in un data.frame, per poi scriverli in un file di tipo csv
  writeOutput <- function(outputFile) {
    write("created 'writeOutput' variable (function).",file = logFile,sep="",append = TRUE)
    writable <- data.frame(inputArray, gsm)
    write("created 'writable' variable internal to the 'writeOutput' function.",file = logFile,sep="",append = TRUE)
    colnames(writable) <- c("Keywords", "Number of gsm ID")
    write.csv(writable, outputFile)
  }
  
  #Qua iniziano i comandi che vengono eseguiti appena richiamata la funzione
  #Controllo se la cartella dei log esiste ed eventualmente la creo
  if (!file.exists("logs")){
    dir.create(file.path("logs"))
  }
  #Creazione del file di log
  logName <- paste("Prova", format(Sys.time(), format="%Y-%m-%d%H%M"), ".txt",sep = "_")
  logFile <- file.path("logs",logName)
  #Selezione file di input
  library('tcltk')
  rbVal <- ""
  write("Created 'rbVal' variable.",file = logFile,sep="",append = TRUE)
  input <- select()
  write("created 'input' variable.",file = logFile,sep="",append = TRUE)
  write(paste("Input file:",input,sep = " "),file = logFile,sep="")
  write(paste("Output file:",paste(outName,".csv",sep=""),sep = " "),file = logFile,sep="",append = TRUE)
  radio()
  write(paste("Specie:",rbVal,sep = " "),file = log,sep="",append = TRUE)
  write("created 'logName' variable.",file = logFile,sep="",append = TRUE)
  write("created 'logFile' variable.",file = logFile,sep="",append = TRUE)
  gsm <- ""
  write("created 'gsm' variable.",file = logFile,sep="",append = TRUE)
  inputArray <- as.character(scan(file=input, what=character(), sep = "\n"))
  write("created 'inputArray' variable.",file = logFile,sep="",append = TRUE)
  write("created 'counter' variable internal to the for loop.",file = logFile,sep="",append = TRUE)
  for (counter in inputArray){
    cerca(rbVal, counter)
  }
  write("removed 'counter' variable.",file = logFile,sep="",append = TRUE)
  writeOutput(paste(outName,".csv",sep=""))
  
}