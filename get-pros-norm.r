## A script to collate and normalize F0 and intensity features
## from praat output.
source("read-praat-files.r")
library(plyr)
library(data.table)

#----------------------------------------------------------------
args=(commandArgs(TRUE))
if(length(args) < 4){
        stop("Not enough arguments supplied. Exit.")
} 

#----------------------------------------------------------------
print(args)
currconv <- args[1]	## The identifier for the speech data
featname <- args[2]	## F0 or Intensity
segsdir <- args[3]	## The working directory 
spurtfile <- args[4]	## A text file listing segment metadata 
			## This should be the same as used to extract
			## the features from praat

## Directories where the raw features values are
convdir <- paste(segsdir, "/conv/", currconv, "/", sep="")
if (featname == "i0") {
	rawdir <- paste(segsdir, "/conv/", currconv, "/", currconv, "-int",  "/", sep="")
} else {
	rawdir <- paste(segsdir, "/conv/", currconv, "/", currconv, "-", featname, "/", sep="")
}

featdir <- paste(segsdir, "/", featname, "/", sep="")
if (!file.exists(featdir)) {
	dir.create(featdir, recursive=T)
	print(paste("creating", featdir))
}

#----------------------------------------------------------------
# Get time series data.  
if (featname == "i0") {
	print("get.i0.tiers")
	st <- "none"
	x.list <- get.i0.tiers.conv(currconv, rawdir)
} else if (featname == "f0") {
	print("get.f0.tiers")
	st <- "mean.val" 	## Convert to semitones based on speaker mean
	x.list <- get.f0.tiers.conv(currconv, rawdir)
} else {
	#To extend we have to add in suffix names, number of 
	#lines to skip etc, because praat is not completely consistent.
	#We might as well change to a switch statement. 
	stop(paste("unknown feature type:", featname))
}

##----------------------------------------------------------------
## Get spurt info
## Need to account for some inconsistencies in file creation in the past!
print(spurtfile)
if (grep(".txt", spurtfile)) {
	if (grepl("asrspurts", spurtfile) || grepl("turns", spurtfile)) {  
		spurts.channel <-  data.table(read.table(spurtfile, header=F))
		setnames(spurts.channel, c("conv","spk","participant","sid","chno","vsrc","starttime","endtime","wid","vconv","wav.file","video.file"))
	} else {
		## This is the one we want
		spurts.channel <-  data.table(read.table(spurtfile, header=T))
		if ("part" %in% names(spurts.channel)) {
			setnames(spurts.channel, "part", "participant")
		}
		if ("sent.id" %in% names(spurts.channel)) {
			setnames(spurts.channel, "sent.id", "wid")
		}
	}
} else {
	spurts.obj <- load(spurtfile)
	spurts.channel <- get(spurts.obj)
}


#summary(spurts.channel)

## Add offset times
x.offset <- add.times(x.list, spurts.channel) 

## Get stats over all the data for each speaker
var.name <- toupper(featname)
x.aggs <- calc.spk.aggs(x.offset, var.name=var.name)
setnames(x.aggs, names(x.aggs), gsub(var.name, "val", names(x.aggs)))

## Get normalized values
## We can remove spurt slope if we want to focus on utterance
## internal features that might be affected by declination. 
## We keep the non-corrected version anyway.
x.norm <- normalize.conv(x.offset, x.aggs, var.name=var.name, st=st, zscore=F, center=T, remove.outliers=T, remove.spurt.slope=T)

## Adds some extra bibs and bobs
conv.maxtime  <- spurts.channel[,list(maxtime=max(endtime, na.rm=T)),by=conv]
x.norm <- add.maxtime(x.norm, conv.maxtime=unique(conv.maxtime))

## This is just something leftover from working with NXT data
if (("spk" %in% names(x.norm)) & !("nxt_agent" %in% names(x.norm))) {
	setnames(x.norm, c("spk"), c("nxt_agent"))  
}
if (("chno" %in% names(x.norm)) & !("channel" %in% names(x.norm))) {
	setnames(x.norm, c("chno"), c("channel"))
}

## Get pointwise derivatives 
x.norm <- add.df.conv(x.norm, var.name=var.name)

## Add this xid field in to make things easier later. 
x.norm <- data.table(xid=x.norm[,paste(conv, nxt_agent, sep="-")], x.norm)

## Output the normalized values
normfile <- paste(segsdir, "/", featname, "/", currconv, sep="")
save(x.norm, file=normfile)
write.table(x.norm, file=paste(normfile,".txt",sep=""), row.names=F)

print("=== END get-pros-norm ===")

