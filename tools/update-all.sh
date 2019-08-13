#!/usr/bin/env bash
echo "Make sure your using sudo!!"
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get autoremove -y
apt-get autoclean -`