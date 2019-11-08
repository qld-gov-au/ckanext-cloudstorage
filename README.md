# ckanext-cloudstorage

Implements support for using S3, Azure, or any of 30+ providers supported by
[libcloud][] to [CKAN][].

# Setup

After installing `ckanext-cloudstorage`, add it to your list of plugins in
your `.ini`:

    ckan.plugins = stats cloudstorage

If you haven't already, setup [CKAN file storage][ckanstorage] or the file
upload button will not appear.

Every driver takes two options, regardless of which one you use. Both
the name of the driver and the name of the container/bucket are
case-sensitive:

    ckanext.cloudstorage.driver = AZURE_BLOBS
    ckanext.cloudstorage.container_name = demo

You can find a list of driver names [here][storage] (see the `Provider
Constant` column.)

Each driver takes its own setup options. See the [libcloud][] documentation.
These options are passed in using `driver_options`, which is a Python dict.
For most drivers, this is all you need:

    ckanext.cloudstorage.driver_options = {"key": "<your public key>", "secret": "<your secret key>"}

# Support

Most libcloud-based providers should work out of the box, but only those listed
below have been tested:

| Provider | Uploads | Downloads | Secure URLs (private resources) |
| --- | --- | --- | --- |
| Azure    | YES | YES | YES (if `azure-storage` is installed) |
| AWS S3   | YES | YES | YES (if `boto` is installed) |
| Rackspace | YES | YES | No |

# What are "Secure URLs"?

"Secure URLs" are a method of preventing access to private resources. By
default, anyone that figures out the URL to your resource on your storage
provider can download it. Secure URLs allow you to disable public access and
instead let ckanext-cloudstorage generate temporary, one-use URLs to download
the resource. This means that the normal CKAN-provided access restrictions can
apply to resources with no further effort on your part, but still get all the
benefits of your CDN/blob storage.

    ckanext.cloudstorage.use_secure_urls = 1

This option also enables multipart uploads, but you need to create database tables
first. Run next command from extension folder:
    `paster cloudstorage initdb -c /etc/ckan/default/production.ini `

With that feature you can use `cloudstorage_clean_multipart` action, which is available
only for sysadmins. After executing, all unfinished multipart uploads, older than 7 days,
will be aborted. You can configure this lifetime, example:

     ckanext.cloudstorage.max_multipart_lifetime  = 7

# Migrating From FileStorage

If you already have resources that have been uploaded and saved using CKAN's
built-in FileStorage, cloudstorage provides an easy migration command.
Simply setup cloudstorage as explained above, enable the plugin, and run the
migrate command. Provide the path to your resources on-disk (the
`ckan.storage_path` setting in your CKAN `.ini` + `/resources`), and
cloudstorage will take care of the rest. Ex:

    paster cloudstorage migrate <path to files> -c ../ckan/development.ini

# Notes

1. You should disable public listing on the cloud service provider you're
   using, if supported.
2. Currently, only resources are supported. This means that things like group
   and organization images still use CKAN's local file storage.

# FAQ

- *DataViews aren't showing my data!* - did you setup CORS rules properly on
  your hosting service? ckanext-cloudstorage can try to fix them for you automatically,
  run:

        paster cloudstorage fix-cors <list of your domains> -c=<CKAN config>

- *Help! I can't seem to get it working!* - send me a mail! tk@tkte.ch

[libcloud]: https://libcloud.apache.org/
[ckan]: http://ckan.org/
[storage]: https://libcloud.readthedocs.io/en/latest/storage/supported_providers.html
[ckanstorage]: http://docs.ckan.org/en/latest/maintaining/filestore.html#setup-file-uploads

# Docker System

Once you have completed setup.

ahoy build (or ahoy up)
visit http://ckanext-cloudstorage.docker.amazee.io

