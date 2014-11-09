#! /bin/sh
DEBMIRROR=http://cdn.debian.net/debian
UBUMIRROR=http://archive.ubuntu.com/ubuntu
DEBCOMPONENTS="main"
UBUCOMPONENTS="main,universe"
CURRENT_ARCH=amd64
DEBDIST=wheezy
UBUDIST=trusty
DISTS="sid jessie wheezy trusty utopic"
DISTS="sid jessie wheezy trusty"
DISTS="wheezy"

sbuild_prepare(){
	if ! getent group sbuild > /dev/null
	then
		sudo apt-get -y install sbuild
		sudo /usr/sbin/sbuild-adduser $LOGNAME
	fi
	#sbuild_group_id=$(getent group sbuild | cut -d: -f3)
}

mkbuild_prepare(){
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

get_mirror_by_dist(){
	DIST=$1
	case $DIST in
		sid|jessie|wheezy)
			echo $DEBMIRROR
		;;
		trusty|utopic)
			echo $UBUMIRROR
		;;
	esac
}

get_local_mirror_by_dist(){
	DIST=$1
	case $DIST in
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
	DIST=$1
	COMPONENTS=${2:-$DEBCOMPONENTS}
	MIRROR=${3:-$DEBMIRROR}
	ARCH=${4:-$CURRENT_ARCH}
	if [ -f /var/lib/sbuild/$DIST-$ARCH.tar.gz2 ]
	then 
		echo =====================================================
		echo Already have /var/lib/sbuild/$DIST-$ARCH.tar.gz
		echo =====================================================
	else
		echo =====================================================
		echo mk-sbuild $DIST
		echo sudo /usr/sbin/sbuild-createchroot 
		echo 	--components="$COMPONENTS"
		echo 	--make-sbuild-tarball=/var/lib/sbuild/$DIST-$ARCH
		echo 	$DIST `mktemp -d` $MIRROR
		echo =====================================================
		sudo /usr/sbin/sbuild-createchroot \
			--components="$COMPONENTS" \
			--make-sbuild-tarball=/var/lib/sbuild/$DIST-$ARCH \
			$DIST `mktemp -d` $MIRROR
	fi
}

mkbuild_generic(){
	DIST=$1
	ARCH=$(dpkg --print-architecture)
	# Config are in /etc/schroot/chroot.d/
	# Result is in /var/lib/schroot/chroots/
	if [ -d x/var/lib/schroot/chroots/$DIST-$ARCH ]
	then
		echo =====================================================
		echo Already have /var/lib/schroot/chroots/$DIST-$ARCH
		echo =====================================================
		echo To CHANGE the golden image: sudo schroot -c source:$DIST-$ARCH -u root
		echo To ENTER an image snapshot: schroot -c $DIST-$ARCH
		echo To BUILD within a snapshot: sbuild -A -d $DIST-$ARCH PACKAGE*.dsc
	else
		echo =====================================================
		echo mk-sbuild $DIST
		echo =====================================================
		MIRROR=$(get_mirror_by_dist $DIST)
		mk-sbuild $DIST --debootstrap-mirror=$MIRROR
		mkbuild_add $DIST
	fi
}

mkbuild_add(){
	DIST=$1
	ARCH=$(dpkg --print-architecture)
	MIRROR=$(get_local_mirror_by_dist $DIST)
	curl -s http://localhost/localrepo/botkey.gpg |\
		sudo schroot -c source:$DIST-$ARCH -u root apt-key add -
	sudo schroot -c source:$DIST-$ARCH -u root -- /bin/sh -c "echo \"deb $MIRROR $DIST main\" > /etc/apt/sources.list.d/localrepo-$DIST.list"
	#sudo schroot -c source:$DIST-$ARCH -u root apt-get update
}

mkbuild_clean(){
	DIST=$1
	ARCH=$(dpkg --print-architecture)
	[ -d /var/lib/schroot/chroots/$DIST-$ARCH ] && \
		sudo rm -rf /var/lib/schroot/chroots/$DIST-$ARCH
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
	for DIST in $UPDLIST
	do
		echo =====================================================
		echo Updating $DIST
		echo =====================================================
		sudo sbuild-update -udcar $DIST
	done
}

# Deprecated
sbuilds_prepare(){
	sbuild_prepare
	sbuild_generic sid
	sbuild_generic jessie
	sbuild_generic wheezy

	sbuild_generic trusty $UBUCOMPONENTS $UBUMIRROR
	sbuild_generic utopic $UBUCOMPONENTS $UBUMIRROR
}

dists_prepare(){
	mkbuild_prepare
	for dist in $DISTS
	do
		mkbuild_generic $dist
	done
}

mkbuild_prepare

#mkbuild_clean wheezy

dists_prepare
sbuild_update
