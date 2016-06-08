#!/bin/bash
############################################
# detect if there are any zip files that start with a set of digits that are kind of like an IP
# if there are any that start with an IP we'll try to rename them from the cluster bundle
############################################
function vropsRenameZips() {
	if [ `ls | grep -E ^"([0-9]{1,3}[\.]){3}[0-9]{1,3}" | wc -l` -gt 0 ];then
	        echo "Log bundle dected with IP instead of node name, therefore renaming.";
		unzip cluster*.zip -d `ls cluster*.zip | cut -d\_ -f1-2` > unzip.log;
		rm unzip.log;
		rm cluster*.zip;
		for i in `ls | grep -E ^"([0-9]{1,3}[\.]){3}[0-9]{1,3}"`; 
		do
			ip=`echo $i | cut -d\_ -f1`; 
			name=`egrep $ip cluster*/clusterInfo/platformInfo.txt | head -n1 | cut -d\: -f1 | cut -d\- -f2-`; 
			echo "Rename $i to `echo $name | tr '[:upper:]' '[:lower:]'`""_"`echo $i | cut -d\_ -f2-`; 
			mv $i `echo $name | tr '[:upper:]' '[:lower:]'`"_"`echo $i | cut -d\_ -f2-`; 
		done;
	fi
}

############################################
# unzips any zip file in the current directory
############################################
function vropsUnzip() {
if [ `ls | egrep zip$ | wc -l` -gt 0 ];then
        if [ `ls | grep cluster*.zip | wc -l` -gt 0 ];then
		unzip cluster*.zip -d `ls cluster*.zip | cut -d\_ -f1-2` > unzip.log;
	        rm unzip.log;
	        rm cluster*.zip;
	fi
	echo "There are zip files in the current directory, so unpacking them.";
	for i in `ls *.zip`;
	do
		# show what file we are on
	        echo " > $i";
       		# unzip the file
	        unzip $i -d `echo $i | cut -d\_ -f1` > `echo $i | cut -d\_ -f1`.log;
       		# remove the original files and the log file
        	rm $i;
        	rm `echo $i | cut -d\_ -f1`.log;
	done
	echo "All files unzipped.";
else
	echo "There are no zipped files in the directory";
fi
echo "";
};

############################################
# if a log bundle was passed, extract it
############################################
function bundleCheck() {
local bundleWithArgs=( $1 );
local bundle="${bundleWithArgs[0]}";
shift;

if [ ! -z "$bundle" ];then
        bundleTimeEpochA=`echo $bundle | cut -d\_ -f2`;
        bundleTimeEpoch=`expr $bundleTimeEpochA / 1000`;
        bundleDate=`date -d @$bundleTimeEpoch +%Y-%m-%d`;
	echo "A log bundle was passed to the script, extracting to directory $bundleDate.";
	unzip $bundle -d $bundleDate-$bundleTimeEpoch;
        cd $bundleDate-$bundleTimeEpoch;
	echo "The current working directory is:";
	pwd;
else
	echo "No bundle was passed, assuming current directory as pwd.";
fi
}

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
