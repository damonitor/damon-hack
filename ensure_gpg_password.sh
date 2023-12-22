#!/bin/bash

bindir=$(dirname "$0")

if ! diff "$bindir/_ssh_config" $HOME/.ssh/config
then
	echo "Please set $HOME/.ssh/config same to $bindir/_ssh_config"
	exit 1
fi


if ! grep --quiet "^export SSH_AUTH_SOCK=\$(gpgconf --list-dirs agent-ssh-socket)" "$HOME/.bashrc"
then
	echo "Add export SSH_AUTH_SOCK=\$(gpgconf --list-dirs agent-ssh-socket) to .bashrc"
	exit 1
fi

if [ ! $(git config --get gpg.program) = "gpg" ]
then
	echo "do git config gpg.program gpg"
	exit 1
fi

gpg-connect-agent updatestartuptty /bye > /dev/null
ssh gitolite.kernel.org help > /dev/null
ssh git@github.com &> /dev/null
