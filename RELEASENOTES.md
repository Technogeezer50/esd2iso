# w11arm_esd2iso 5.0.2 Release Notes

w11arm_esd2iso | 5.0.2 build 20231125

v5.0.2 is a bug-fix release to w11arm_esd2iso v5.0.

## What's changed?

### What's changed in 5.0.2

* Issue #1: Fix errors in builds of Win 11 23H2 ISOs when running with a Debian or 
Fedora-derived mkisofs (non-Jorg "Schily" Schilling fork). Add -allow-limited-size 
argument for these versions that allows install.wim in the ISO
to exceed 4GB in size.

* Additional feedback to the user after selection of the
edition while the available languages for that edition are being determined. Otherwise the
user will think that nothing is going on. 

### What's changed in 5.0.1

* Re-working of README.md file. 
* Move of the how-to-use documentation into file USAGE.txt.

### What's changed in 5.0.0

* Generic version. Will run on both macOS (Darwin) and many Linux distos. Almost all Mac specific
things have been removed
	
* First version to be posted to GitHub. No longer available on VMware Fusion Documents site.

* Unlike the Mac-specific download formerly available on the VMwrae Fusion site, this version
requires the user to install some utilities on both Linux and Mac systems. 
