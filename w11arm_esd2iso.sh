#!/bin/sh 
#
#
# Credit: Location and methods of obtaining Microsoft ESD distributions and
# Microsoft Product catalog from b0gdanw "ESD to ISO on macOS.txt" https://gist.github.com/b0gdanw/e36ea84828dbd19e03eff6158f1fc77c
#
# This script is offered as-is, with NO GUARANTEES OR WARRANTIES
#

DEBUG=0
downloadApp="curl"
aOption=0
hOption=0
lOption=0
rOption=0
vOption=0
langCodes=""

version="1.0 (02-Mar-2023)"
requires="wiminfo wimapply wimexport"

usage() {
  echo "Usage: "
  echo "$0 [-a] [-v] [-h] esd-language"
  echo "$0 [-v] [-h] -r work-dir"
  echo "$0 -l"
  echo "\tesd-language\t Valid Windows 11 language tag"
  echo "\twork-dir\t Work directory for restarting failed download"
  echo "Options:"
  echo "\t-a\tUse aria2c for ESD download instead of curl"
  echo "\t-l\tList available language tags and languages and exit"
  echo "\t-h\tPrint usage and exit"
  echo "\t-v\tEnable verbose output"
  echo "\t-r working-dir\tRestart failed ESD download using work-dir"

  exit 1
}
printLanguages() {
	echo "Valid Microsoft ESD language tags are:\n"
	echo "Language tag	Language"
	echo "------------	--------------------"
    for i in $langCodes; do
      echo "${i}\t\t\t\t\c"
      xpath -q -n -e '//File[LanguageCode="'$i'"]/Language' $workingDir/w11arm_pro_products.xml | sed -E -e s/'(<Language>)|(<\/Language>)'//g
    done 
    rm -rf $workingDir
    exit 1
}
downloadCatalog(){
	wDir=$1
	if [ ! -d $wDir ]; then
		echo "ERROR: $wDir is expected to exist for downloadCatalog but doesn't"
		echo "Please report this error"
		exit 1
	fi
	#
	# Download and process the Windows Product Catalog so we know what languages are available
	# and the URLs for the downloads
	#
	echo "\nPlease wait while some required information is being downloaded from Microsoft and processed"
	(
		cd $wDir 
		curl -L "https://go.microsoft.com/fwlink?linkid=2156292" -o ./catalog.cab 
		tar xf catalog.cab products.xml
		sed -i .bak 's/\r//' products.xml
		echo '<Catalog>' > w11arm_pro_products.xml
		
		#
		# Get only the W11 Pro ARM64 products
		#
	
		xpath -q -n -e '//File[Architecture="ARM64"][Edition="Professional"]' products.xml >> w11arm_pro_products.xml
		
		echo '</Catalog>'>> w11arm_pro_products.xml
	
		#
		# Get the available languages
		# 
	)
	langCodes=$(xpath -q -n -e '//File/LanguageCode' $wDir/w11arm_pro_products.xml | sed -E -e s/"<[\/]?LanguageCode>"//g | sort)
	echo "Processing complete\n"
}
echo "w11arm_esd2iso $version\n"

setupEsdDownload(){
#
# Find the desired language variant file 
#
# Now that we know we have an image available in the desired language,
# build the file names for the download URL (from the Microsoft catalog info),
# the file name for the ESD that resides in the working directory
# and the name of the ISO we're going to generate
#
	

	xpath -q -n -e '//File[Architecture="ARM64"][Edition="Professional"][LanguageCode="'$esdLang'"]' $workingDir/w11arm_pro_products.xml >$workingDir/esd_edition.xml
	esdURL=$(xpath -n -q -e '//FilePath' $workingDir/esd_edition.xml | sed -E -e s/'(<FilePath>)|(<\/FilePath>)'//g)
	buildName=$(xpath -n -q -e '//FileName' $workingDir/esd_edition.xml | sed -E -e s/'(<FileName>)|(\.esd<[\/]FileName>)'//g)

	esdFile=$workingDir/${buildName}.esd
	isoFile=./${buildName}.iso

	if [ $DEBUG -ne 0 ] ; then
	    echo "\nesdURL = $esdURL"
	    echo "buildName = $buildName"
	    echo "esdFile = $esdFile"
	    echo "isoFile = $isoFile/n"
	fi

	echo "The generated ISO will be $isoFile"
	if [ -e $isoFile ]; then
	  echo "\tWARNING: File $isoFile exists, removing it"
	  rm -rf $isoFile
	fi
	echo "Selected language of the ISO is \c"
	xpath -n -q -e '//Language' $workingDir/esd_edition.xml | sed -E -e s/'(<Language>)|(<\/Language>)'//g
	[ $DEBUG -ne 0 ] && echo "The ESD will be downloaded from\n$esdURL"

	return 0
}

downloadEsd() {
	#
	# Get the ESD from Microsoft
	#
	
	if [ $downloadApp = "curl" ]; then
		curl --keepalive-time 300 $esdURL -o $esdFile;
		retVal=$?
	else
		aria2c -d $workingDir --file-allocation=none $esdURL
		retVal=$?
	fi
	if [ $retVal -eq 0 ]; then
		[ $DEBUG -gt 0 ] &&	wiminfo $esdFile
	fi
	return $retVal
}

extractEsd(){
	#
	# Extract image 1 in the ESD to create the boot environment
	#
	
	eFile=$1
	eDir=$2

	bootWimFile=$eDir/sources/boot.wim
	installWimFile=$eDir/sources/install.wim
	
	esdImageCount=`wiminfo $eFile | grep "Image Count:" | sed -E -e s/"Image Count:[ \\t]*"//`
	echo "image count $esdImageCount"
	echo "\nExtracting Windows boot and setup files to image"
	wimapply $eFile 1 $eDir

	#
	# Create the boot.wim file that contains WinPE and Windows Setup
	# Images 2 and 3 in the ESD contain these components
	#
	# Important: image 3 in the ESD must be marked as bootable when
	# transferred to boot.wim or else the installer will fail
	#
	wimexport $eFile 2 $bootWimFile --compress=LZX --chunk-size 32K
	wimexport $eFile 3 $bootWimFile --compress=LZX --chunk-size 32K --boot

	[ $DEBUG -ne 0 ] && wiminfo  $bootWimFile

	#
	# Create the install.wim file that contains the files that Setup will install
	# Images 4, 5, (and 6 if it exists) in the ESD contain these components
	#
	echo "\nExtracting Windows editions from ESD to the image"
	wimexport $eFile 4 $installWimFile --compress=LZMS --chunk-size 128K 
	wimexport $eFile 5 $installWimFile --compress=LZMS --chunk-size 128K 
	if [ $esdImageCount -eq 6 ]; then
		wimexport $eFile 6 $installWimFile --compress=LZMS --chunk-size 128K 
	fi

	[ $DEBUG -ne 0 ] && wiminfo $installWimFile
	return 0
}

buildIso(){
	iDir=$1
	iFile=$2
	elToritoBootFile=$iDir/efi/microsoft/boot/efisys.bin
	
	#
	# Create the ISO file
	#

	hdiutil makehybrid -o $iFile -iso -udf -hard-disk-boot -eltorito-boot $elToritoBootFile $iDir
	return $?
}

while getopts ":ahlr:v" opt; do
  case $opt in
    a)
    	aOption=1
    	;;
    h)
    	usage
    	;;

    r)
    	rOption=1
    	workingDir=$OPTARG
    	;;
    l)
    	lOption=1
    	;;
    v)
    	vOption=1
    	;;
    :)
    	echo "Option -$OPTARG requires an argument"
    	usage
    	;;
    
    \?)
    	echo "Invalid option: -$OPTARG"
    	usage
    	;;
    esac
