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
			local ip=`echo $i | cut -d\_ -f1`; 
			local name=`cat -v cluster_*/clusterInfo/platformInfo.txt | egrep "Host: \[\/$ip\]" -B2 | head -n1 | cut -d\- -f2- | cut -d\^ -f1 | tr '[:upper:]' '[:lower:]'`; 
			echo "Renaming $i to use $name instead of $ip"; 
            mv $i $name"_"`echo $i | cut -d\_ -f2-`; 
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