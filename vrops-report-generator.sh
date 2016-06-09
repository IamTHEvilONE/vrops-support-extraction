#!/bin/bash
# define the report filename
report="00-vROpsSupportBundleReport.txt";
errorLog="errorReport.txt";

############################################
# Create the header, requires $bundleTime
############################################
function reportHeader() {
local importedArgs=( $1 );
local bundleTime="${importedArgs[0]}";
shift;

echo "#####################################################" >> $report;
echo "# vRealize Operations Manager Support Bundle Report #">> $report;
echo "#####################################################" >> $report;
echo "">> $report;

if [ ! -z "$bundleTime" ];then
    echo "--== Bundle Info ==--">> $report;
    # what time was the bundle collected
    echo "The Support Bundle was created on $bundleTime" >> $report;
    echo "">>$report;
else
	echo "Nothing passed to reportHeader" >> $errorLog;
fi
}

############################################
# Report on what Paks are installed
############################################
function reportBuildsAndPaks() {
# local importedArgs=( $1 );
# local bundleTime="${importedArgs[0]}";
# shift;

# what are the deployed builds?
echo "What build numbers are deployed in the cluster? (Supported configs should only show 1 build below)" >> $report;
egrep RELEASENUMBER */slice-info/conf/.buildInfo | awk -F"RELEASENUMBER:" '{ print $2 }' | sort -u >> $report;
echo "">>$report;

# Locate the pak files that have been installed and then put them out to screen
echo "What pak files are installed in the cluster? (Full Bundle suggested)" >> $report;
find . | grep pak | grep webapp | grep json | cut -d\_ -f4-| cut -d\. -f1 | sort -u >> $report;
echo "">>$report;
}

############################################
# Create the header, requires $bundleTime
############################################
function reportNodeSpecs() {
local importedArgs=( $1 );
local nodes="${importedArgs[0]}";
shift;

echo "Rundown of each Node, in no particular order">> $report;
for node in $nodes
do
isNodeRC=`sed -nre 's/^remotecollectorroleenabled\s*=\s*(.+)\s*/\1/p' $node/slice-info/conf/utilities/sliceConfiguration/data/roleState.properties`;

# processor count/speed
        echo "--== $node ==--" >>$report;
	vropsMajorVersion=`egrep RELEASENUMBER $node/slice-info/conf/.buildInfo | cut -d\: -f2- | cut -d\. -f1-3`;
	vropsBuildNumber=`egrep RELEASENUMBER $node/slice-info/conf/.buildInfo | cut -d\. -f4`;
	echo "Version & Build: $vropsMajorVersion $vropsBuildNumber" >> $report;
	nodeUUID=`egrep "slicedinstanceid =" $node/slice-info/conf/utilities/sliceConfiguration/data/platformState.properties | cut -d\  -f3`
        echo "Node UUID: $nodeUUID" >> $report;
	egrep "enabled = " $node/slice-info/conf/utilities/sliceConfiguration/data/roleState.properties >> $report;
	echo "Processor Model:" `egrep "model name" $node/sysenv/cpuInfo.txt | tail -n1 | cut -d\: -f2-` >> $report;
        echo "Processor Count:" `egrep "processor" $node/sysenv/cpuInfo.txt | wc -l` >> $report;
	egrep "MemTotal" $node/sysenv/memInfo.txt | sort -u>> $report;
	grep  data-db $node/sysenv/df.txt >>$report;
        echo "">> $report;
	head $node/sysenv/top.txt |tail -n6>>$report;
	
	echo "">> $report;
done
}
