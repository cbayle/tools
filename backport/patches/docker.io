--- docker.io-wheezy-amd64/debian/helpers/gitcommit.sh	2014-09-20 10:08:07.000000000 +0200
+++ docker.io-wheezy-amd64.patch/debian/helpers/gitcommit.sh	2014-11-09 17:43:15.002715563 +0100
@@ -8,7 +8,7 @@
 	uVersion="$(cat VERSION)"
 fi
 if [ -z "$dVersion" ]; then
-	dVersion="$(dpkg-parsechangelog --show-field Version)"
+	dVersion="$(head -1 debian/changelog | sed 's/.*(\(.*)\).*/\1/')"
 fi
 
 if [ "${uVersion%-dev}" = "$uVersion" ]; then
