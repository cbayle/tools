GITREPOS=docker-centos6 docker-debian8 docker-tuleap-base docker-tuleap-buildsrpms tools docker-debian7 docker-tuleap-aio  docker-tuleap-buildrpms  docker-ubuntu tuleap

update:
	@find .. -maxdepth 1 -type d -name '[a-z]*' | while read dir ; do echo "====== $$dir ======" ; (cd $$dir ; git pull) ; done

status:
	@find .. -maxdepth 1 -type d -name '[a-z]*' | while read dir ; do echo "====== $$dir ======" ; (cd $$dir ; git status) ; done

clone:
	for repo in $(GITREPOS) ; \
	do (cd .. ; \
		if [ ! -d $$repo ] ; \
		then \
			 echo git clone https://github.com/cbayle/$$repo.git  ; \
		fi ); \
	done
