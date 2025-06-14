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
	echo "Note tht it should be that for authorize ([A])"
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

output=$(gpg-connect-agent updatestartuptty /bye)
if [ ! "$output" = "OK" ]
then
	echo "gpg-connect-agent updatestartuptty /bye failed"
	exit 1
fi

if ! ssh gitolite.kernel.org help | grep --quiet "list of remote commands available"
then
	echo "gitolite help failed"
	exit 1
fi

if ! ssh -T git@github.com 2>&1 | grep --quiet "successfully authenticated"
then
	echo "ssh -T git@github failed"
	exit 1
fi

exit 0
