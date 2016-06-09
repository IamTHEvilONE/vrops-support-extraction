# vrops-support-extraction
The purpose of this application is to extract and perform basic reporting on a vRealize Operations support bundle.

#  Usage
vrops-bundle-report.sh <support bundle tarball>
- when a tarball is passed into the utility, it wille extract all files to a temporary directory
- when a tarball is not passed into the utility, the assumption is that the support bundle was extracted to the current directory 

# Requirements
1. Cluster information is required, which means you need to include the current master node in the support bundle.
2. Light bundles may omit some data, so most testing is done on a Full Support Bundle from all nodes (excluding Remote Collectors)
