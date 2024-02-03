# w11arm_esd2iso 

## What is w11arm_esd2iso?

w11arm_esd2iso is a utility to build Windows 11 ARM installation ISOs from Microsoft ESD files.
It was born out of necessity for users of VMware Fusion on Apple Silicon Macs. They needed a way
to easily obtain an installation ISO for Windows 11 ARM because Microsoft does not provide it
via a public download.

The benefits of w11arm_esd2iso over building ISOs from uupdump.net are:

* The ISO is built from a single file downloaded from Microsoft's ESD repositories.
* The downloaded ESD used to build the ISO is Microsoft's latest "retail" installation media.
* The build process uses less working disk space.
* The build is faster from ESD vs. downloading, extracting, and stitching together multiple UUP files.
* It's easier to select the edition and language you need.
* No Windows system required. ISOs can be reliably built on Linux and macOS.

Since this is a command line utility written in the bash shell, it's best suited for
users that are comfortable with working in UNIX/Linux/macOS shell environments and "getting your
hands dirty". If you aren't 
comfortable with this, it's recommended to use "friendlier" mechanisms to 
obtain Windows 11 ARM installation media 
(such as Parallels' and VMware Fusion's built-in tools, or the open source CrystalFetch).

## How is this different than the versions that used to be found on the VMware Fusion Documents forum?

This project was created by the original author of the w11arm_esd2iso utility
as a continuation of the project formerly found on the VMware Fusion Documents forum. It is compatible in operation with
the final version that resided on the VMware sites.

> [!Note]
> w11arm_esd2iso was removed from the VMware Fusion Documents site as of
> 2023-11-15. This is now the official home of the project.

The major differences between this project and the versions previously available on the VMware sites
are:
 
* This project will run on both Intel and Apple Silicon Macs.
* This project should run on most if not all Linux distributions.
* This project requires the user to install the open source utilities that w11arm_esd2iso uses.

## What doesn't w11arm_esd2iso do?

w11arm_esd2iso does not:

* Build media for any other version or architecture of Windows other than Windows 11 ARM.
* Build media for Windows channels other than the release channel. That means you can't 
use it to build Insider Preview, Beta, Dev, or Canary channel releases.

# Compatibility

## What operating systems does w11arm_esd2iso run on?

w11arm_esd2iso is written in the bash shell, and uses open-source utilities. This
allows it to run on:
* macOS 12 Monterey and later (on both Intel and Apple Silicon Macs),
* Relatively recent versions of x64 and arm64 Linux distributions
(It's been tested and found to run on Fedora, Ubuntu, and Debian). 


# Installation and Use 

## How do I install w11arm_esd2iso?

* Download the zip file of the latest release found on GitHub.
* Extract the zip file.
* Move the file w11arm_esd2iso to the location of your choice.
* Change permissions on w11arm_esd2iso to make it executable (it does not require
root permissions).
* Install all required utilities as noted in USAGE.txt.

## How do I use w11arm_esd2iso?

See the file USAGE.txt that's included with the download.

# Licensing

w11arm_esd2iso is Copyright (C) 2023 Paul Rockwell and licensed under the terms of 
the GNU General Public License version 2.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  

See the files COPYING and COPYING.GPLv2 for all the gory details.

# Other

## What if I find a bug or need help?

Bug reporting is something that I'm in the process of figuring out how to handle. Stay tuned.

The utility is written as a bash shell script. If you're fluent in bash shell programming
you can probably find out what's going wrong. 

## Credits

Information for obtaining Microsoft ESD distributions and
Microsoft Product catalog from b0gdanw "ESD to ISO on macOS.txt" 
https://gist.github.com/b0gdanw/e36ea84828dbd19e03eff6158f1fc77c


