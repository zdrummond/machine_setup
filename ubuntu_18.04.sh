# Startup script for Ubuntu 18.04 VPS on Vultr (Dev machine and cloud server)

# Apply latest patches
sudo -s -- <<EOF
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get autoremove -y
apt-get autoclean -y
EOF

# add a new user @todo: make this a one-liner
adduser --disabled-password --gecos "" zach
usermod -aG sudo zach
sudo sh -c "echo \"zach ALL=(all) NOPASSWD:ALL\" >> /etc/sudoers"


# Setup SSH
mkdir -p /home/zach/.ssh
cp ~/.ssh/authorized_keys /home/zach/.ssh
chown -R zach:zach /home/zach/
chown root:root /home/zach
chmod 700 /home/zach/.ssh
chmod 644 /home/zach/.ssh/authorized_keys


## MANUALLY LOG OUT AS ROOT AND LOG IN AS NEW USER

# OPTIONAL: to add ssh key, assuming that you have ssh-copy-id installed on local machine and your keypair is in ~/.ssh and named id_rsa:
# Locally, i.e. on your laptop.  eg. ssh-copy-id stvhwrd@45.63.10.205
ssh-copy-id stvhwrd@<IP_ADDRESS_OF_SERVER>

# log in with ssh key
# eg. ssh stvhwrd@45.63.10.205
ssh stvhwrd@<IP_ADDRESS_OF_SERVER>

# install some useful bits
sudo apt update && sudo apt full-upgrade -y;
sudo apt install -y git zsh wget curl rbenv curl mosh tree vim tmux git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev;

cd $HOME
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
exec $SHELL

# check for latest version of ruby at https://www.ruby-lang.org/en/downloads/releases/
rbenv install 2.4.1
rbenv global 2.4.1
ruby -v

# enable firewall
sudo ufw app list;
sudo ufw allow OpenSSH;
sudo ufw allow mosh;
sudo ufw enable;

# configure git  -- don't forget to add the RSA key to GitHub, GitLab, etc.
git config --global color.ui true;
git config --global user.name "Stevie Howard";
git config --global user.email "stvhwrd@uvic.ca";
ssh-keygen -t rsa -b 4096 -C "stvhwrd@uvic.ca";
echo "after adding the SSH key to your GitHub account, run `ssh -T git@github.com` to test the connection.";

# install NodeJS
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -;
sudo apt install -y nodejs;

# install Yarn package manager
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -;
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list;
sudo apt update && sudo apt install -y yarn;

# install MySQL
sudo apt -y install mysql-server mysql-client libmysqlclient-dev;

# install PostgreSQL
sudo sh -c "echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -;
sudo apt update && sudo apt install -y postgresql-common;
sudo apt install -y postgresql-9.5 libpq-dev;
sudo -u postgres createuser stvhwrd -s;

# install Rails (make sure that rbenv is finished installing Ruby, first)
gem install -V rails;
rbenv rehash;
