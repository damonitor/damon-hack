#!/bin/bash

bindir=$(dirname "$0")

if ! grep --quiet "Host gitolite.kernel.org" "$HOME/.ssh/config"
then
	echo "$HOME/.ssh/config has no lines for gitolite.kernel.org"
	echo "You may refer to $bindir/_ssh_config"
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

if [ ! -f $HOME/.gnupg/sshcontrol ]
then
	echo "Add keygrip to $HOME/.gnupg/sshcontrol"
	echo "You may use gpg --list-secret-keys --with-keygrip to get keygrip"
	exit 1
fi

if ! diff "$bindir/_gpg_agent_conf" "$HOME/.gnupg/gpg-agent.conf"
then
	echo "Please tset $HOME/.gnupg/gpg-agent.conf same to $bindir/_gpg_agent_conf"
	exit 1
fi

if ! which pinentry-tty > /dev/null
then
	echo "pinentry-tty not found"
	exit 1
fi

gpg-connect-agent updatestartuptty /bye > /dev/null
ssh gitolite.kernel.org help > /dev/null
ssh git@github.com &> /dev/null
