#!/bin/bash

# To simplify things, we don't want to install mariadb-server until we've done
# our initial sync of filesystems from blue. Blue will ssh in and call this
# when it's done zfs send.
apt-get -qq install -y mariadb-server mariadb-client
