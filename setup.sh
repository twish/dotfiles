#!/usr/bin/env bash

set -e

currentDir=`pwd`

#### Link .bash_profile
if [ -f ~/.bash_profile ] && [ ! -L ~/.bash_profile ]; then
	echo 'You seem to have a .bash_profile created in your homedir. Please remove before running setup.sh...'
fi

if [ ! -d $currentDir ] || [ ! -f $currentDir/.bash_profile ]; then
	echo 'It seems we cannot find the sourcefile for symlinking .bash_profile. Are you executing setup.sh from within the dotfiles dir? If not - do so.'
	exit 1
fi

if [ -L ~/.bash_profile ]; then
	echo 'Unlinking current .bash_profile symlink...'
	unlink ~/.bash_profile
fi

echo 'Creating link for .bash_profile in homedir...'
ln -s $currentDir/.bash_profile ~/.bash_profile

if [ ! -L ~/.bash_profile ]; then
	echo 'Could not create symlink for bash_profile, exiting...'
	exit 1
fi

#### Link .bash_aliases
if [ -f ~/.bash_aliases ] && [ ! -L ~/.bash_aliases ]; then
	echo 'You seem to have a .bash_aliases created in your homedir. Please remove before running setup.sh...'
fi

if [ ! -d $currentDir ] || [ ! -f $currentDir/.bash_aliases ]; then
	echo 'It seems we cannot find the sourcefile for symlinking .bash_aliases. Are you executing setup.sh from within the dotfiles dir? If not - do so.'
	exit 1
fi

if [ -L ~/.bash_aliases ]; then
	echo 'Unlinking current .bash_aliases symlink...'
	unlink ~/.bash_aliases
fi

echo 'Creating link for .bash_aliases in homedir...'
ln -s $currentDir/.bash_aliases ~/.bash_aliases

if [ ! -L ~/.bash_aliases ]; then
	echo 'Could not create symlink for .bash_aliases, exiting...'
	exit 1
fi

##### Link .bash_completions
if [ -f ~/.bash_completions ] && [ ! -L ~/.bash_completions ]; then
	echo 'You seem to have a .bash_completions created in your homedir. Please remove before running setup.sh...'
fi

if [ ! -d $currentDir ] || [ ! -f $currentDir/.bash_completions ]; then
	echo 'It seems we cannot find the sourcefile for symlinking .bash_completions. Are you executing setup.sh from within the dotfiles dir? If not - do so.'
	exit 1
fi

if [ -L ~/.bash_completions ]; then
	echo 'Unlinking current .bash_completions symlink...'
	unlink ~/.bash_completions
fi

echo 'Creating link for .bash_completions in homedir...'
ln -s $currentDir/.bash_completions ~/.bash_completions

if [ ! -L ~/.bash_completions ]; then
	echo 'Could not create symlink for .bash_completions, exiting...'
	exit 1
fi


##### Link .gitconfig
if [ -f ~/.gitconfig ] && [ ! -L ~/.gitconfig ]; then
	echo 'You seem to have a .gitconfig created in your homedir. Please remove before running setup.sh...'
fi

if [ ! -d $currentDir ] || [ ! -f $currentDir/.gitconfig ]; then
	echo 'It seems we cannot find the sourcefile for symlinking .gitconfig. Are you executing setup.sh from within the dotfiles dir? If not - do so.'
	exit 1
fi

if [ -L ~/.gitconfig ]; then
	echo 'Unlinking current .gitconfig symlink...'
	unlink ~/.gitconfig
fi

echo 'Creating link for .gitconfig in homedir...'
ln -s $currentDir/.gitconfig ~/.gitconfig

if [ ! -L ~/.gitconfig ]; then
	echo 'Could not create symlink for .gitconfig, exiting...'
	exit 1
fi


##### Link global .gitignore
if [ -f ~/.gitignore ] && [ ! -L ~/.gitignore ]; then
	echo 'You seem to have a .gitignore created in your homedir. Please remove before running setup.sh...'
fi

if [ ! -d $currentDir ] || [ ! -f $currentDir/.gitignore ]; then
	echo 'It seems we cannot find the sourcefile for symlinking .gitignore. Are you executing setup.sh from within the dotfiles dir? If not - do so.'
	exit 1
fi

if [ -L ~/.gitignore ]; then
	echo 'Unlinking current .gitignore symlink...'
	unlink ~/.gitignore
fi

echo 'Creating link for .gitignore in homedir...'
ln -s $currentDir/.gitignore ~/.gitignore

if [ ! -L ~/.gitignore ]; then
	echo 'Could not create symlink for .gitignore, exiting...'
	exit 1
fi