done
shift "$((OPTIND-1))"
#
# Check number of arguments
# One argument is allowed when not using the -r option for restart
# If using the -r or -l options no arguments are allowed
#

if [ $# -gt 1 ]; then
	echo "ERROR: Too many arguments specified"
	usage
fi

if [ $rOption -eq 1 ]; then
	if [ $aOption -eq 1 ]; then
		echo "NOTE: the -a option does not need to be specified, it implied with -r option"
	else
		aOption=1
	fi
	if [ $lOption -eq 1 ]; then
		echo "ERROR: the -l can not be used with the -r option"
		usage
	fi
	if [ $# -eq 1 ]; then
		echo "ERROR: esd-language is not allowed when using -r option"
		usage
	fi
fi
if [ $lOption -eq 1 ]; then
	if [ $rOption -eq 1  -o  $aOption -eq 1  ]; then
		echo "ERROR: the -a, -r and -h options can not be used with the -l option"
		usage
	fi
	if [ $# -eq 1 ]; then
		echo "ERROR: esd-language argument is not allowed when using -l option"
		usage
	fi
fi
if [ $rOption -eq 0 -a $lOption -eq 0 ]; then
	if [ $# -lt 1 ]; then
		echo "ERROR: esd-language argument is required"
		usage
	fi
fi


if [ $vOption -eq 1 ]; then
	DEBUG=1
fi

#
# If the -a option was specified, see if aria2c exists
# If we are doing a restart and aria2c doesn't exist, error out since a restartable
# download can only occur with aria2c
# If we aren't doing a restart and aria2c doesn't exist, then default back to curl
#

if [ $aOption -eq 1 ]; then
	which -s aria2c
	if [ $? -ne 0 ]; then
		if [ $rOption -eq 1 ]; then
			echo "ERROR: Download restart requested, but aria2c can not be found"
			echo "Restart request can not be performed"
			exit 2
		else
		    echo "WARNING: aria2c not found, -a option ignored"
		    aOption=0
		fi
	else
		downloadApp="aria2c"
   		echo "NOTE: Using aria2c for ESD download"
   	fi
fi


#
# Check for for wiminfo, wimapply and wimexport 
#
# all of these are from open source package wimlib
# Warn the user if any of them are not here and abort
#

echo "\nChecking for presence of wimlib utilities"
notFound=0
for i in $requires; do
    which -s $i
    if [ $? -ne 0 ]; then
      echo "\t$i not found"
      notFound=1
    fi
done
if [ $notFound -eq 1 ]; then
      echo "ERROR: One or more wimlib utiltiies are not found."
      exit 1
fi 
echo "Required wimlib utilities are present"

if [ $rOption -eq 0 -a $lOption -eq 1 ]; then
	workingDir=`mktemp -q -d ./esd2iso_temp.XXXXXX`
	if [ $? -ne 0 ]; then
		echo "Unable to create work directory, exiting"
		exit 1
	fi
	downloadCatalog $workingDir
	printLanguages
fi

if [ $rOption -eq 0 ]; then

	#
	# No restart requested - perform normal processing
	#
	
	freeSpace=$(df -g . | awk '/dev.*/ {print $4}')
	[ $DEBUG -gt 0 ] && echo "Free space is $freeSpace GB"
	if [ $freeSpace -lt 15 ]; then
		echo "ERROR: You have insufficent space on this disk to complete the ISO build."
		echo "This script requires approximately 15 GB of free disk space and you have "
		echo "$freeSpace GB remaining."
		exit 1
	else
		if [ $freeSpace -lt 20 ]; then
			echo "WARNING: This script typically requires 12-15 GB of free disk space to complete"
			echo "You have $freeSpace GB available. You may run out of disk space during the process."
		fi
	fi

	#
	# We're going to make a temp directory where we're going to do all of our work
	# mktemp will put this directory in the current working directory.
	#

	workingDir=`mktemp -q -d ./esd2iso_temp.XXXXXX`
	if [ $? -ne 0 ]; then
		echo "Unable to create work directory, exiting"
		exit 1
	fi
	echo "Work directory $workingDir created"
	
	downloadCatalog $workingDir
    
	#
	# extDir is the "extract directory" where we're going to extract the ESD 
	# and evenutally build the ISO from. It's a subdirectory of the working/temp directory
	#

	extDir=$workingDir/Windows11ARM64_ESD
	mkdir $extDir



	esdLang=`echo $1 | tr "[:upper:]" "[:lower:]"`

	if [ $esdLang != $1 ]; then
		echo "NOTE: Language specification $1 has been converted to lower case for use in this script"
	fi

	#
	# Verify that the language is supported by Windows
	#
	echo "\nVerifying language $esdLang is available\c"
	found=0
	for i in $langCodes; do
	 if [ $esdLang = $i ]; then 
	   found=1; 
	 fi;
	done

	if [ $found -eq 0 ]; then
	  echo "...FAILED\nERROR: $esdLang is not a valid language tag"
	  printLanguages
	fi
	echo "...verified"

	echo "\nStep 1: Getting information about the requested $esdLang ESD file\n"
	setupEsdDownload
	echo "\nStep 1 completed"

	echo "\nStep 2: Downloading ESD from Microsoft with $downloadApp\n"
	downloadEsd
	if [ $? -ne 0 ]; then
		echo  "ERROR: ESD download failed with error $retVal"
		if [ $aOption -eq 1 ]; then
			#
			# Write out information to support download restart if we are using aria2c
			# for download
			#
			touch $workingDir/restartOK
			echo "isoFile $isoFile" >> $workingDir/restartOK
			echo "esdFile $esdFile" >> $workingDir/restartOK
			echo "esdURL $esdURL" >> $workingDir/restartOK
			echo "ESD download can be restarted with the following command:"
			echo "$0 -r $workingDir"
		else
			rm -rf $workingDir
		fi
		exit 1
	fi
else
	#
	# Restart option selected
	#
	# See if the work directory exists and if it supports restart
	#
	
	if [ ! -d $workingDir ]; then
		echo "ERROR:Work directory $workingDir does not exist, exiting"
		exit 2
	fi
	if [ ! -f "$workingDir/restartOK" ]; then
		echo "ERROR: The work directory $workingDir does not support restart, exiting"
		exit 2
	fi;
	#
	# Reset variables needed for restart
	#
	extDir=$workingDir/Windows11ARM64_ESD
	isoFile=$(cat $workingDir/restartOK | awk '/isoFile/ { print $2 }')
	esdFile=$(cat $workingDir/restartOK | awk '/esdFile/ { print $2 }')
	esdURL=$(cat $workingDir/restartOK | awk '/esdURL/ { print $2 }')

	if [ $DEBUG -ne 0 ] ; then
	    echo "\nesdURL = $esdURL"
	    echo "esdFile = $esdFile"
	    echo "isoFile = $isoFile/n"
	fi

	echo "Restarting Step 2: Downloading ESD from Microsoft with $downloadApp\n"
	downloadEsd
	if [ $? -ne 0 ]; then
		echo  "ERROR: ESD download failed with error $retVal"
		echo "ESD download can be restarted with the following command:"
		echo "$0 -r $workingDir"
		exit 1
	else
		rm $workingDir/restartOK
	fi
fi
	
echo "Step 2 complete - ESD downloaded"	
	
echo "\nStep 3: Building installation image from ESD distribution"

extractEsd $esdFile $extDir

echo "\nStep 3 completed - installation image built"



echo "\nStep 4: Creating ISO $isoFile from the installation image\n"

if buildIso $extDir $isoFile ; then
    echo "Step 4 completed - ISO created"
else
    echo "ERROR: ISO was NOT created"
    echo "Working directory $workingDir was not deleted, use for debugging"
    exit 1
fi

echo "\nCleaning up work directory"
rm -rf $workingDir
echo "Done!"
exit 0