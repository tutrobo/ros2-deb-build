#!/bin/bash

set -e

# for libk4a
echo 'libk4a1.4 libk4a1.4/accepted-eula-hash string 0f5d5c5de396e4fee4c0753a21fee0c1ed726cf0316204edda484f08cb266d76' | debconf-set-selections
echo 'libk4a1.4 libk4a1.4/accept-eula boolean true' | debconf-set-selections

APT_LIST=/etc/apt/sources.list.d/actions-local.list
ROSDEP_LIST=/etc/ros/rosdep/sources.list.d/99-actions-local.list

mkdir /repository

for pkg_path in $(colcon list -tp); do
  (
    cd $pkg_path

    apt update && rosdep update
    rosdep install -yi --from-paths .
    bloom-generate rosdebian
    fakeroot debian/rules binary

    apt_name=$(cat debian/control | awk '$1 == "Package:" { print $2 }')
    rosdep_name=${apt_name#ros-*-}
    rosdep_name=${rosdep_name//-/_}
    deb_path=$(find $(cd .. && pwd) -name $apt_name'*.deb')
    
    cp $deb_path /archives/

    cd /repository

    ln -s $deb_path .
    dpkg-scanpackages . > Packages
    if [ ! -e $APT_LIST ]; then
      echo "deb [trusted=yes] file:///repository ./" > $APT_LIST
    fi

    echo -e "$rosdep_name:\n  ubuntu: [$apt_name]" >> rosdep.yaml
    if [ ! -e $ROSDEP_LIST ]; then
      echo "yaml file:///repository/rosdep.yaml" > $ROSDEP_LIST
    fi
  )
done
