# ! /bin/sh
CURRENT_BUILDERRESULTDIR=$(pwd)/build
CURRENT_REPODIR=/var/www/localrepo
CURRENT_RELEASE=$(lsb_release -sc)
CURRENT_DISTRIB=$(lsb_release -si|tr '[A-Z]' '[a-z]')

BUILDERRESULTDIR=${1:-$CURRENT_BUILDERRESULTDIR}
REPODIR=${2:-$CURRENT_REPODIR}
DISTRIB=${3:-$CURRENT_DISTRIB}
RELEASE=${4:-$CURRENT_RELEASE}

find $BUILDERRESULTDIR -name '*.changes' | while read changefilepath
do
	changefile=$(basename $changefilepath)
#	echo "== $changefile =="
	
	case $changefile in
		*_source.changes)
#			echo "--> $changefile"
#			changebase=$(echo $changefile|cut -d_ -f1)
#			changechar=$(echo $changebase|cut -c1)
#			changevers=$(echo $changefile|cut -d_ -f2)
#			if ls $REPODIR/$DISTRIB/pool/main/$changechar/$changebase/${changebase}_*${changevers}_*_source.changes 2>/dev/null
#			then
#				echo "   -> Already parsed : $changefile"
#			else
#				echo "   -> Parsing : $changefilepath"
#				reprepro --ignore=wrongdistribution -Vb $REPODIR/$DISTRIB include $RELEASE $changefilepath
#			fi
			;;
		*)	
			#echo "--> $changefile"
			changebase=$(echo $changefile|cut -d_ -f1)
			changechar=$(echo $changebase|cut -c1)
			changevers=$(echo $changefile|cut -d_ -f2)
			if ls $REPODIR/$DISTRIB/pool/main/$changechar/$changebase/${changebase}_*${changevers}_*.changes >/dev/null 2>&1
			then
				#echo "   -> Already parsed : $changefile"
				sleep 0
			else
				echo "   -> Parsing : $changefilepath"
				reprepro --ignore=wrongdistribution -Vb $REPODIR/$DISTRIB include $RELEASE $changefilepath
			fi
			;;
	esac
done
