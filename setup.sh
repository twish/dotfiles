#!bin/bash

#### Link .bash_profile
if [ -f ~/.bash_profile ] && [ ! -L ~/.bash_profile ]; then
	echo 'You seem to have a .bash_profile created in your homedir. Please remove before running setup.sh...exiting'
	exit 1
fi

echo 'Creating link for .bash_profile in homedir...'
ln -s ./.bash_profile ~/.bash_profile

if [ ! -L ~/.bash_profile ]; then
	echo 'Could not create symlink for bash_profile, exiting...'
	exit 1
fi

#### Link .bash_aliases
if [ -f ~/.bash_aliases ] && [ ! -L ~/.bash_aliases ]; then
	echo 'You seem to have a .bash_aliases created in your homedir. Please remove before running setup.sh...exiting'
	exit 1
fi

echo 'Creating link for .bash_aliases in homedir...'
ln -s ./.bash_aliases ~/.bash_aliases

if [ ! -L ~/.bash_aliases ]; then
	echo 'Could not create symlink for .bash_aliases, exiting...'
	exit 1
fi
