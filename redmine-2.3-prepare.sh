#!/bin/bash -e

# Define common variables
USERNAME=redmine
WWW_USERNAME=redmine
RUN_WITH_USERNAME="sudo -iu $USERNAME "

# Create user with $USERNAME
id $USERNAME || sudo useradd -gsudo --shell=/bin/bash -rm $USERNAME

# Install apache2
#sudo apt-get install apache2

# Install RVM and rvm reqirements
sudo apt-get -y install curl
curl -L get.rvm.io | $RUN_WITH_USERNAME bash -s stable
# Install packages suggested by rvm-installer (try 'rvm requirements')
sudo apt-get -y install \
     build-essential openssl libreadline6 libreadline6-dev curl \
     git-core zlib1g zlib1g-dev libssl-dev libyaml-dev \
     libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev \
     ncurses-dev automake libtool bison subversion pkg-config

sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install mysql-server
echo "Set MySQL root password later with 'mysqladmin -u root password'"

sudo apt-get -y install \
     libmysqlclient-dev libpq-dev zip libcurl4-gnutls-dev \
     libmagick++-dev

# Prepare environment for Redmine
## Define versions
REDMINE_VERSION=2.3
REDMINE_DIR=/opt/redmine
NGINX_DIR=/opt/nginx
RUBY_VERSION=2.0.0
GEM_VERSION=2.1.3
## Checkout Redmine
sudo git clone git://github.com/redmine/redmine.git --branch ${REDMINE_VERSION}-stable $REDMINE_DIR
# sudo svn co http://svn.redmine.org/redmine/branches/${REDMINE_VERSION}-stable $REDMINE_DIR
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

# copy certs
# cp project.u-k-s.ru.crt /etc/ssl/certs/
# cp project.u-k-s.ru.key /etc/ssl/certs/
#
# copy nginx files
# cp nginx /etc/init.d/
# cp S50nginx /etc/rc.2/
