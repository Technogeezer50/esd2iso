#/bin/sh

version=$1
FILES="README w11arm_esd2iso w11arm_esd2iso_manpage.pdf doc bin lib"
DOCS="CHANGELOG COPYING COPYING.GPLv2 COPYING.GPLv2 COPYING.LGPLv3"

rebuild_bindir() {
	
	BINDIR="$1"

	if [ "x$BINDIR" = "x" ]; then
 		echo "Error: need directory location to rebuild"
 		exit 1
	fi

	echo "Rebuilding bin directory $BINDIR"
	rm -rf $1
	mkdir $1

	( cd "${BINDIR}"

	  cp /opt/local/bin/aria2c ./
	  cp /opt/local/bin/wimlib-imagex ./

	  ln -s wimlib-imagex wimapply
	  ln -s wimlib-imagex wiminfo
	  ln -s wimlib-imagex wimexport
	)

	# ls -alR "${BINDIR}"

        return 0
}
rebuild_libdir() {

	LIBDIR="$1"

	if [ "x$LIBDIR" = "x" ]; then
 		echo "Error: need directory location to rebuild"
 		exit 1
	fi

	echo "Rebuilding lib directory $LIBDIR"
	rm -rf $1

	mkdir $LIBDIR
	( cd $LIBDIR

	  cp -R /opt/local/lib/libgmp*.dylib ./
	  cp -R /opt/local/lib/libgmpxx*.dylib ./
	  cp -R /opt/local/lib/libiconv*.dylib ./
	  cp -R /opt/local/lib/libicudata*.dylib ./
	  cp -R /opt/local/lib/libicui18n*.dylib ./
	  cp -R /opt/local/lib/libicuio*.dylib ./
	  cp -R /opt/local/lib/libicutest*.dylib ./
	  cp -R /opt/local/lib/libicutu*.dylib ./
	  cp -R /opt/local/lib/libicuuc*.dylib ./
	  cp -R /opt/local/lib/libintl*.dylib ./
	  cp -R /opt/local/lib/liblzma*.dylib ./
	  cp -R /opt/local/lib/libuv*.dylib ./
	  cp -R /opt/local/lib/libwim*.dylib ./
	  cp -R /opt/local/lib/libxml2*.dylib ./
	  cp -R /opt/local/lib/libz*.dylib ./
	  
	  cp    /opt/local/libexec/openssl3/lib/libcrypto.3.dylib ./
	  ln -s libcrypto.3.dylib libcrypto.dylib
	)
	# ls -alR "$LIBDIR"

	return 0
}

if [ "x$version" = "x" ]; then
   echo "Error: must specify a version"
   exit 1
fi

rm -rf zipfile
mkdir zipfile

echo "Installing utility and README files"

cp w11arm_esd2iso zipfile
cp README zipfile

rebuild_bindir zipfile/bin
rebuild_libdir zipfile/lib

echo "Rebuilding doc directory zipfile/doc"
mkdir zipfile/doc
cp $DOCS zipfile/doc

echo "Creating manpage doc"
pandoc --from=markdown --to=man  w11arm_esd2iso.1.md --standalone | mandoc -man -T pdf >zipfile/w11arm_esd2iso_manpage.pdf

ls -alR zipfile

echo "Creating zip file w11arm_esd2iso-V${version}.zip"

( cd zipfile; zip -ry ../w11arm_esd2iso-V${version}.zip  $FILES )

rm -rf zipfile
exit 0


