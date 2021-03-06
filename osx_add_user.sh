#!/bin/bash

usage() {
    pgm=$(basename $0)
    echo "usage: $pgm login [shell]"
    exit 1
}

login=$1; shift
shell=$1; shift

if [ -z $login ]; then
    usage
fi

if [ -z $shell ]; then
    shell=/sbin/nologin
fi

next_uid=$(($(nireport / /users uid | grep "5[0-9][0-9]" | sort -n | tail -1) + 1))
next_gid=$(($(nireport / /groups gid | grep "5[0-9][0-9]" | sort -n | tail -1) + 1))

echo "# creating user:"
echo "# uid = $next_uid"
echo "# login = $login"
echo "# shell = $shell"

sudo niutil -create / /users/$login
sudo niutil -createprop / /users/$login uid $next_uid
sudo niutil -createprop / /users/$login realname $login
sudo niutil -createprop / /users/$login home "/Users/$login"
sudo niutil -createprop / /users/$login shell $shell
sudo niutil -createprop / /users/$login gid $next_gid
sudo niutil -createprop / /users/$login passwd "*"
sudo /usr/bin/ditto -rsrc /System/Library/User\ Template/English.lproj /Users/$login
sudo chown -R $login:staff /Users/$login

# sudo passwd $login

echo "# to make the user an admin user, execute:"
echo sudo niutil -appendprop / /groups/admin users $login
