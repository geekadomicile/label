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
	VALIDCOUNTRY="$(head -n 1 $f.txt)"
	TRACKINGNUMBER="$(grep -ho '^[0-9][A-Z][0-9]\{11\}$' $f.txt)"
	INTLTRACKINGNUMBER="$(grep -ho '^[A-Z]\{2\}[0-9]\{9\}[A-Z]\{2\}$' $f.txt)"
	MAXWEIGHT="$(grep -ho '^Max\.[0-9]*g$' $f.txt)"
	PRICE="$(grep -ho '^[0-9]\{1,\},[0-9]\{2\}$' $f.txt)"
	VALIDUNTIL="$(grep -ho '[0-9]\{8\}-' $f.txt)"
	STAMPNUMBER="$(grep -ho -m 1 '^[0-9A-Z^\ ]\{10\}$' $f.txt)"
	
	UNIQUENAME=$f.$VALIDCOUNTRY.$TRACKINGNUMBER$INTLTRACKINGNUMBER.$MAXWEIGHT.$PRICE.$VALIDUNTIL.$STAMPNUMBER

	DEST=../$DESTDIR/$UNIQUENAME
	mkdir $DEST

	# Get first stamp
	convert -crop 702x375+113+163 $f.png $DEST/stamp.png
	# Get first tracking barcode
	convert -crop 702x375+923+163 $f.png $DEST/tracking.png

	mv $f.txt	$DEST/vosTimbres.txt
	mv $f		$DEST/vosTimbres.pdf
	rm $f.png
done
cd ..
ls -l $DESTDIR
