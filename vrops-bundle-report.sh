#!/bin/bash
# Locate current location of the pull from github
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
# Import the modules required
. "$DIR/vrops-support-extraction.sh"
. "$DIR/vrops-report-generator.sh"

reportName="00-vROpsSupportBundleReport.txt"

###########################
## Main Function
###########################
# Check to see if a bundle was passed to this script
bundleCheck $1;
# Rename the zips if any of the nodes is known by IP address
vropsRenameZips;
# Unzip the zip files if required
vropsUnzip;

# Generate the report header
reportHeader $reportName;
# Get build info
reportBuildsAndPaks $reportName;
# generate node specs
reportNodeSpecs $reportName;
# view the report
less $reportName;
