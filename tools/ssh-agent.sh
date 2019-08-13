#!/usr/bin/env bash
keybase login zdrummond
eval "$(ssh-agent -s)"
key="$::env(HOME)/.ssh/id_rsa"
cat ~/.ssh/id_rsa_pwd.pgp | keybase pgp decrypt | expect << EOF
  spawn ssh-add $key
  expect "Enter passphrase"
  send "$1\r"
  expect eof
EOF
keybase logout
