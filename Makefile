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
	jpgraph-tuleap mailman-tuleap viewvc-tuleap openfire-tuleap-plugins \
	tools

GITHUB=git@github.com:
GITHUB=https://github.com/

update:
	@find .. -maxdepth 1 -type d -name '[a-z]*' | \
		while read dir ; do \
			echo "====== $$dir ======" ; \
			(cd $$dir ; \
			if [ -d .git ] ; \
			then \
				git pull ; \
			fi) ; \
		done

remotes:
	@find .. -maxdepth 1 -type d -name '[a-z]*' | \
		while read dir ; do \
			echo "====== $$dir ======" ; \
			(cd $$dir ; \
			if [ -d .git ] ; \
			then \
				git remote -v ; \
			fi) ; \
		done

showbrances:
	@find .. -maxdepth 1 -type d -name '[a-z]*' | \
		while read dir ; do \
			echo "====== $$dir ======" ; \
			(cd $$dir ; \
			if [ -d .git ] ; \
			then \
				git branch -va ; \
			fi) ; \
		done

status:
	@find .. -maxdepth 1 -type d -name '[a-z]*' | \
		while read dir ; do \
			echo "====== $$dir ======" ; \
			(cd $$dir ; \
			if [ -d .git ] ; \
			then \
				git status ; \
			fi) ; \
	done

clone:
	for repo in $(GITREPOS) ; \
	do (cd .. ; \
		if [ ! -d $$repo ] ; \
		then \
			 git clone $(GITHUB)cbayle/$$repo.git  ; \
		fi ); \
	done


