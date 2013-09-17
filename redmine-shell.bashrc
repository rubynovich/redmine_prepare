# Common variables
REDMINE_VERSION=2.2
GEMSET=ruby-1.9.3-gems1824@redmine2.2
export RAILS_ENV=production

# Define core variables
REDMINE_DIR=/opt/redmine-${REDMINE_VERSION}

# Prepare RVM environment
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

# Select Redmine gemset
rvm $GEMSET

# Go to Redmine directory
cd $REDMINE_DIR