## Local environment setup
- Make sure that you have latest versions of all required software installed:
  - [Docker](https://www.docker.com/) [Docs](https://docs.docker.com/install/)
    [Mac Install](https://docs.docker.com/docker-for-mac/install/)
    ```
    Linux (Ubuntu)
    sudo apt-get remove docker docker-engine docker.io containerd runc
    sudo apt-get update
    sudo apt-get install \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg-agent \
      software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    sudo add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) \
     stable"
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io
    ```
    If you don't want sudo infront of docker [non-root user manage](https://docs.docker.com/install/linux/linux-postinstall/)
    ```text
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
    sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
    sudo chmod g+rwx "~$USER/.docker" -R
    ```
  - [Docker Compose](https://docs.docker.com/compose/)
    ```
    sudo pip install docker-compose
    ```
  - [Pygmy](https://pygmy.readthedocs.io/)
    ```
    sudo gem install pygmy
    ```
  - [Ahoy](https://github.com/ahoy-cli/ahoy) [Docs](https://ahoy-cli.readthedocs.io/en/latest/)
    ```
    Linux
    sudo wget https://github.com/devinci-code/ahoy/releases/download/2.0.0/ahoy-bin-linux-amd64 -O /usr/local/bin/ahoy && sudo chown $USER /usr/local/bin/ahoy && chmod +x /usr/local/bin/ahoy
    ```
    ```text
    OSX
    brew tap devinci-code/tap
    brew install ahoy
    # For v2 which is still alpha (see below)
    brew install ahoy --HEAD
    ```
- Make sure that all local web development services are shut down (Apache/Nginx, Mysql, MAMP etc).
- Checkout project repository (in one of the [supported Docker directories](https://docs.docker.com/docker-for-mac/osxfs/#access-control)).  
- `pygmy up`
- `ahoy build`

Use `admin`/`password` to login to CKAN.


### If behind a proxy

Add proxy details to docker daemon via https://docs.docker.com/config/daemon/systemd/
* Create base folder if not existing
  ```sudo mkdir -p /etc/systemd/system/docker.service.d```
* add http-proxy file
  ```sudo vi /etc/systemd/system/docker.service.d/http-proxy.conf```
  with details
  ```
  [Service]
  Environment="HTTP_PROXY=http://localhost:3128/"
  ```
* add https-proxy file
  ```bash
  sudo vi /etc/systemd/system/docker.service.d/https-proxy.conf
  ```
  with details
  ```bash
  [Service]
  Environment="HTTP_PROXY=http://localhost:3128/"
  ```

* Reload systemd
```
  sudo systemctl daemon-reload
  sudo systemctl restart docker
  ```
* ensure /etc/gemrc has your proxy
  ```
  http_proxy: http://localhost:3128
  https_proxy: http://localhost:3128
  ```
* Configure internal proxy settings in the docker machines form [here](https://docs.docker.com/network/proxy/)

  ~/.docker/config.json
    ```
    {
      "proxies":
    {
      "default":
    {
      "httpProxy": "http://hostexternalip:3128",
      "httpsProxy": "http://hostexternalip:3128"
    }
    }
    }
    ```


That should be it. If you still have problems you can also update ruby proxy and internal docker environment settings

* if you have squid proxy please ensure you allow docker containers to access it ensure these records exist
```text
http_access allow local-net

acl local-net src ${your external ip address}/32 # replace ${your external ip address} with your external ip
acl local-net src 10.0.0.0/8 # RFC1918 possible internal network
acl local-net src 172.16.0.0/1 # RFC1918 possible internal network
acl local-net src 192.168.0.0/16 # RFC1918 possible internal network
acl local-net src fc00::/7 # RFC 4193 local private network range
acl local-net src fe80::/10 # RFC 4291 link-local (directly plugged) machines

acl SSL_ports port 443
acl Safe_ports port 80    # http
acl CONNECT method CONNECT

acl local-servers dstdomain .amazee.io
always_direct allow local-servers
always_direct allow localnet
```

* update /etc/hosts
```text
127.0.0.1 docker.amazee.io adminer.docker.amazee.io mailhog.docker.amazee.io ckanext-cloudstorage.docker.amazee.io
```

## Available `ahoy` commands
Run each command as `ahoy <command>`.
  ```  
   build        Build or rebuild project.
   clean        Remove containers and all build files.
   cli          Start a shell inside CLI container or run a command.
   doctor       Find problems with current project setup.
   down         Stop Docker containers and remove container, images, volumes and networks.
   flush-redis  Flush Redis cache.
   info         Print information about this project.
   install-site Install a site.
   lint         Lint code.
   logs         Show Docker logs.
   pull         Pull latest docker images.
   reset        Reset environment: remove containers, all build, manually created and Drupal-Dev files.
   restart      Restart all stopped and running Docker containers.
   start        Start existing Docker containers.
   stop         Stop running Docker containers.
   test-bdd     Run BDD tests.
   test-unit    Run unit tests.
   up           Build and start Docker containers.
  ```

## Coding standards
Python code linting uses [flake8](https://github.com/PyCQA/flake8) with configuration captured in `.flake8` file.   

Set `ALLOW_LINT_FAIL=1` in `.env` to allow lint failures.

## Nose tests
`ahoy test-unit`

Set `ALLOW_UNIT_FAIL=1` in `.env` to allow unit test failures.

## Behavioral tests
`ahoy test-bdd`

Set `ALLOW_BDD_FAIL=1` in `.env` to allow BDD test failures.

### How it works
We are using [Behave](https://github.com/behave/behave) BDD _framework_ with additional _step definitions_ provided by [Behaving](https://github.com/ggozad/behaving) library.

Custom steps described in `test/features/steps/steps.py`.

Test scenarios located in `test/features/*.feature` files.

Test environment configuration is located in `test/features/environment.py` and is setup to connect to a remote Chrome
instance running in a separate Docker container. 

During the test, Behaving passes connection information to [Splinter](https://github.com/cobrateam/splinter) which
instantiates WebDriver object and establishes connection with Chrome instance. All further communications with Chrome 
are handled through this driver, but in a developer-friendly way.

For a list of supported step-definitions, see https://github.com/ggozad/behaving#behavingweb-supported-matcherssteps.

## Automated builds (Continuous Integration)
In software engineering, continuous integration (CI) is the practice of merging all developer working copies to a shared mainline several times a day. 
Before feature changes can be merged into a shared mainline, a complete build must run and pass all tests on CI server.

This project uses [Circle CI](https://circleci.com/) as a CI server: it imports production backups into fully built codebase and runs code linting and tests. When tests pass, a deployment process is triggered for nominated branches (usually, `master` and `develop`).

Add `[skip ci]` to the commit subject to skip CI build. Useful for documentation changes.

### SSH
Circle CI supports shell access to the build for 120 minutes after the build is finished when the build is started with SSH support. Use "Rerun job with SSH" button in Circle CI UI to start build with SSH support.
