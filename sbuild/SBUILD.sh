#! /bin/sh
CURRENT_RELEASE=$(lsb_release -sc)
CURRENT_DISTRIB=$(lsb_release -si|tr '[A-Z]' '[a-z]')
CURRENT_ARCH=$(dpkg --print-architecture)

DEBMIRROR=http://cdn.debian.net/debian
UBUMIRROR=http://archive.ubuntu.com/ubuntu
DEBCOMPONENTS="main"
UBUCOMPONENTS="main,universe"

RELEASES="sid jessie wheezy trusty utopic"
RELEASES="sid jessie wheezy trusty"
RELEASES="$CURRENT_RELEASE"

sbuild_deps(){
	if ! getent group sbuild > /dev/null
	then
		sudo apt-get -y install sbuild
		sudo /usr/sbin/sbuild-adduser $LOGNAME
	fi
	#sbuild_group_id=$(getent group sbuild | cut -d: -f3)
}

mkbuild_deps(){
	if [ ! -f /usr/bin/mk-sbuild ]
	then
		#ubuntu-dev-tools ubuntu-archive-keyring
		sudo apt-get -y install ubuntu-dev-tools
	fi
	if [ ! -f /usr/bin/curl ]
	then
		sudo apt-get -y install curl
	fi
}

get_mirror_by_release(){
	RELEASE=$1
	case $RELEASE in
		sid|jessie|wheezy)
			echo $DEBMIRROR
		;;
		trusty|utopic)
			echo $UBUMIRROR
		;;
	esac
}

get_component_by_release(){
	RELEASE=$1
	case $RELEASE in
		sid|jessie|wheezy)
			echo $DEBCOMPONENTS
		;;
		trusty|utopic)
			echo $UBUCOMPONENTS
		;;
	esac
}

get_local_mirror_by_release(){
	RELEASE=$1
	case $RELEASE in
		sid|jessie|wheezy)
			echo http://localhost/localrepo/debian
		;;
		trusty|utopic)
			echo http://localhost/localrepo/ubuntu
		;;
	esac
}

# Deprecated
sbuild_generic(){
	# Config are in /etc/schroot/chroot.d/
	# Result is in /var/lib/sbuild
	RELEASE=$1
	COMPONENTS=${2:-$DEBCOMPONENTS}
	MIRROR=${3:-$DEBMIRROR}
	ARCH=${4:-$CURRENT_ARCH}
	if [ -f /var/lib/sbuild/$RELEASE-$ARCH.tar.gz2 ]
	then 
		echo =====================================================
		echo Already have /var/lib/sbuild/$RELEASE-$ARCH.tar.gz
		echo =====================================================
	else
		echo =====================================================
		echo mk-sbuild $RELEASE
		echo sudo /usr/sbin/sbuild-createchroot 
		echo 	--components="$COMPONENTS"
		echo 	--make-sbuild-tarball=/var/lib/sbuild/$RELEASE-$ARCH
		echo 	$RELEASE `mktemp -d` $MIRROR
		echo =====================================================
		sudo /usr/sbin/sbuild-createchroot \
			--components="$COMPONENTS" \
			--make-sbuild-tarball=/var/lib/sbuild/$RELEASE-$ARCH \
			$RELEASE `mktemp -d` $MIRROR
	fi
}

mkbuild_generic(){
	RELEASE=$1
	ARCH=$(dpkg --print-architecture)
	# Config are in /etc/schroot/chroot.d/
	# Result is in /var/lib/schroot/chroots/
	if [ -d /var/lib/schroot/chroots/$RELEASE-$ARCH ]
	then
		echo =====================================================
		echo Already have /var/lib/schroot/chroots/$RELEASE-$ARCH
		echo =====================================================
		echo To CHANGE the golden image: sudo schroot -c source:$RELEASE-$ARCH -u root
		echo To ENTER an image snapshot: schroot -c $RELEASE-$ARCH
		echo To BUILD within a snapshot: sbuild -A -d $RELEASE-$ARCH PACKAGE*.dsc
	else
		echo =====================================================
		echo mk-sbuild $RELEASE
		echo =====================================================
		MIRROR=$(get_mirror_by_release $RELEASE)
		mk-sbuild $RELEASE --debootstrap-mirror=$MIRROR
		mkbuild_add $RELEASE
	fi
}

mkbuild_add(){
	RELEASE=$1
	ARCH=$(dpkg --print-architecture)
	MIRROR=$(get_local_mirror_by_release $RELEASE)
	curl -s http://localhost/localrepo/botkey.gpg |\
		sudo schroot -c source:$RELEASE-$ARCH -u root apt-key add -
	sudo schroot -c source:$RELEASE-$ARCH -u root -- /bin/sh -c "echo \"deb $MIRROR $RELEASE main\" > /etc/apt/sources.list.d/localrepo-$RELEASE.list"
	#sudo schroot -c source:$RELEASE-$ARCH -u root apt-get update
}

mkbuild_clean(){
	RELEASE=$1
	ARCH=$(dpkg --print-architecture)
	[ -d "/var/lib/schroot/chroots/$RELEASE-$ARCH" ] && \
		sudo rm -rf /var/lib/schroot/chroots/$RELEASE-$ARCH
	[ -f "/etc/schroot/chroot.d/sbuild-$RELEASE-$ARCH" ] && \
		sudo rm -f /etc/schroot/chroot.d/sbuild-$RELEASE-$ARCH
}

schroot_list(){
	schroot -l
	echo "You can shell using for exemaple :"
	echo "	sbuild-shell chroot:wheezy-amd64-sbuild"
}

schroot_info(){
	schroot --info --all-sessions
}

sbuild_update(){
	UPDLIST=$(grep '^\[' /etc/schroot/chroot.d/*| cut -d[ -f2 | cut -d] -f1)
	for RELEASE in $UPDLIST
	do
		echo =====================================================
		echo Updating $RELEASE
		echo =====================================================
		sudo sbuild-update -udcar $RELEASE
	done
}

sbuilds_deps(){
	sbuild_deps
	for release in $RELEASES
	do
		sbuild_generic $release $(get_component_by_release $release) $(get_mirror_by_release $release)
	done
}

releases_deps(){
	mkbuild_deps
	for release in $RELEASES
	do
		mkbuild_generic $release
	done
}

#mkbuild_clean $CURRENT_RELEASE
releases_deps
#sbuild_update
