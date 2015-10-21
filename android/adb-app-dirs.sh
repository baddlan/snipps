#!/bin/sh
# Use > 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use > 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
# note: if this is set to > 0 the /etc/hosts part is not recognized ( may be a bug )
# 
# Thanks to Bruno Bronosky <http://stackoverflow.com/users/117471/bruno-bronosky>

while [[ $# > 1 ]]
do
	key="$1"

	case $key in
		-s|--device)
	DEVICE="$2"
	shift # past argument
	;;
	-p|--package)
		PACKAGE="$2"
	shift # past argument
	;;
	-f|--directory)
		DIRECTORY="$2"
	shift # past argument
	;;
	--default)
	DEFAULT=YES
	;;
	*)
	# unknown option
	;;
esac
shift # past argument or value
done

if [[ -n $1 ]]; then
	echo "Last line of file specified as non-opt/last argument:"
	tail -1 $1
fi

# Variables and defaults
appPackage=${PACKAGE}
device=${DEVICE:=`adb devices | tail -2 | head -1 | cut -f 1 | sed 's/ *$//g'`}
extractToDir=${DIRECTORY:="/tmp"}

####
echo "Extracting '${appPackage}' directories from device (${device}) to '${extractToDir}'"

# Ensure that a package name has been provided
if [ -z $appPackage ]
	then 
	echo "Application package is not provided. Use the '-p | --package' option to set it."; 
	exit 1
fi

# Ensure that abe.jar tool exists
if [ ! -f ./support/abe.jar ]
	then
	echo "Unable to locate 'abe.jar' tool in the 'support' directory. Download it from http://sourceforge.net/projects/adbextractor/files/abe.jar/download"
	exit 1
fi

# Begin the backup procedure
adb -s $device backup -f $appPackage.ab $appPackage

# Convert the `ab` file to `tar` format
java -jar ./support/abe.jar unpack $appPackage.ab $appPackage.tar

# Extract the `tar` archive
tar -xf $appPackage.tar -C $extractToDir

# Clean up
rm $appPackage.tar $appPackage.ab

echo "Done! Your application files were extracted under the '${extractToDir}/apps' directory."
