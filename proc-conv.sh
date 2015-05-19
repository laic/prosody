#!/bin/bash

ALTCONV=$1 #APPENUKENG003583
SSCRIPTS=~/corpus/scripts/
PROSODY=~/prosody/

DATADIR=~/lubbock/data/ted-trans/derived/
SEGSDIR=$DATADIR/segs/


#(cd $PROSODY

mkdir -p $SEGSDIR

#echo "*** raw pros***"
./extract-spurt-feats.sh "$DATADIR/alignsent/${ALTCONV}.alignsent.txt" $DATADIR/prosfeats/ $DATADIR/wav/  > feat.log.txt

RSCRIPTS=$PROSODY/
echo "*** normalize ***"
SPURTSFILE=$DATADIR/alignsent/$ALTCONV.alignsent.txt
if [ ! -e $SEGSDIR/conv ]
then
	ln -s $DATADIR/prosfeats $SEGSDIR/conv 
fi

CONV=`head -n 2 $SPURTSFILE | tail -n 1 | cut -d " " -f 1`
echo $ALTCONV $CONV
Rscript $RSCRIPTS/get-pros-norm.r $CONV f0 $SEGSDIR $SPURTSFILE
Rscript $RSCRIPTS/get-pros-norm.r $CONV i0 $SEGSDIR $SPURTSFILE

echo "*** word aggs***"
Rscript $RSCRIPTS/get-pros-window.r $CONV f0 $SEGSDIR $SPURTSFILE
Rscript $RSCRIPTS/get-pros-window.r $CONV i0 $SEGSDIR $SPURTSFILE

#)





