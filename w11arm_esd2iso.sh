#!/bin/sh
#
#
# Credit: Location and methods of obtaining Microsoft ESD distributions and
# Microsoft Product catalog from b0gdanw "ESD to ISO on macOS.txt" https://gist.github.com/b0gdanw/e36ea84828dbd19e03eff6158f1fc77c
#
# This script is offered as-is, with NO GUARANTEES OR WARRANTIES
#


verbosityLevel=0
aOption=0
bOption=0
hOption=0
lOption=0
rOption=0
langCodes=""

version="w11arm_esd2iso 2.1 (22-Mar-2023)\n"
requires="wiminfo wimapply wimexport"

usage() {
  echo "Usage:\n"
  echo "$0 [-abhvV] esd-language"
  echo "$0 [-vVh] -r work-dir"
  echo "$0 [-vVh] -l\n\nArguments:"
  echo "\tesd-language\\tValid Windows 11 language tag"
  echo "\twork-dir\tWork directory for restarting failed download"
  echo "\nOptions:"
  echo "\t-a\tUse aria2c for ESD download instead of curl"
  echo "\t-b\t  Download business (Pro/Enterprise) ESD instead of consumer (Home/Pro)"
  echo "\t-h\tPrint usage and exit"
  echo "\t-v\tEnable verbose output"
  echo "\t-V\tPrint script version and exit"
  echo "\t-r work-dir\n\t\tRestart the failed ESD download from a prior execution using work-dir"
}
printVersion() {
	echo $version
}
verboseOn() {
	if [ $verbosityLevel -eq 0 ]; then
		return 1
	else
		return 0
	fi
}
printLanguages() {
	local langCode
	local langDesc
	
	printf '%s\n\n' "Valid Microsoft ESD language tags are:"
	printf '%-20s %-30s\n' "Language tag"	"Language"
	printf '%-20s %-30s\n'  "------------" "--------------------"
    for langCode in $langCodes; do
      langDesc="$(xpath -q -n -e '//File[LanguageCode="'$langCode'"]/Language' $workingDir/w11arm_products.xml | sed -E -e s/'(<Language>)|(<\/Language>)'//g )"
      printf '%-20s %-30s\n' "$langCode" "$langDesc"
    done
    return 0
}
downloadCatalog() {
	local wDir
	local editionType
	local showMeter
	local retVal
	local edQuery
	local editionName
	
	wDir=$1
	editionType=$2
	showMeter="--no-progress-meter"
	
	if [ ! -d $wDir ]; then
		echo "ERROR: $wDir is expected to exist for downloadCatalog but doesn't"
		echo "Please report this error"
		exit 1
	fi
	
	#
	# Download and process the Windows Product Catalog so we know what languages are available
	# and the URLs for the downloads
	#
	
	if [ $editionType -eq 0 ]; then
		editionName="Consumer (Home/Pro)"
	else
		editionName="Business (Pro/Enterprise)"
	fi
	
	echo "\nPlease wait while information is being downloaded from Microsoft for the $editionName ESDs"
	
	verboseOn && showMeter=""
	curl -L "https://go.microsoft.com/fwlink?linkid=2156292" $showMeter -o $wDir/catalog.cab
	retVal=$?
	if [ $retVal -ne 0 ]; then
		return $retVal
	fi
	( cd $wDir; tar xf catalog.cab products.xml; sed -i .bak 's/\r//' products.xml )

	
	#
	# Get only the W11 Pro ARM64 products
	#
	echo '<Catalog>' > $wDir/w11arm_products.xml
	if [ $editionType -eq 0 ]; then
		edQuery='//File[Architecture="ARM64"][Edition="Professional"]'
	else
		edQuery='//File[Architecture="ARM64"][Edition="Enterprise"]'
	fi
	
	xpath -q -n -e $edQuery $wDir/products.xml >> $wDir/w11arm_products.xml
	
	echo '</Catalog>'>> $wDir/w11arm_products.xml

	#
	# Get the available languages
	# 
	
	langCodes=$(xpath -q -n -e '//File/LanguageCode' $wDir/w11arm_products.xml | sed -E -e s/"<[\/]?LanguageCode>"//g | sort)
	echo "Processing complete"
	return 0
}

setupEsdDownload(){

###################
# Find the desired language variant file 
#
# Now that we know we have an image available in the desired language,
# build the file names for the download URL (from the Microsoft catalog info),
# the file name for the ESD that resides in the working directory
# and the name of the ISO we're going to generate
###################
	
	xpath -q -n -e '//File[LanguageCode="'$esdLang'"]' $workingDir/w11arm_products.xml >$workingDir/esd_edition.xml
	esdURL=$(xpath -n -q -e '//FilePath' $workingDir/esd_edition.xml | sed -E -e s/'(<FilePath>)|(<\/FilePath>)'//g)
	buildName=$(xpath -n -q -e '//FileName' $workingDir/esd_edition.xml | sed -E -e s/'(<FileName>)|(\.esd<[\/]FileName>)'//g)

	esdFile=$workingDir/${buildName}.esd
	isoFile=./${buildName}.iso

	if verboseOn ; then
	    echo "\nesdURL = $esdURL"
	    echo "buildName = $buildName"
	    echo "esdFile = $esdFile"
	    echo "isoFile = $isoFile/n"
	fi

	echo "Selected language of the ISO is $esdLang \c"
	xpath -n -q -e '//Language' $workingDir/esd_edition.xml | sed -E -e s/'(<Language>)|(<\/Language>)'//g
	verboseOn && echo "The ESD will be downloaded from\n$esdURL"
	echo "The generated ISO will be $isoFile"
	return 0
}

downloadEsd() {

	local retVal
	local retryCount
	local retryLimit
	local showProgress
	
	retryLimit=20
	retryCount=0
	
	verboseOn && echo "NOTE: Using $downloadApp for ESD download"
	#
	# Get the ESD from Microsoft
	#
	
	if [ $downloadApp = "curl" ]; then
	   showProgress="--progress-bar"
	   verboseOn && showProgress=""
		curl --keepalive-time 300 $showProgress $esdURL -o $esdFile;
		retVal=$?
	else
		showProgress="--summary-interval=0"
	    verboseOn && showProgress="--summary-interval=120"
	    retVal=1
	    while [ $retVal -ne 0 -a $retryCount -lt $retryLimit ]
		do
			retryCount="$((retryCount + 1))"
			echo "ESD Download attempt $retryCount"
			aria2c $showProgress -d $workingDir --file-allocation=none $esdURL
			retVal=$?
			if [ $retVal -ne 0 ]; then
				echo "Download interrupted, \c"
				if [ $retryCount -eq $retryLimit ]; then
					echo "retry limit reached"
				else
					echo "retrying"
				fi
			fi
		done
	fi
	if [ $retVal -eq 0 ]; then
		verboseOn && wiminfo $esdFile
	fi
	return $retVal
}

extractEsd(){	
	
	local eFile
	local eDir
	local retVal
	local esdImageCount
	local bootWimFile
	local installWimFile
	local images
	local imageIndex
	local imageEdition
	local beQuiet
	
	eFile=$1
	eDir=$2
	beQuiet="--quiet"
	bootWimFile=$eDir/sources/boot.wim
	installWimFile=$eDir/sources/install.wim
	images="4 5"
	
	verboseOn && beQuiet=""
	
	esdImageCount=$(wiminfo $eFile | awk '/Image Count:/ {print $3}')
	verboseOn && echo "image count in ESD: $esdImageCount"

	#
	# Extract image 1 in the ESD to create the boot environment
	#

	echo "\nApplying boot files to the image"
	wimapply $eFile 1 $eDir $beQuiet 2>/dev/null
	retVal=$?
	if [ $retVal -ne 0 ]; then
		echo "ERROR: Extract of boot files failed"
		return $retVal
	fi

	echo "Files applied"

	################
	# Create the boot.wim file that contains WinPE and Windows Setup
	# Images 2 and 3 in the ESD contain these components
	#
	# Important: image 3 in the ESD must be marked as bootable when
	# transferred to boot.wim or else the installer will fail
	################

	echo "\nAdding WinPE and Windows Setup to the image"
	wimexport $eFile 2 $bootWimFile --compress=LZX --chunk-size 32K $beQuiet
	retVal=$?
	if [ $retVal -ne 0 ]; then
		echo "ERROR: Add of WinPE failed"
		return $retVal
	fi

	wimexport $eFile 3 $bootWimFile --compress=LZX --chunk-size 32K --boot $beQuiet
	retVal=$?
	if [ $retVal -ne 0 ]; then
		echo "ERROR: Add of Windows Setup failed"
		return $retVal
	fi
	echo "Files added to image"
	
	verboseOn && wiminfo  $bootWimFile

	echo "\nAdding Windows editions to image"

	################
	# Create the install.wim file that contains the files that Setup will install
	# Images 4, 5, (and 6 if it exists) in the ESD contain these components
	################
	

	[ $esdImageCount -eq 6 ] && images="$images 6"
	
	for imageIndex in $images; do
		imageEdition="$(wiminfo $eFile $imageIndex | grep '^Description:' | sed 's/Description:[ \t]*//')"
		echo "\tAdding $imageEdition to the image"
		wimexport $eFile $imageIndex $installWimFile --compress=LZMS --chunk-size 128K $beQuiet
		retVal=$?
		if [ $retVal -ne 0 ]; then
			echo "ERROR: Addition of $imageIndex to the image failed"
			return $retVal
		fi
	done

	echo "All Windows editions added to image"	
	
	verboseOn && wiminfo $installWimFile

	return 0
}

buildIso(){
	local iDir=$1
	local iFile=$2
	local elToritoBootFile
	
	iDir=$1
	iFile=$2
	
	if [ -e $iFile ]; then
	  echo "\tWARNING: File $iFile exists, removing it"
	  rm -rf $iFile
	fi

	elToritoBootFile=$iDir/efi/microsoft/boot/efisys.bin
	
	#
	# Create the ISO file
	#

	hdiutil makehybrid -o $iFile -iso -udf -hard-disk-boot -eltorito-boot $elToritoBootFile $iDir
	return $?
}


#-------------------
#
# Start of program
#
#-------------------


#-------------------
# 
# Process arguments
# 
#-------------------

while getopts ":abhlr:vV" opt; do
  case $opt in
    a)
    	aOption=1
    	;;
    b)
    	bOption=1
    	;;
    h)
    	usage
    	exit 1
    	;;

    r)
    	rOption=1
    	workingDir=$OPTARG
    	;;
    l)
    	lOption=1
    	;;
	v)
    	verbosityLevel=$((verbosityLevel + 1))
    	;;
	V)
    	printVersion
    	exit 1
    	;;
    :)
    	echo "Option -$OPTARG requires an argument"
    	usage
    	exit 1
    	;;
    
    \?)
    	echo "Invalid option: -$OPTARG\n"
    	usage
    	exit 1
    	;;
    esac
