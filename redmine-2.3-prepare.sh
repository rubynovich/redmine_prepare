#!/bin/bash -e

# Define common variables
USERNAME=redmine
WWW_USERNAME=redmine
RUN_WITH_USERNAME="sudo -iu $USERNAME http_proxy=$http_proxy https_proxy=$https_proxy"

# Create user with $USERNAME
id $USERNAME || sudo useradd -rm $USERNAME

# Install apache2
#sudo apt-get install apache2

# Install RVM and rvm reqirements
sudo apt-get install curl
curl -L get.rvm.io | $RUN_WITH_USERNAME bash -s stable
# Install packages suggested by rvm-installer (try 'rvm requirements')
sudo apt-get install \
     build-essential openssl libreadline6 libreadline6-dev curl \
     git-core zlib1g zlib1g-dev libssl-dev libyaml-dev \
     libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev \
     ncurses-dev automake libtool bison subversion pkg-config \
     mysql-server libmysqlclient-dev libpq-dev zip libcurl4-gnutls-dev \
     libmagick++-dev

# Prepare environment for Redmine
## Define versions
REDMINE_VERSION=2.3
REDMINE_DIR=/opt/redmine-${REDMINE_VERSION}
NGINX_DIR=/opt/nginx
RUBY_VERSION=1.9.3
GEM_VERSION=1.8.24
## Checkout Redmine
sudo git clone git://github.com/redmine/redmine.git --branch ${REDMINE_VERSION}-stable $REDMINE_DIR
#sudo svn co http://svn.redmine.org/redmine/branches/${REDMINE_VERSION}-stable $REDMINE_DIR
## Prepare directory and permissions for the bundler
sudo mkdir -p $REDMINE_DIR/.bundle
sudo mkdir $NGINX_DIR
sudo chown $USERNAME:$USERNAME $NGINX_DIR
sudo chown $USERNAME:$USERNAME $REDMINE_DIR/.bundle
sudo chown $USERNAME:$USERNAME $REDMINE_DIR     # necessary to be able to create Gemfile.lock during installation
## Prepare
GEM_INSTALL="gem install --no-rdoc --no-ri"
GEM_VERSION_SHORT=${GEM_VERSION//./}
cat << EOF | $RUN_WITH_USERNAME bash -e
    [[ -s "\$HOME/.rvm/scripts/rvm" ]] && source "\$HOME/.rvm/scripts/rvm" && \
    rvm install $RUBY_VERSION-gems$GEM_VERSION_SHORT && \
    rvm use $RUBY_VERSION-gems$GEM_VERSION_SHORT && \
    rvm rubygems $GEM_VERSION && \
    rvm gemset create redmine$REDMINE_VERSION && \
    rvm use $RUBY_VERSION-gems$GEM_VERSION_SHORT@redmine$REDMINE_VERSION
    ## Install bundler (to make a process of dependencies instalation easier)
    #  aantonov: in next line gem can not follow http redirect
    #  aantonov: kinda breakpoint
    $GEM_INSTALL bundler
    ## Install passenger
    $GEM_INSTALL passenger
    ## Build passenger
    passenger-install-nginx-module --auto --auto-download --prefix=$NGINX_DIR
    ## Install necessary gems using bundler
    cd $REDMINE_DIR || exit 1
    bundle install --without development test
EOF

# Install Redmine
## Fix some permissions
sudo chown root:root $REDMINE_DIR
cd $REDMINE_DIR
sudo mkdir -p tmp public/plugin_assets
sudo chown -R $WWW_USERNAME files log tmp public/plugin_assets db
sudo chmod -R 755 files log tmp public/plugin_assets
sudo chmod -R 700 db
