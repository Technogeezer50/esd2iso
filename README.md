# Name
w11arm_esd2iso - a utility to build Windows 11 ARM installation ISOs from Microsoft ESD files

## Summary

This utility creates ISO installation media for Windows 11 ARM from 
ESD files in Microsoft's software distribution infrastructure.
The resulting ISO can be used to install Windows 11 ARM virtual machines on any
virtualization solution that supports arm64 architectures such as VMware Fusion on
Apple Silicon Macs. 

## Changes in version 5.0

First version to be uploaded to its new home on GitHub:
		https://github.com/Technogeezer50/esd2iso
	
This version now runs on Linux distributions.
		
See the CHANGELOG document for changes made in prior versions.

## Command Syntax
**w11arm_esd2iso** [-v]\
**w11arm_esd2iso** [-v] -r *work-dir*\
**w11arm_esd2iso** [-Vh]

## Description
In the first form, a Windows 11 ARM 22H2 ESD (Electronic 
Software Distribution) file is downloaded from Microsoft,
and converted to ISO.
	
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
	
## Command options

**-h**		
: Print a synopsis of usage and exit

**-r** *work-dir*
: Resume an interrupted ESD download using the information from the work directory
*work-dir*. 
	
**-v**	
: Enable verbose output. Use only when providing debugging output.

**-V**	
: Print the version of the utility and exit.


## Files
./esd2iso_work.xxxxxx	
: Work directory for ESD download and image creation, created in the current 
working directory. The directory contains the downloaded ESD file and other files used during creation of the ISO. It will be deleted upon successful creation of the ISO.


## Dependencies
w11arm_esd2iso is written using the BASH shell, and should run on any reasonably current macOS or Linux systems. It should 
run on Intel or arm64 architecture systems.

w11arm_esd2iso requires the followng utilities in order to create the ISO from the Microsoft ESD file:
* xpath
* shasum
* wimlib-imagex
* cabextract
* aria2c
* mkisofs

> [!IMPORTANT]
> Mac users beware. Unlike the versions found on the VMware Fusion Documents site, w11arm_esd2iso does not bundle any of these utilities. You'll need to install them yourself.

### Mac Users
macOS already includes both xpath and shasum. The remaning packages will need to be installed from Homebrew or MacPorts (or compile them yourself from their sources if you are 
so inclined).

To install from Homebrew:
```
brew install wimlib cabextract aria2 cdrtools
```
To install from MacPorts:
```
sudo port install wimlib cabextract aria2 cdrtools
```
### Linux users

For Linux, most of the utilities should be available in your distribution's repos.
Install them using your package manager if not already installed. 

The exact packages to install may vary between distros. If you don't know which packages contain the utility, many
distros will give you a hint if you simply type the command with no arguments. 

## Return codes
**0**	: Successful creation of the ISO file

**Non-zero** 	: Unsuccessful creation of the ISO file
	
## Other Notes

w11arm_esd2iso only builds ISO media for Windows 11 ARM 22H2. It does not build media 
for any other version of Windows or Windows Server.

Have at least 12 GB of free disk space to run w11arm_esd2iso. Checks are performed for
sufficient disk space and the utility will refuse to run if space isn't available.
available. 

The work directory will be deleted upon successful ISO creation and when most 
errors are encountered. It will not be deleted if a transfer of the ESD can be
restarted using the -r option, or if the final phase of the ESD creation
fails.  

If downloads are interrupted due to network issues, the 
utility will automatically retry the download from the point of interruption up to 10 times. After 10 retries,
the utility will exit, and will display a command (containing the -r option) that can be 
copy/pasted to resume the ESD download. 

An interrupted download can be restarted with the  -r option as many times as necessary 
as long as the work directory still exists. In all honesty, it shouldn't need to be used more than 
once unless you have a really, really bad network connection. Each restart attempt
using the -r option will also resume a download from the point of interruption of the
last execution of the utility. 

The downloaded ESD file will be validated against the SHA1 hash 
provided by Microsoft. If the verification fails (indicating a corrupt
download), the utility will exit with an error message.

## Credits
Information for obtaining Microsoft ESD distributions and
Microsoft Product catalog from b0gdanw "ESD to ISO on macOS.txt" 
https://gist.github.com/b0gdanw/e36ea84828dbd19e03eff6158f1fc77c

## Legalese

w11arm_esd2iso is Copyright (C) 2023 Paul Rockwell

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
