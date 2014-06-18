# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
export GOPATH="/home/ezioruan/mygo:/home/ezioruan/huo_server_go"
export PATH=$PATH:${GOPATH%:*}/bin


# Add environment variable COCOS_CONSOLE_ROOT for cocos2d-x
export COCOS_CONSOLE_ROOT=/home/ezioruan/cocos2d-x-3.0rc1/tools/cocos2d-console/bin
export PATH=$COCOS_CONSOLE_ROOT:$PATH
export PATH=$PATH:~/code/swift-0.94.1/bin/
