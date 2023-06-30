% W11ARM_ESD2ISO(1) w11arm_esd2iso 4.0
% Paul Rockwell (@Technogeezer on VMware Fusion forum)
% June 2023

# NAME
w11arm_esd2iso - utility to build Windows 11 ARM ISOs from Microsoft ESD files

# SYNOPSIS
**w11arm_esd2iso** [-v]\
**w11arm_esd2iso** [-v] -r *work-dir*\
**w11arm_esd2iso** [-Vh]

# DESCRIPTION
In the first form, a Windows 11 ARM 22H2 ESD (Electronic 
Software Distribution) file is downloaded from Microsoft,
and converted to ISO. This ISO can be used to install Windows 11 ARM on physical
or virtual machines.
	
The utility will prompt for the type of ISO to produce 
(either Home/Pro or Pro/Enterprise) and the language for the created ISO. A list of
available languages will be provided to assist in making the ISO language selection. 

The generated ISO file is placed in the current working directory. The utility
will display the name of the generated ISO file.

In the second form, an interrupted network transfer of the ESD
from Microsoft is resumed from the point of interruption and the ISO build process
will continue. The *work-dir* argument is required, 
and is expected to be a work directory created from a prior failed run of the utility.

In the third form, the utility will either print out it's version or a synopsis of 
command line options, and immediately exit without performing any ISO build.
	
# OPTIONS

**-h**		
: Print a synopsis of usage and exit

**-r** *work-dir*
: Resume an interrupted ESD download using the information from the work directory
*work-dir*. 
	
**-v**	
: Enable verbose output. Use only when providing debugging output.

**-V**	
: Print the version of the utility and exit.


# FILES
./esd2iso_work.*	
: Work directory for ESD download and image creation, located in the current 
working directory.


# DEPENDENCIES
w11arm_esd2iso requires an Apple Silicon (M1/M2) Macs running macOS 13 (Ventura) or later.

Starting with version 3.0, w11arm_esd2iso no longer requires the installation of 
open-source utilities from Homebrew or MacPorts. 
All required utilities are provided in the distribution zip file.

# EXIT VALUES
**0**
: Successful creation of the ISO file

**Non-zero** 
: Unsuccessful creation of the ISO file
	
# NOTES


There are no intentions to make this script run on Windows or Intel Macs.

w11arm_esd2iso only builds ISO media for Windows 11 ARM 22H2. It does not build media 
for any other versions of Windows or Windows Server.

The current working directory must be changed to the directory where the distribution zip
file of w11arm_esd2iso was extracted. The utility must be executed from that directory 
otherwise the required bundled components will not be found. 

Have at least 12 GB of free disk space to run w11arm_esd2iso. Checks are performed for
sufficient disk space and the utility will refuse to run if space isn't available.
available. 

The w11arm_esd2iso utility contains bundled versions of the open-source wimlib-imagex(1) and 
aria2c(1) utilities. These will be used if the utilities are not found to be installed
with Homebrew/MacPorts. This is done for ease of use - the user 
does not have to go through the complexity of installing Xcode command line tools, 
Homebrew/MacPorts, and the packages containing these utilities. Im the unlikely event that 
existing user-installed versions of aria2c and wimlib-imagex present a problem, 
an uninstall of Homebrew/MacPorts is not necessary. The default behavior of using the 
bundled utilites can be restored by removing the Homebrew/MacPorts binary directory from 
the $PATH variable of the shell being used to
run w11arm_esd2iso. 

The work directory will be deleted upon successful ISO creation and when most 
errors are encountered. It will not be deleted if a transfer of the ESD can be
restarted using the -r option, or if the final phase of the ESD creation
fails.  

The command line syntax has changed starting with V4.0 and is not 100% compatible with 
V3.0.1 and earlier. The functions provided by command line options and arguments are now
provided by interactively prompting the user during the build process. 

The -a option has been removed as aria2c(1) is now used for all downloads. 

w11arm_esd2iso automatically enables retry and restart features that handle the interruption 
of ESD downloads from Microsoft due to network connectivity issues.  The 
utility will automatically retry an interrupted download up to 20 times. After 20 retries,
the utility will exit, and will display a command (containing the -r option) that can be 
copy/pasted to resume the ESD download. 

The -r option can be used as many times as necessary as directed by the utility to 
complete the download. In all honesty, it shouldn't need to be used more than 
once unless you have a really, really bad network connection. Each restart attempt
using the -r option will resume a download from the point of interruption of the
last execution of the utility. 
			
More extensive guidance on the use of w11arm_esd2iso to create Windows 11 ARM virtual
machines with VMware Fusion 13 on Apple Silicon can be found in the 
Unofficial Fusion 13 for Apple Silicon Companion Guide which can be found at
https://communities.vmware.com/t5/VMware-Fusion-Documents/The-Unofficial-Fusion-13-for-Apple-Silicon-Companion-Guide/ta-p/2939907

# EXAMPLES

**./w11arm_esd2iso**
: Download and build a Windows 11 ARM ISO. The user will be prompted for both the type
of ISO to create, and the language of the ISO. 

**./w11arm_esd2iso -r ./esd2iso_work.abcdef**
: Restart a interrupted download from the point of interruption using the
work directory ./esd2iso_work.abcdef left behind from a previous run of the utility.

# SEE ALSO
wimlib-imagex(1), aria2c(1), hdiutil(1)

# CREDITS
Information for obtaining Microsoft ESD distributions and
Microsoft Product catalog from b0gdanw "ESD to ISO on macOS.txt" 
https://gist.github.com/b0gdanw/e36ea84828dbd19e03eff6158f1fc77c

# LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
	
# SUPPORT
No production level support is available for this script. The author 
provides best effort response to any issues with no service level targets.

Any questions about this utility should be posted to the VMware Fusion Discussions 
forum: https://communities.vmware.com/t5/VMware-Fusion/ct-p/3005-home

If you find an error please run the utility with the -v option, then attach the entire
output of the utility in a zip file to your post.
