#!/bin/sh

set -xe

RUBY_X_Y_Z_VERSION=$(grep "%define \+rubyver" $HOME/rpmbuild/SPECS/ruby.spec | awk '{print $3}')
RUBY_X_Y_VERSION=$(echo $RUBY_X_Y_Z_VERSION | sed -e 's@\.[0-9]$@@')

cd $HOME/rpmbuild/SOURCES && curl -LO https://cache.ruby-lang.org/pub/ruby/$RUBY_X_Y_VERSION/ruby-$RUBY_X_Y_Z_VERSION.tar.gz

rpmbuild -ba $HOME/rpmbuild/SPECS/ruby.spec

cp $HOME/rpmbuild/RPMS/x86_64/* .
cp $HOME/rpmbuild/SRPMS/* .


need_to_release() {
	http_code=$(curl -sL -w "%{http_code}\\n" https://github.com/${GITHUB_USER}/${GITHUB_REPO}/releases/tag/${RUBY_X_Y_Z_VERSION} -o /dev/null)
	test $http_code = "404"
}

if ! need_to_release; then
	echo "$GITHUB_REPO $RUBY_X_Y_Z_VERSION has already released."
	exit 0
fi

#
# Create a release page
#

github-release release \
  --tag $RUBY_X_Y_Z_VERSION \
  --name "Ruby-${RUBY_X_Y_Z_VERSION}" \
  --description "not release"

#
# Upload rpm files and build a release note
#

print_rpm_markdown() {
  RPM_FILE=$1
  cat <<EOS
* $RPM_FILE
    * sha256: $(openssl sha256 $RPM_FILE | awk '{print $2}')
EOS
}

upload_rpm() {
  RPM_FILE=$1
  github-release upload \
    --tag $RUBY_X_Y_Z_VERSION \
    --name "$RPM_FILE" \
    --file $RPM_FILE
}

cat <<EOS > description.md
Use at your own risk!
Build on CentOS 7
EOS

# CentOS 7
for i in *.el7.centos.x86_64.rpm *.el7.centos.src.rpm; do
  print_rpm_markdown $i >> description.md
  upload_rpm $i
done

#
# Make the release note to complete!
#

github-release edit \
  --tag $RUBY_X_Y_Z_VERSION \
  --name "Ruby-${RUBY_X_Y_Z_VERSION}" \
  --description "$(cat description.md)"
