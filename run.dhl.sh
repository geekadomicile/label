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
    grep -m 1 -ho 'WAYBILL[0-9]\{10\}$' $f.txt > tmp.txt
    TRACKINGNUMBER="$(grep -m 1 -ho '[0-9]\{10\}$' tmp.txt)"
	
	UNIQUENAME=$f.$TRACKINGNUMBER
    echo $TRACKINGNUMBER
	DEST=../$DESTDIR/$UNIQUENAME
	mkdir $DEST

	# Get first half of label
	convert -crop 1179x1037+53+30 -density 205 $f.png $DEST/tracking.png
	# Get second half of label
	convert -crop 1179x1037+53+1227 -density 205 $f.png $DEST/tracking2.png


	mv $f.txt	$DEST/
	mv $f		$DEST/
	rm tmp.txt
	rm $f.png
done
cd ..
ls -l $DESTDIR
