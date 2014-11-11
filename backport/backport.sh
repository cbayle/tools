#! /bin/sh
set -e
CURRENT_RELEASE=$(lsb_release -sc)
CURRENT_ARCH=$(dpkg --print-architecture)

PACKAGE=$1
RELEASE=${2:-$CURRENT_RELEASE}
ARCH=${3:-$CURRENT_ARCH}
SUFFIX=${4:-~grz}
RELSRC=${5-sid}

[ -z "$PACKAGE" ] && exit 1

echo "Backporting $PACKAGE for $RELEASE-$ARCH$SUFFIX"

if [ ! -f "build/done_$PACKAGE" ]
then
	echo "Building $PACKAGE"
	#sudo sbuild-update -udcar $RELEASE-$ARCH
        #backportpackage -w build -S$SUFFIX -Bsbuild -b -s$RELSRC -d$RELEASE --dont-sign $PACKAGE
	if [ -f patches/$PACKAGE ]
	then
		#backportpackage -w build -S$SUFFIX -Bsbuild -s$RELSRC -d$RELEASE --dont-sign $PACKAGE
		backportpackage -w build -S$SUFFIX -s$RELSRC -d$RELEASE --dont-sign $PACKAGE
		cd build
		dpkg-source -x $PACKAGE*$SUFFIX.dsc $PACKAGE-$RELEASE-$ARCH
		cd $PACKAGE-$RELEASE-$ARCH 
		patch -p1 < ../../patches/$PACKAGE 
		cd ..
		dpkg-source -b $PACKAGE-$RELEASE-$ARCH
		rm -rf $PACKAGE-$RELEASE-$ARCH
		sbuild --apt-update --source --force-orig-source \
			-A -d$RELEASE-$ARCH ${PACKAGE}*${SUFFIX}*.dsc && touch done_${PACKAGE}
	else
		backportpackage -w build -S$SUFFIX -s$RELSRC -d$RELEASE --dont-sign $PACKAGE
		cd build 
		sbuild --apt-update --source --force-orig-source \
			-A -d$RELEASE-$ARCH ${PACKAGE}*${SUFFIX}*.dsc && touch done_${PACKAGE}
	fi
fi
