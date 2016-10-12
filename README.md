# Centos 7 spec and build for ruby

Heavily borrowed from https://github.com/feedforce/ruby-rpm

To use, create Docker container:
```
docker build -t centos7-ruby-rpm .
```

Then run build script in container:
```
docker run -i -e GITHUB_USER=<github_user> -e GITHUB_REPO=<github_repo> -e GITHUB_TOKEN=<github_api_token> centos7-ruby-rpm ./build-ruby.sh
```

The above script will build RPMS and then create a release in github where the rpm can be downloaded from.
