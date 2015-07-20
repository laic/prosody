#!/bin/bash

ALTCONV=$1 # e.g. APPENUKENG003583, should match $ALTCONV.alignseg.txt
#SSCRIPTS=~/corpus/scripts/
PROSODY=~/prosody/
RSCRIPTS=$PROSODY/

DATADIR=~/lubbock/data/ted-trans/derived/
SEGSDIR=$DATADIR/segs/


mkdir -p $SEGSDIR

echo "*** raw pros***"
./extract-spurt-feats.sh "$DATADIR/alignseg/${ALTCONV}.alignseg.txt" $DATADIR/prosfeats/ $DATADIR/wav/  > feat.log.txt

echo "*** normalize ***"
SPURTSFILE=$DATADIR/alignseg/$ALTCONV.alignseg.txt
if [ ! -e $SEGSDIR/conv ]
then
	ln -s $DATADIR/prosfeats $SEGSDIR/conv 
fi

CONV=`head -n 2 $SPURTSFILE | tail -n 1 | cut -d " " -f 1`
echo $ALTCONV $CONV
Rscript $RSCRIPTS/get-pros-norm.r $CONV f0 $SEGSDIR $SPURTSFILE
Rscript $RSCRIPTS/get-pros-norm.r $CONV i0 $SEGSDIR $SPURTSFILE

echo "*** word aggs***"
WORDFILE=$DATADIR/alignword/$ALTCONV.alignword.txt
Rscript $RSCRIPTS/get-pros-window.r $CONV f0 $SEGSDIR $WORDFILE
Rscript $RSCRIPTS/get-pros-window.r $CONV i0 $SEGSDIR $WORDFILE

SEGFILE=$DATADIR/alignseg/$ALTCONV.alignseg.txt
Rscript $RSCRIPTS/get-pros-window.r $CONV f0 $SEGSDIR $SEGFILE
Rscript $RSCRIPTS/get-pros-window.r $CONV i0 $SEGSDIR $SEGFILE

SENTFILE=$DATADIR/alignsent/$ALTCONV.alignsent.txt
Rscript $RSCRIPTS/get-pros-window.r $CONV f0 $SEGSDIR $SENTFILE
Rscript $RSCRIPTS/get-pros-window.r $CONV i0 $SEGSDIR $SENTFILE

#)




