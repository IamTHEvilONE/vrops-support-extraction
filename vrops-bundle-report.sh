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

#Once extracted, set some variables
bundleTimeEpochA=`ls | grep cluster | cut -d\_ -f2`;
bundleTimeEpoch=`expr $bundleTimeEpochA / 1000`;
bundleTime=`date -d @$bundleTimeEpoch`;
bundleDate=`date -d @$bundleTimeEpoch +%Y-%m-%d`;
# echo "$bundleDate / $bundleTime - $bundleTimeEpoch";

# Generate the list of node names based on the folders in the directory
nodes=`ls | grep -v cluster`;

# Generate the report header
reportHeader $bundleTime;
# Get build info
reportBuildsAndPaks;
# generate node specs
reportNodeSpecs $nodes;
# view the report
less $reportName;
