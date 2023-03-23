% W11ARM_ESD2ISO(1) w11arm_esd2iso 2.1
% Paul Rockwell (@Technogeezer on VMware Fusion forum)
% March 2023

# NAME
w11arm_esd2iso - build Windows 11 ARM ISOs from Microsoft ESD files

# SYNOPSIS
**w11arm_esd2iso** [-abhvV] *language-tag*\
**w11arm_esd2iso** [-vVh] -r *work-dir*\
**w11arm_esd2iso** [-vVh] -l

# DESCRIPTION
In the first form, a Windows 11 ARM 22H2 ESD (Electronic 
Software Distribution) file for for the language *language-tag* is downloaded from Microsoft,
and converted to ISO. This ISO can be used to install Windows 11 ARM on physical
or virtual machines.
	
By default, a "Consumer" (Home/Pro) ISO will be built. Use the -b option to build
a "Business" (Pro/Enterprise) ISO.

The generated ISO file is placed in the current working directory. The script
will display the name of the generated ISO file.

In the second form, an interrupted network transfer of the ESD
from Microsoft is resumed from the point of interruption and the ISO build process
will continue. The *work-dir* argument is required, 
and is expected to be a work directory created from a prior failed run of the script.

In the third form, the script prints a list of recognized Windows 11 ARM language tags.
These tags can be used for the *language-tag* specification in the first form of the
script. 
	
# OPTIONS
**-a**		
: Use aria2c(1) for download of the ESD file instead of curl(1). 

**-b**		
: Create an ISO for "Business" (Pro/Enterpise) editions rather than "Consumer" (Home/Pro) editions

**-h**		
: Print usage and exit

**-l**
: Print a list of valid language-tags and their corresponding languages and exit.

**-r** *work-dir*
: Resume an interrupted ESD download using the information from the work directory
*work-dir*. 
	
**-v**	
: Enable verbose output. Use only when providing debugging output.

**-V**	
: Print the version of the script and exit.


# FILES
./esd2iso_work.*	
: Work directory for ESD download and image creation, located in the current 
working directory.


# DEPENDENCIES
w11arm_esd2iso depends on utilities found in the open-source wimlib package,
and expects those utilities to be accessible through $PATH. The wimlib package
can be installed from either Homebrew or MacPorts.

If the -a option is used, the open-source aria2 package must be
installed from either Homebrew or MacPorts.
	
# EXIT VALUES
**0**
: Successful creation of the ISO file

**Non-zero** 
: Unsuccessful creation of the ISO file
	
# NOTES
The script may need to be made executable (with chmod +x) after extraction from the zip file.

This script only runs on macOS.

This script only builds ISO media for Windows 11 ARM. It does not build media 
for any other CPU architecture or version of Windows.

Have at least 15GB of free disk space to run this script. The script will check 
for what it considers to be sufficient space and will refuse to run if it isn't
available. 

The work directory will be deleted upon successful ISO creation and when most 
errors are encountered. It will not be deleted if a transfer of the ESD can be
restarted using the -r option, or if the final phase of the ESD creation
fails.  

Without the -a option, an interruption in the download of the ESD due to network
issues will require the entire download to be processed from the beginning.

With the -a option, retry and restart features are enabled that allow a
download to be resumed from the point of interruption.  The script will automatically
retry an interrupted download up to 20 times. After 20 retries, the script will exit, and will display a command 
(containing the -r option) that can be copy/pasted to resume the ESD download. 

The -r option can be used as mamy times as necessary as directed by the script to complete the download. (although in
all honesty, it shouldn't need to be used more than once unless you have a really, really
bad network connection). Each restart attempt
using the -r option will resume a download from the point of interruption of the
last execution of the script. 
			
More extensive guidance on the use of this script to create Windows 11 ARM virtual
machines with VMware Fusion 13 on Apple Silicon can be found in the 
Unofficial Fusion 13 for Apple Silicon Companion Guide which is found at
https://communities.vmware.com/t5/VMware-Fusion-Documents/The-Unofficial-Fusion-13-for-Apple-Silicon-Companion-Guide/ta-p/2939907

# EXAMPLES
**./w11arm_esd2iso -l**
: Display a list of supported Windows 11 ARM languages and their associated
language tags. 

**./w11arm_esd2iso en-us**
: Download and build the en-us (US English) language ISO of Windows 11 ARM. 
No download restart is supported. 

**./w11arm_esd2iso -a en-us**
: Download and build the en-gb (UK English) language ISO of Windows 11 ARM.
Restart of interrupted downloads using the -r option are supported.

**./w11arm_esd2iso -r ./esd2iso_work.abcdef**
: Restart a interrupted download from the point of interruption using the
work directory ./esd2iso_work.abcdef left behind from a previous run of the script 
that used the -a option.

# SEE ALSO
wiminfo(1), wimextract(1), wimapply(1), aria2c(1), curl(1), hdiutil(1)

# CREDITS
Information for obtaining Microsoft ESD distributions and
Microsoft Product catalog from b0gdanw "ESD to ISO on macOS.txt" 
https://gist.github.com/b0gdanw/e36ea84828dbd19e03eff6158f1fc77c

# LICENSE
This script is free software and is provided AS-IS. NO WARRANTIES
OR GUARANTEES, EXPRESS OR IMPLIED, ARE PROVIDED. USE AT YOUR OWN RISK.
	
# SUPPORT
No production level support is available for this script. The author only
provides best effort response to any issues with no service level targets.

Any questions about this script should be posted to the VMware Fusion Discussions 
forum: https://communities.vmware.com/t5/VMware-Fusion/ct-p/3005-home

If you find an error please run the script with the -v option, then attach the entire
output of the script in a zip file to your post.
	
# TODO
Maybe someday this script will run on Linux. There are no
intentions to make this script run on Windows.


	

