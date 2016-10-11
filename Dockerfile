FROM centos:centos7.2.1511

RUN yum update -y -q && \
	yum install -y rpm-build tar make && \
	yum -y install readline-devel ncurses-devel gdbm-devel glibc-devel gcc openssl openssl-devel libyaml-devel libffi-devel zlib-devel && \
	cd /usr/bin && \
	curl -L https://github.com/aktau/github-release/releases/download/v0.6.2/linux-amd64-github-release.tar.bz2 | tar xvj --strip-components 3 && \
	useradd -u 1000 builder && \
	mkdir -p /home/builder/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS} && \
	chown -R builder:builder /home/builder/rpmbuild && \
	cd

ADD script/build-ruby.sh /home/builder/rpmbuild/

RUN chmod a+x /home/builder/rpmbuild/build-ruby.sh

ADD ruby.spec /home/builder/rpmbuild/SPECS/

WORKDIR /home/builder/rpmbuild

USER builder
