#!/bin/bash

SRCDIR="upload"
TMPDIR="tmp"
DESTDIR="processed"

mkdir -p $SRCDIR
mkdir -p $TMPDIR
mkdir -p $DESTDIR

for f in $SRCDIR/*.pdf;
do
	mv $f $TMPDIR/$(date +%F-%T.%N).pdf
done

cd $TMPDIR
for f in *.pdf;
do
	# make png file
	convert -density 300 $f $f.png
	# make txt file
	pdftotext $f $f.txt

	# trim
	sed -i -- 's/\ //g' $f.txt

	# parse text data
    TRACKINGNUMBER="$(grep -m 1 -ho '[A-Z]\{2\}[0-9]\{9\}[A-Z]\{2\}$' $f.txt)"
	
	UNIQUENAME=$f.$TRACKINGNUMBER

	DEST=../$DESTDIR/$UNIQUENAME
	mkdir $DEST

	# Get proof of dispatch
	convert -crop 1629x1183+110+1080 -density 205 $f.png $DEST/proof.png
    mogrify -rotate 90 $DEST/proof.png
	# Get first tracking barcode
	convert -crop 1312x1710+2130+382 -density 205 $f.png $DEST/tracking.png

	mv $f.txt	$DEST/
	mv $f		$DEST/
	rm $f.png
done
cd ..
ls -l $DESTDIR
