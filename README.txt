README for w11arm_esd2iso 1.0 (1-Mar-2023)

This script is designed to create ISO installation media for Windows 11 ARM on macOS from ESD
files in Microsoft's software distribution infrastructure.
Use this ISO file to install Windows 11 virtual machines on VMware Fusion 13 on Apple Silicon. 

This script will not be necessary when either Microsoft provides a Windows 11 ARM ISO 
for end-user download or VMware provides a way to create the ISO in their Fusion product like
Parallels does.

Contents of the downloaded zip file:

	- README - contains more info on the script, including a man(1) like reference
	- w11arm_esd2iso.sh

NAME
	w11arm_esd2iso.sh - build Windows 11 ARM ISOs from Microsoft ESD files

SYNOPSIS
	w11arm_esd2iso.sh [-a] [-v] [-h] language-tag
	w11arm_esd2iso.sh -r work-dir
	w11arm_esd2iso.sh -l

DESCRIPTION
	In the first form, w11arm_esd2iso downloads the the ESD file for Windows 11 ARM 22H2
	Professional (includes Windows 11 Home) for the selected language-tag from Microsoft,
	and converts it to ISO. This ISO can be used to install Windows 11 ARM on physical
	or virtual machines.
	
	The generated ISO file is placed in the current working directory. The script
	will display the name of the generated ISO file.
	
	In the second form, the script resumes a failed network transfer of the ESD
	from Microsoft and continues the ISO build process. 
	
	In the third form, the script prints a list of recognized Windows 11 language tags.
	These tags can be used for the language-tag specification in the first form of the
	script. 
	
OPTIONS
	-a		
	    Use aria2c for download of the ESD file instead of curl.  

	-h		
	    Print usage and exit

	-l
	    Print a list of valid language-tags and their corresponding languages

	-r work-dir
	    Resume an interrupted ESD download using the information from the work directory
	    "work-dir". Restart is only available when the original download attempt was
	    performed with the -a option.
			
  	-v	
  		Enable verbose output. Use only when providing debugging output.

FILES
	./esd2iso_work.*	Work directory for ESD download and image creation,
				located in the current working directory.

				This directory will be deleted upon successful ISO
				creation and when most errors are encountered. It
				will not be deleted if a transfer of the ESD can be
				restarted, or if the final phase of the ESD creation
				fails.  
	
DEPENDENCIES
	w11arm_esd2iso.sh depends on utilities found in the open-source wimlib package,
	and expects those utilities to be accessible through $PATH. The wimlib package
	can be installed from either Homebrew or MacPorts.
	
	If the -a option is used to optionally use aria2c instead of curl for the
	download of the ESD from Microsoft, the open-source aria2 packages must be
	installed from either Homebrew or MacPorts.
	
EXIT STATUS

	0		Successful creation of the ISO file
	Non-zero 	Unsuccessful creation of the ISO file
	
NOTES
	The script must be made executable after extraction from the zip file.

	Have at least 15GB of free disk space to run this script. The script will check 
	for what it considers to be sufficient space and will refuse to run if it isn't
	available. 
	
	This script only builds ISO media for Windows 11 ARM Professional, which includes 
	Windows 11 Home. It does not build media for any other Windows version, architecture,
	or edition.

	More complete guidance on the use of this script to create Windows 11 SO media 
	suitable for use with VMware Fusion 13 on Apple Silicon can be found in the 
	Unofficial Fusion 13 for Apple Silicon Companion Guide which is found at
	https://communities.vmware.com/t5/VMware-Fusion-Documents/The-Unofficial-Fusion-13-for-Apple-Silicon-Companion-Guide/ta-p/2939907

	Consider running with the -a option to use aria2c to download the ESD. 
	aria2c seems to have better resiliency to network conditions than using the curl 
	method.

AUTHOR
	Paul Rockwell (@Technogeezer on VMware Fusion Discussions forum)
	
CREDITS
	Information for obtaining Microsoft ESD distributions and
	Microsoft Product catalog from b0gdanw "ESD to ISO on macOS.txt" 
	https://gist.github.com/b0gdanw/e36ea84828dbd19e03eff6158f1fc77c

LICENSE
	This script is free software and is provided AS-IS. NO WARRANTIES
	OR GUARANTEES, EXPRESS OR IMPLIED, ARE PROVIDED. USE AT YOUR OWN RISK.
	
SUPPORT
	No production level support is available for this script. The author only
	provides best effort response to any issues with no service level targets.
	
	Any questions about this script should be posted to the VMware Fusion Discussions 
	forum: https://communities.vmware.com/t5/VMware-Fusion/ct-p/3005-home

	If you find an error please run the script with the -v option, then attach the entire
	output of the script in a zip file to your post.
	

