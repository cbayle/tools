# Fillrepo vars
REPODIR=/var/www/localrepo
RELEASE=wheezy
DISTRIB=debian
ARCH=$(shell dpkg --print-architecture)
BUILDERRESULTDIR=$(CURDIR)/build
SUFFIX=~grz

default: docker
	@echo 'All done'

docker: dh-golang init-system-helpers golang go-md2man golang-context golang-dbus golang-go-patricia golang-go-systemd golang-gocapability-dev golang-gosqlite-dev golang-mux golang-pty docker.io
	@echo 'Docker done'

go-md2man: golang-blackfriday

golang-blackfriday: golang-go.net-dev

clean: cleanrepo
	echo "Clean Done"

showvers:
	rmadison docker.io --architecture amd64

fillrepo: preparerepo $(REPODIR)
	./fillrepo.sh $(BUILDERRESULTDIR) $(REPODIR) $(DISTRIB) $(RELEASE)

cleanrepo:
	./cleanrepo.sh $(REPODIR) $(DISTRIB) $(RELEASE)

preparerepo:
	[ -d $(REPODIR)/$(DISTRIB)/dists/$(RELEASE) ] || make -C repo

build/done_%.done:
	@[ -f build/done_$* ] || ./backport.sh $* $(RELEASE) $(ARCH) $(SUFFIX)
	make fillrepo

%: build/done_%.done
	@[ ! -f build/done_$* ] || echo "Building $* Done"
