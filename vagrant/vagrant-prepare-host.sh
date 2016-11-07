#!/bin/bash
#
# vagrant-prepare-host.sh
#
# Runs on your local machine (the vagrant host) to prepare source code for editing.
# This script is run automatically on `vagrant up`.  You do not need to this manually.
#

# Passed argument is Vagrant Home folder.
VAGRANT_HOME=$1
DEVSHOP_HOME="$VAGRANT_HOME/../"
DEVMASTER_VERSION=$2
AEGIR_HOME="$DEVSHOP_HOME/aegir-home"

DEVMASTER_ROOT="$DEVSHOP_HOME/aegir-home/devmaster-$DEVMASTER_VERSION"

if [ ! -d "$DEVSHOP_HOME/aegir-home" ]; then
  echo "Æ | Creating aegir-home directory..."
  mkdir "$DEVSHOP_HOME/aegir-home"
fi

# Build a full devshop frontend on the host with drush make, with working-copy option.
if [ ! -d $DEVMASTER_ROOT ]; then
   drush make $DEVSHOP_HOME/build-devmaster.make $DEVMASTER_ROOT --working-copy --no-gitinfofile
   cp $DEVMASTER_ROOT/sites/default/default.settings.php $DEVMASTER_ROOT/sites/default/settings.php
   mkdir $DEVMASTER_ROOT/sites/local.devshop.site
   chmod 777 $DEVMASTER_ROOT/sites -R
fi

# Clone drush packages.
if [ ! -d $AEGIR_HOME/.drush ]; then
    echo "Æ | Creating .drush/commands folder..."
    cd $AEGIR_HOME
    mkdir -p .drush/commands
    cd .drush/commands
    echo "Æ | Cloning Provision..."
    git clone git@git.drupal.org:project/provision.git
    cd provision
    git checkout $AEGIR_VERSION

    cd ..
    echo "Æ | Cloning Registry Rebuild..."
    git clone git@git.drupal.org:project/registry_rebuild.git --branch 7.x-2.x

    cd $AEGIR_HOME
    chmod 777 .drush -R
fi

# Clone ansible roles.
cd $DEVSHOP_HOME
if [ ! -d roles ]; then
    mkdir roles
    ansible-galaxy install -r roles.yml -p roles
    cd roles

    # Overwrite the roles installed by galaxy with git clones of Our Roles
    rm -rf opendevshop.aegir-user opendevshop.aegir-apache opendevshop.aegir-nginx opendevshop.devmaster opendevshop.devshop
    git clone git@github.com:opendevshop/ansible-role-aegir-user.git opendevshop.aegir-user
    git clone git@github.com:opendevshop/ansible-role-aegir-apache.git opendevshop.aegir-apache
    git clone git@github.com:opendevshop/ansible-role-aegir-nginx.git opendevshop.aegir-nginx
    git clone git@github.com:opendevshop/ansible-role-devmaster.git opendevshop.devmaster
    git clone git@github.com:opendevshop/ansible-role-devshop.git opendevshop.devshop

fi
