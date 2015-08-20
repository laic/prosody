#!/bin/bash

## Get raw F0 and intensity features using praat.  

PRAAT=praat 		#/exports/home/clai/.local/bin/praat
spurtfile=$1		## Segmentation file, see for example ~/lubbock/data/ted-trans/derived/alignseg/${ALTCONV}.alignseg.txt" 
spurtdir=$2 		## This is the output directory 	
indir=$3		## i.e. where the wav files are    

tail -n +2 $spurtfile |
while read line
do
	conv=`echo $line | cut -d " " -f 1`
	spk=`echo $line | cut -d " " -f 2`
	part=`echo $line | cut -d " " -f 3`
	sid=`echo $line | cut -d " " -f 4`
	chno=`echo $line | cut -d " " -f 5`
	#vidsrc=`echo $line | cut -d " " -f 6`
	start=`echo $line | cut -d " " -f 6`
	end=`echo $line | cut -d " " -f 7`
	niteid=`echo $line | cut -d " " -f 8`
	wavfile=`echo $line | cut -d " " -f 9`

	outfile=$niteid
	outdir="$spurtdir/$conv/"

	#echo $start $end
	#echo $indir
	#echo $outdir

        if [ ! -e $outdir ]
        then
                mkdir $outdir
                #mkdir $outdir/$conv-wav 
                mkdir $outdir/$conv-f0
                mkdir $outdir/$conv-int
        fi

	echo  $wavfile $outfile $start $end $indir $outdir $conv 
	#echo `which praat`
	praat ./extract-feats.praat $wavfile $outfile $start $end $indir $outdir $conv 

done  

#exit 0
