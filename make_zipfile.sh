#/bin/sh

version=$1
FILES="w11arm_esd2iso README CHANGELOG w11arm_esd2iso_manpage.pdf"

pandoc --from=markdown --to=man  w11arm_esd2iso.1.md --standalone | mandoc -man -T pdf >w11arm_esd2iso_manpage.pdf

zip w11arm_esd2iso-V${version}.zip  $FILES

