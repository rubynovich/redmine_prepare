#!/bin/bash -e

# Define common variables
USERNAME=redmine

# Define core variables
BASHRC=$(dirname $(readlink -f $0))/redmine-shell.bashrc
RUN_WITH_USERNAME="sudo -iu $USERNAME http_proxy=$http_proxy https_proxy=$https_proxy"

# Launch shell
if [[ -z "$@" ]]; then
        $RUN_WITH_USERNAME bash --rcfile $BASHRC
else
        $RUN_WITH_USERNAME bash -c "source $BASHRC; $@"
fi