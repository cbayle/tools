GITREPOS=docker-centos6 \
	docker-debian8 \
	docker-debian7 \
	docker-ubuntu \
	docker-tuleap-base \
	docker-tuleap-aio  \
	docker-tuleap-buildrpms  \
	docker-tuleap-buildsrpms \
	tuleap \
	tuleap-debian-build \
	tuleap-centos-build \
	tools

GITHUB=git@github.com:
GITHUB=https://github.com/

update:
	@find .. -maxdepth 1 -type d -name '[a-z]*' | while read dir ; do echo "====== $$dir ======" ; (cd $$dir ; git pull) ; done

status:
	@find .. -maxdepth 1 -type d -name '[a-z]*' | while read dir ; do echo "====== $$dir ======" ; (cd $$dir ; git status) ; done

clone:
	for repo in $(GITREPOS) ; \
	do (cd .. ; \
		if [ ! -d $$repo ] ; \
		then \
			 git clone $(GITHUB)cbayle/$$repo.git  ; \
		fi ); \
	done
