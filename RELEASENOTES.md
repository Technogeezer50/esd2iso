# w11arm_esd2iso 5.1.0 Release Notes

w11arm_esd2iso | 5.1.0 build 20260128

v5.1.0 is a minor release of w11arm_esd2iso.

## What's changed?

### What's changed in 5.1.0

* Updated for Windows 11 ARM 25H2.
* Updated for new URL to Microsoft Product Catalog
* ESD checksums are now calculated using SHA256 due to Microsoft product catalog changes.

### What's changed in 5.0.3

* No functional changes.
* Cleanup of files in the project relating to licensing.

* Clarification of requirements for third party utilities needed on macOS.

* Notice in README.md to open an issue in GitHub if a bug is found.

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
