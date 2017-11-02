#!/bin/bash

# start ssh 

test -x /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server

/etc/init.d/ssh start

echo "Current directory : $(pwd)"
echo "Environment RUNVAR: $RUNVAR"
echo "There are $# arguments: $@"
