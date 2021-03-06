entry <- function(vars, 
                  labels = vars,
                  title = 'Digitare il nome del file di output',
                  prompt = NULL) {
  
  stopifnot(length(vars) == length(labels))
  
  # Create a variable to keep track of the state of the dialog window:
  # done = 0; If the window is active
  # done = 1; If the window has been closed using the OK button
  # done = 2; If the window has been closed using the Cancel button or destroyed
  done <- tclVar(0)
  
  tt <- tktoplevel()
  tkwm.title(tt, title)	
  entries <- character()
  tclvars <- character()
  
  # Capture the event "Destroy" (e.g. Alt-F4 in Windows) and when this happens, 
  # assign 2 to done.
  tkbind(tt,"<Destroy>",function() tclvalue(done)<-2)
  
  tclvars <- tclVar("")
  entries <- tkentry(tt, textvariable=tclvars)
  
  doneVal <- as.integer(tclvalue(done))
  results <- character()
  
  reset <- function() {
    tclvalue(tclvars) <<- ""
  }
  reset.but <- tkbutton(tt, text="Reset", command=reset)
  
  cancel <- function() {
    tclvalue(done) <- 2
  }
  cancel.but <- tkbutton(tt, text='Cancel', command=cancel)
  
  submit <- function() {
    for(i in seq_along(vars)) {
      tryCatch( {
        results <<- tclvalue(tclvars)
        tclvalue(done) <- 1
      },
      error = function(e) { tkmessageBox(message=geterrmessage()) },
      finally = { }
      )
    }
  }
  submit.but <- tkbutton(tt, text="Submit", command=submit)
  
  tkgrid(tklabel(tt, text=labels), entries, pady=10, padx=10, columnspan=4)
  
  tkgrid(submit.but, cancel.but, reset.but, pady=10, padx=10, columnspan=3)
  tkfocus(tt)
  
  # Do not proceed with the following code until the variable done is non-zero.
  #   (But other processes can still run, i.e. the system is not frozen.)
  tkwait.variable(done)
  
  if(tclvalue(done) != 1) {
    results <- NULL
  }
  
  tkdestroy(tt)
  return(results)
}

#Seleziona il file di input dalla lista di file disponibili e lo ritorna
select <- function(){
  writeLog("created 'select' variable (function).")
  input <- tclvalue(tkgetOpenFile(title="Selezionare il file di input", filetypes = "{ {Text Files} {.txt} }"))
  writeLog("created 'input' variable internal to the 'select' function.")
  if(input == ""){
    writeLog("ERROR: no input file selected")
    stop()
  }
  return(input)
}

#Crea una fiestra con tre radiobutton per selezionare una specie tra uomo, topo e ratto, poi passa il valore selezionato alla funzione cerca (default "human")
radio <- function(){
  done <- tclVar(0)
  writeLog("created 'radio' variable(function).")
  inputBox <- tktoplevel()
  # Capture the event "Destroy" (e.g. Alt-F4 in Windows) and when this happens, 
  # assign 2 to done.
  tkbind(inputBox,"<Destroy>",function() tclvalue(done)<-2)
  writeLog("created 'inputBox' variable internal to the 'radio' function.")
  rb1 <- tkradiobutton(inputBox)
  writeLog("created 'rb1' variable internal to the 'radio' function.")
  rb2 <- tkradiobutton(inputBox)
  writeLog("created 'rb2' variable internal to the 'radio' function.")
  rb3 <- tkradiobutton(inputBox)
  writeLog("created 'rb3' variable internal to the 'radio' function.")
  rbValue <- "'Homo sapiens'"
  writeLog("created 'rbValue' variable internal to the 'radio' function.")
  tkconfigure(rb1,variable=rbValue,value="'Homo sapiens'")
  tkconfigure(rb2,variable=rbValue,value="'Mus musculus'")
  tkconfigure(rb3,variable=rbValue,value="'Rattus norvegicus'")
  tkgrid(tklabel(inputBox,text="Which spece you want to analize?"))
  tkgrid(tklabel(inputBox,text="Human "),rb1)
  tkgrid(tklabel(inputBox,text="Mouse "),rb2)
  tkgrid(tklabel(inputBox,text="Rat "),rb3)
  
  #Una volta premuto il tasto ok dalla finestra di dialogo, invia il valore selezionato ad un'altra funzione
  onOK <- function(){
    writeLog("created 'onOK' variable (function) internal to the 'radio' function.")
    rbVal <<- tclvalue(rbValue)
    if(rbVal != ""){
	  tclvalue(done) <- 1
      writeLog(paste("Specie:", rbVal, sep = " "))
    }
  }
  
  OK.but <- tkbutton(inputBox,text="OK",command=onOK)
  writeLog("created 'OK.but' variable internal to the 'radio' function.")
  tkgrid(OK.but)
  tkfocus(inputBox)
  tkwait.variable(done)
  if(tclvalue(done) != 1) {
    writeLog("ERROR: no spece selected")
    stop()
  }
  tkdestroy(inputBox)
  for (counter in inputArray){
        cerca(rbVal, counter)
      }
  writeLog("removed 'counter' variable.")
  writeOutput(paste(outName,".csv",sep=""))
}

