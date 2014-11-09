# ! /bin/sh
CURRENT_REPODIR=/var/www/localrepo
CURRENT_RELEASE=$(lsb_release -sc)
CURRENT_DISTRIB=$(lsb_release -si|tr '[A-Z]' '[a-z]')

REPODIR=${1:-$CURRENT_REPODIR}
DISTRIB=${2:-$CURRENT_DISTRIB}
RELEASE=${3:-$CURRENT_RELEASE}

find $REPODIR/$DISTRIB -name '*.deb' | while read packagepath
do
	packagedeb=$(basename $packagepath)
	packagename=$(echo $packagedeb | cut -d_ -f1)
        reprepro -Vb $REPODIR/$DISTRIB remove $RELEASE $packagename
done

find $REPODIR/$DISTRIB -name '*.dsc' | while read packagepath
do
	packagedeb=$(basename $packagepath)
	packagename=$(echo $packagedeb | cut -d_ -f1)
        reprepro -Vb $REPODIR/$DISTRIB remove $RELEASE $packagename
done
