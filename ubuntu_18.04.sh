# Startup script for Ubuntu 18.04 VPS on Vultr (Dev machine and cloud server)

#---- as root ----

# add a new user
adduser --disabled-password --gecos "" zach
usermod -aG sudo zach
sudo sh -c "echo \"zach ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers"


# Setup SSH
mkdir -p /home/zach/.ssh
cp ~/.ssh/authorized_keys /home/zach/.ssh
chown -R zach:zach /home/zach/
# This was recommend, why? chown root:root /home/zach
chmod 700 /home/zach/.ssh
chmod 644 /home/zach/.ssh/authorized_keys

#---- as zach ----
su - zach

# install some useful bits
sudo apt update && sudo apt full-upgrade -y;
sudo apt install -y git zsh wget curl rbenv mosh tree tmux git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev;

# Setup zsh and oh my!
sudo chsh -s /bin/zsh zach
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"


# Setup my tools
mkdir ~/tools
curl -fLo ~/tools/update-all.sh https://raw.githubusercontent.com/zdrummond/machine_setup/master/tools/update-all.sh
curl -fLo ~/tools/ssh-agent.sh https://raw.githubusercontent.com/zdrummond/machine_setup/master/tools/ssh-agent.sh
curl -fLo ~/tools/ssh-copy-github.sh https://raw.githubusercontent.com/zdrummond/machine_setup/master/tools/ssh-copy-github.sh
curl -fLo ~/tools/ssh-copy-github.sh https://raw.githubusercontent.com/zdrummond/machine_setup/master/tools/add-swap.sh
chmod +x ~/tools/update-all.sh
chmod +x ~/tools/ssh-agent.sh
chmod +x ~/tools/ssh-copy-github.sh
chmod +x ~/tools/add-swap.sh

# Setup local SSH key
# Create a new SSH key for this machine and store the passowrd using my public key
openssl rand -base64 20 | tee >(keybase pgp encrypt --no-self -o ~/.ssh/id_rsa_pwd.pgp zdrummond) | xargs -I{} ssh-keygen -t rsa -b 4096 -C "zdrummond@gmail.com" -N {} -f ~/.ssh/id_rsa


# Using cloud provider firewall, but if we wanted local firewall...
# enable firewall
# sudo ufw app list;
# sudo ufw allow OpenSSH;
# sudo ufw allow mosh;
# sudo ufw enable;

# configure git  -- don't forget to add the RSA key to GitHub, GitLab, etc.
git config --global color.ui true;
git config --global user.name "Zachary Drummond";
git config --global user.email "zdrummond@gmail.com";
echo "after adding the SSH key to your GitHub account, run `ssh -T git@github.com` to test the connection.";
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"


#Install rbenv and nodenv
cd $HOME
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

curl -fsSL https://github.com/nodenv/nodenv-installer/raw/master/bin/nodenv-installer | bash

echo 'export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/plugins/ruby-build/bin:$HOME/.nodenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(rbenv init -)"' >> ~/.zshrc
echo 'eval "$(nodenv init -)"' >> ~/.zshrc

source ~/.zshrc

# check for latest version of ruby at https://www.ruby-lang.org/en/downloads/releases/
rbenv install 2.6.3
rbenv global 2.6.3
nodenv install 10.16.0
nodenv global 10.16.0

# install Yarn package manager
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -;
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list;
sudo apt update && sudo apt install -y --no-install-recommends yarn;

# Config zsh
npm install --global pure-prompt
echo "autoload -U promptinit; promptinit" >> ~/.zshrc
echo "prompt pure" >> ~/.zshrc


# install MySQL
#sudo apt -y install mysql-server mysql-client libmysqlclient-dev;

#### install PostgreSQL
# add the repository
sudo tee /etc/apt/sources.list.d/pgdg.list <<END
deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main
END
# get the signing key and import it
wget https://www.postgresql.org/media/keys/ACCC4CF8.asc
sudo apt-key add ACCC4CF8.asc
# fetch the metadata from the new repo
sudo apt-get update
sudo apt update && sudo apt install -y postgresql-11 postgresql-contrib
sudo apt-get install -y libpq-dev
sudo -u postgres createuser zach -s;

# install Rails (make sure that rbenv is finished installing Ruby, first)
gem install -V rails;
rbenv rehash;

#TODO
# zsh - nice prompt
# 2 factor
# ssh agent tool is having issues and doesnt output errors

