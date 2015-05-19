#!/usr/bin/Rscript --vanilla --slave

library(data.table)
library(plyr)
source("proc-prosody.r")

print("=== START get-pros-window ===")

args=(commandArgs(TRUE))
if(length(args)==0){
	stop("No arguments supplied. Exiting")

}

#----------------------------------------------------------
print(args)
currconv <- args[1]
featname <- args[2]
xdir <- args[3]
window.file  <- args[4]
#window.type <- args[5]
#----------------------------------------------------------
## get windows
#window.file <- paste(window.dir, "/", currconv, ".", window.type, ".txt" sep="")		

window.type <- strsplit(basename(window.file), "\\.")[[1]][2]
print(window.type)

segs <- fread(window.file)
segs <- segs[,list(conv, xid=paste(conv, spk, sep="-"), niteid=sent.id, wstarts=starttime, wends=endtime)]
print(segs)

x.list <- dlply(segs, .(xid), function(x) {x})
print(paste("spk NAMES:", names(x.list)))

## get feature time series 
objfile <- paste(xdir, "/", featname, "/", currconv, sep="")		
xobj <- load(objfile)
x.feat <- get(xobj)

## Fix an ICSI error 
#if (currconv == "Bmr031") {
#	x.feat$participant[x.feat$xid == "Bmr031-H"] <- "me001"
#}

## Get aggs
x.aggs <- get.var.aggs.spk(x.feat, windows=x.list, wkey="xid", var.name=toupper(featname))

#if (featname == "i0") {
#	x.aggs <- get.i0.aggs.spk(x.feat, windows=x.list, wkey="xid")
#} else if (featname == "f0") {
#	x.aggs <- get.f0.aggs.spk(x.feat, windows=x.list, wkey="xid")
#}

outfile.txt <- paste(xdir, "/", featname, "/", currconv, ".aggs.", window.type, ".txt", sep="")		
print(outfile.txt)	
write.table(x.aggs[order(wstart)], file=outfile.txt, row.names=F, quote=F)	
	
print("=== END get-pros-window ===")

