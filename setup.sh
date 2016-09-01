#!/usr/bin/env bash

set -e

currentDir=`pwd`

#### Link .bash_profile
if [ -f ~/.bash_profile ] && [ ! -L ~/.bash_profile ]; then
	echo 'You seem to have a .bash_profile created in your homedir. Please remove before running setup.sh...exiting'
	exit 1
fi

if [ ! -d $currentDir ] || [ ! -f $currentDir/.bash_profile ]; then
	echo 'It seems we cannot find the sourcefile for symlinking .bash_profile. Are you executing setup.sh from within the dotfiles dir? If not - do so.'
	exit 1
fi

echo 'Creating link for .bash_profile in homedir...'
ln -s $currentDir/.bash_profile ~/.bash_profile

if [ ! -L ~/.bash_profile ]; then
	echo 'Could not create symlink for bash_profile, exiting...'
	exit 1
fi

#### Link .bash_aliases
if [ -f ~/.bash_aliases ] && [ ! -L ~/.bash_aliases ]; then
	echo 'You seem to have a .bash_aliases created in your homedir. Please remove before running setup.sh...exiting'
	exit 1
fi

if [ ! -d $currentDir ] || [ ! -f $currentDir/.bash_aliases ]; then
	echo 'It seems we cannot find the sourcefile for symlinking .bash_aliases. Are you executing setup.sh from within the dotfiles dir? If not - do so.'
	exit 1
fi

echo 'Creating link for .bash_aliases in homedir...'
ln -s $currentDir/.bash_aliases ~/.bash_aliases

if [ ! -L ~/.bash_aliases ]; then
	echo 'Could not create symlink for .bash_aliases, exiting...'
	exit 1
fi


##### Link .gitconfig
if [ -f ~/.gitconfig ] && [ ! -L ~/.gitconfig ]; then
	echo 'You seem to have a .gitconfig created in your homedir. Please remove before running setup.sh...exiting'
	exit 1
fi

if [ ! -d $currentDir ] || [ ! -f $currentDir/.gitconfig ]; then
	echo 'It seems we cannot find the sourcefile for symlinking .gitconfig. Are you executing setup.sh from within the dotfiles dir? If not - do so.'
	exit 1
fi

echo 'Creating link for .gitconfig in homedir...'
ln -s $currentDir/.gitconfig ~/.gitconfig

if [ ! -L ~/.gitconfig ]; then
	echo 'Could not create symlink for .gitconfig, exiting...'
	exit 1
fi
