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
    cat $f.txt

	# trim
	sed -i -- 's/\ //g' $f.txt

	# parse text data
    TRACKINGNUMBER="$(grep -m 1 -ho '[A-Z]\{2\}[0-9]\{9\}FR\|[0-9][A-Z][0-9]\{11\}$' $f.txt)"
    echo $TRACKINGNUMBER
	
	UNIQUENAME=$f.$TRACKINGNUMBER

	DEST=../$DESTDIR/$UNIQUENAME
	mkdir -p $DEST

	# Get proof of dispatch and rotate
	convert -crop 1472x1045+1876+1294 -density 205 $f.png $DEST/proof.png
    mogrify -rotate 270 $DEST/proof.png
	# Get first tracking barcode
	convert -crop 1182x1417+236+379 -density 205 $f.png $DEST/tracking.png

	mv $f.txt	$DEST/
	mv $f		$DEST/
	rm $f.png
done
cd ..