#Questa funzione è da finire
cerca <- function(specie, key){
  writeLog("created 'cerca' variable (function).")
  library('GEOquery')
  library('GEOmetadb')
  if(!file.exists('GEOmetadb.sqlite')){
    getSQLiteFile()
  }
  con <- dbConnect(SQLite(),'GEOmetadb.sqlite')
  writeLog(paste("created 'con' variable internal to the 'cerca' function. Specie:", specie, " chiave: ", key))
  geo_tables <- dbListTables(con)
  writeLog("created 'geo_tables' variable internal to the 'cerca' function.")
  query1 <-paste("SELECT gse.gse, count(gsm.gsm)",
                 "FROM",
                 "  gsm JOIN gse_gsm ON gsm.gsm=gse_gsm.gsm",
                 "  JOIN gse ON gse_gsm.gse=gse.gse",
                 "  JOIN gse_gpl ON gse_gpl.gse=gse.gse",
                 "  JOIN gpl ON gse_gpl.gpl=gpl.gpl",
                 "WHERE", 
                 " gpl.organism=", specie, " AND (gse.title LIKE '%", key, "%' OR gse.summary LIKE '%", key, "%')",
                 " GROUP BY gse.gse;")
  writeLog("created 'query1' variable internal to the 'cerca' function.")
  localGsm <- dbGetQuery(con, query1)
  localGsm <- data.frame (rep(key, nrow(localGsm)) ,localGsm)
  colnames(localGsm) <- c("keyword","GSE ID","# GSM")
  if(key == inputArray[1]){
    gsm <<- localGsm
  }
  else{
    gsm <<- rbind(gsm, localGsm)
  }
  
}

#Questa funzione scrive i risultati dello script in un file di output in un data.frame, per poi scriverli in un file di tipo csv
writeOutput <- function(outputFile) {
  writeLog("created 'writeOutput' variable (function).")
  write.csv(gsm, outputFile)
}

writeLog <- function(message){
  write(message,file = logFile ,sep="",append = TRUE)
}

#Qua iniziano i comandi che vengono eseguiti appena richiamata la funzione
#Controllo se la cartella dei log esiste ed eventualmente la creo
if (!file.exists("logs")){
  dir.create(file.path("logs"))
}
#Creazione del file di log
logName <- paste("Prova_", format(Sys.time(), format="%Y-%m-%d%H%M"), ".txt",sep = "")
logFile <- file.path("logs",logName)
#Selezione file di input
library('tcltk')
outName <- entry("File :")
if(is.null(outName) || outName == ""){
  writeLog("ERROR: no output file selected")
  stop()
}
rbVal <- ""
writeLog("Created 'rbVal' variable.")
input <- select()
writeLog("created 'input' variable.")
writeLog(paste("Input file:",input,sep = " "))
writeLog(paste("Output file:",paste(outName,".csv",sep=""),sep = " "))
gsm <- ""
writeLog("created 'gsm' variable.")
inputArray <- as.character(scan(file=input, what=character(), sep = "\n"))
writeLog("created 'inputArray' variable.")
radio()
writeLog("created 'logName' variable.")
writeLog("created 'logFile' variable.")
writeLog("created 'counter' variable internal to the for loop.")