done
shift "$((OPTIND-1))"


verboseOn && printVersion


#-------------------
#
# Check number of arguments
# One argument is allowed when not using the -r option for restart
# If using the -r or -l options no arguments are allowed
#
#-------------------

if [ $# -gt 1 ]; then
	echo "ERROR: Too many arguments"
	usage
	exit 1
fi

if [ $rOption -eq 0 -a $lOption -eq 0 ]; then
	if [ $# -lt 1 ]; then
		echo "ERROR: esd-language argument is required"
		usage
		exit 1
	fi
fi
if [ $rOption -eq 1 ]; then
	if [ $lOption -eq 1 ]; then
		echo "ERROR: the -l option can not be used with the -r option"
		usage
		exit 1
	fi
	if [ $# -eq 1 ]; then
		echo "ERROR: too many arguments when using -r option"
		usage
		exit 1
	fi
	if [ $aOption -eq 1 ]; then
		echo "NOTE: -a option is implied with -r, no need to specify it"
	fi;
	aOption=1
fi
if [ $lOption -eq 1 ]; then
	if [ $rOption -eq 1  -o  $aOption -eq 1  ]; then
		echo "ERROR: the -a and -r options can not be used with the -l option"
		usage
		exit 1
	fi
	if [ $# -eq 1 ]; then
		echo "ERROR: too many arguments when using -l option"
		usage
		exit 1
	fi
fi

#-------------------
# Check for for wiminfo, wimapply and wimexport 
#
# all of these are from open source package wimlib
# Warn the user if any of them are not here and abort
#-------------------

cmdPath=""
for utilPath in "/opt/homebrew/bin" "/opt/local/bin" "/usr/local/bin"; do
	if [ -d "$utilPath" ]; then
		cmdPath="${utilPath}"
		verboseOn && echo "Utility path is $utilPath"
		break
	fi;
done
if [ "x$cmdPath" = "x" ]; then
	echo "ERROR: Neither Homebrew or MacPorts appear to be installed"
	echo "Please install one of them and then install required packages"
	exit 1
fi

# 
# If for some reason the user has installed Homebrew or MacPorts, but has not
# put the base directory into $PATH, lets do it for them
#

echo $PATH | grep -E "$cmdPath"'((:)|($))'
if [ $? -ne 0 ]; then
	verboseOn && echo "NOTE: $cmdPath exists, but isn't on shell's PATH. Adding it."
	PATH="${cmdPath}:${PATH}"
	verboseOn && echo "Path is now set to $PATH"	
fi

notFound=0
for i in $requires; do
    which -s $i
    if [ $? -ne 0 ]; then
      echo "ERROR: Required program $i not found"
      notFound=1
    fi
done
if [ $notFound -eq 1 ]; then
      echo "Please install required packages from Homebrew or MacPorts"
      exit 1
fi 

#-------------------
#
# If the -a option was specified, see if aria2c exists
# If we are doing a restart and aria2c doesn't exist, error out since a restartable
# download can only occur with aria2c
# If we aren't doing a restart and aria2c doesn't exist, then default back to curl
#
#-------------------

downloadApp="curl"
if [ $aOption -eq 1 ]; then
	which -s aria2c
	if [ $? -eq 0 ]; then
		downloadApp="aria2c"
	else
		if [ $rOption -eq 1 ]; then
			echo "ERROR: Download restart requested, but aria2c can not be found"
			echo "Restart can not be performed"
			exit 2
		else
		    echo "WARNING: aria2c not found, -a option ignored"
		    aOption=0
		fi
   	fi
fi

if [ $rOption -eq 0 -o $lOption -eq 1 ]; then
	################
	#
	# If normal processing or the -l option has been specified:
	#
	# 	Make a temp in the current working directory where we're going to do all of our work
	# 	Download the catalog after the temp directory has been created
	#
	################

	workingDir="$(mktemp -q -d ./esd2iso_temp.XXXXXX)"
	if [ $? -ne 0 ]; then
		echo "Unable to create work directory, exiting"
		exit 1
	fi
	downloadCatalog $workingDir $bOption
	retVal=$?
	if [ ! $retVal ]; then
		echo "ERROR: Catalog download failed with error $retVal"
		rm -rf $workingDir
		exit 1
	fi
fi

if [ $lOption -eq 1 ]; then
	printLanguages
	rm -rf $workingDir
    exit 1
fi 

if [ $rOption -eq 0 ]; then

	################
	#
	# Normal processing, no restart
	#
	################
		
	freeSpace=$(df -g . | awk '/dev.*/ {print $4}')
	verboseOn && echo "Free space is $freeSpace GB"
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
    
	################
	#
	# extDir is the "extract directory" where we're going to extract the ESD 
	# and evenutally build the ISO from. It's a subdirectory of the working/temp directory
	#
	################

	extDir=$workingDir/ESD_ISO
	mkdir $extDir

	esdLang=$(echo $1 | tr "[:upper:]" "[:lower:]")

	if [ $esdLang != $1 ]; then
		echo "NOTE: Language tag $1 has been converted to lower case"
	fi

	################
	#
	# Verify that the language is supported by Windows
	#
	################
	
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
	  rm -rf $workingDir
      exit 1
	fi
	
	echo "...verified"

	echo "\nStep 1: Getting information about the requested $esdLang ESD file\n"
	setupEsdDownload
	echo "\nStep 1 complete"

	echo "\nStep 2: Downloading ESD from Microsoft with $downloadApp"
	downloadEsd
	retVal=$?
	if [ $retVal -ne 0 ]; then
		echo  "ERROR: ESD download interrupted with error $retVal"
		if [ $aOption -eq 1 ]; then 
			################
			#
			# Write out values of variables that we'll need for restart
			# in a flag file restartOK that we set in the work directory
			#
			################
			
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
	################
	#
	# Restart option selected
	#
	################
	
	################
	#
	# See if the work directory exists and if it supports restart
	#
	################
	
	if [ ! -d $workingDir ]; then
		echo "ERROR:Work directory $workingDir does not exist, exiting"
		exit 2
	fi
	if [ ! -f "$workingDir/restartOK" ]; then
		echo "ERROR: The work directory $workingDir does not support restart, exiting"
		exit 2
	fi;
	echo "\nRestarting interrupted download using work directory $workingDir\n"

	################
	#
	# Read variables needed for restart from the restartOK file
	#
	################
	
	extDir=$workingDir/ESD_ISO
	isoFile=$(cat $workingDir/restartOK | awk '/isoFile/ { print $2 }')
	esdFile=$(cat $workingDir/restartOK | awk '/esdFile/ { print $2 }')
	esdURL=$(cat $workingDir/restartOK | awk '/esdURL/ { print $2 }')

	if verboseOn ; then
	    echo "\nesdURL = $esdURL"
	    echo "esdFile = $esdFile"
	    echo "isoFile = $isoFile/n"
	fi

	echo "Restarting Step 2: Downloading ESD from Microsoft with $downloadApp"
	downloadEsd
	retVal=$?
	if [ $retVal -ne 0 ]; then
		echo  "ERROR: ESD download failed with error $retVal"
		echo "ESD download can be restarted with the following command:"
		echo "$0 -r $workingDir"
		exit 1
	else
		rm $workingDir/restartOK
	fi
fi

################
#
# Regardless of whether restart was asked for or not, at this point
# we have an ESD downloaded. 
#
################
	
echo "\nStep 2 complete - ESD downloaded"	
# echo "no need to build anything further -we know that works"
# rm -rf $workingDir
# exit 0
	
echo "\nStep 3: Building installation image from ESD distribution"
extractEsd $esdFile $extDir
retVal=$?
if [ $retVal -ne 0 ]; then
	echo "Installation image build failed with error code $retVal"
	echo "Work directory $workingDir was not deleted, use for debugging"
	exit 1
fi
echo "\nStep 3 complete - installation image built"

echo "\nStep 4: Creating ISO $isoFile from the installation image\n"
if buildIso $extDir $isoFile ; then
    echo "Step 4 complete - ISO created"
else
    echo "ERROR: ISO was NOT created"
    echo "Working directory $workingDir was not deleted, use for debugging"
    exit 1
fi

echo "\nCleaning up work directory"
rm -rf $workingDir
echo "Done!"
exit 0
