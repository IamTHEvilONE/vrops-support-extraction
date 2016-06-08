#!/bin/bash
# Locate current location of the pull from github
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
# Import the extraction module
. "$DIR/vrops-support-extraction.sh"

###########################
## Main Function
###########################
# Check to see if a bundle was passed to this script
bundleCheck $1;
# Rename the zips if any of the nodes is known by IP address
vropsRenameZips;
# Unzip the zip files if required
vropsUnzip;

bundleTimeEpochA=`ls | grep cluster | cut -d\_ -f2`;
bundleTimeEpoch=`expr $bundleTimeEpochA / 1000`;
# echo $bundleTimeEpoch;
bundleTime=`date -d @$bundleTimeEpoch`;
bundleDate=`date -d @$bundleTimeEpoch +%Y-%m-%d`;
# echo $bundleTime;
echo "$bundleDate / $bundleTime - $bundleTimeEpoch";

# Generate the list of node names based on the folders in the directory
nodes=`ls | grep -v cluster`;

echo "--== Bundle Info ==--">>01-basicinfo.txt;
# what time was the bundle collected
echo "The Support Bundle was created on $bundleTime" >> 01-basicinfo.txt;
echo "">>01-basicinfo.txt;

# what are the deployed builds?
echo "What build numbers are in each node?" >> 01-basicinfo.txt;
egrep RELEASENUMBER */slice-info/conf/.buildInfo >> 01-basicinfo.txt;
echo "">>01-basicinfo.txt;

# Locate the pak files that have been installed and then put them out to screen
echo "What pak files are installed in the cluster? (Full Bundle maybe needed)" >> 01-basicinfo.txt;
find . | grep pak | grep webapp | grep json | cut -d\_ -f4-| cut -d\. -f1 | sort -u >> 01-basicinfo.txt;
echo "">>01-basicinfo.txt;

echo "Rundown of each Node, in no particular order">> 01-basicinfo.txt;
for node in $nodes
do
isNodeRC=`sed -nre 's/^remotecollectorroleenabled\s*=\s*(.+)\s*/\1/p' $node/slice-info/conf/utilities/sliceConfiguration/data/roleState.properties`;

# processor count/speed
        echo "--== $node ==--" >>01-basicinfo.txt;
	vropsMajorVersion=`egrep RELEASENUMBER $node/slice-info/conf/.buildInfo | cut -d\: -f2- | cut -d\. -f1-3`;
	vropsBuildNumber=`egrep RELEASENUMBER $node/slice-info/conf/.buildInfo | cut -d\. -f4`;
	echo "Version & Build: $vropsMajorVersion $vropsBuildNumber" >> 01-basicinfo.txt;
	nodeUUID=`egrep "slicedinstanceid =" $node/slice-info/conf/utilities/sliceConfiguration/data/platformState.properties | cut -d\  -f3`
        echo "Node UUID: $nodeUUID" >> 01-basicinfo.txt;
	egrep "enabled = " $node/slice-info/conf/utilities/sliceConfiguration/data/roleState.properties >> 01-basicinfo.txt;
	echo "Processor Model:" `egrep "model name" $node/sysenv/cpuInfo.txt | tail -n1 | cut -d\: -f2-` >> 01-basicinfo.txt;
        echo "Processor Count:" `egrep "processor" $node/sysenv/cpuInfo.txt | wc -l` >> 01-basicinfo.txt;
	egrep "MemTotal" $node/sysenv/memInfo.txt | sort -u>> 01-basicinfo.txt;
	grep  data-db $node/sysenv/df.txt >>01-basicinfo.txt;
        echo "">> 01-basicinfo.txt;
	head $node/sysenv/top.txt |tail -n6>>01-basicinfo.txt;
	
	echo "">> 01-basicinfo.txt;
done

less 01-basicinfo.txt;
