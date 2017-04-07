# Let's install composer:
cd /tmp/
curl -sS https://getcomposer.org/installer | php && sudo mv composer.phar /usr/local/bin/composer

# Go to home folder and donwload + install Gitify
cd ~
git clone https://github.com/modmore/Gitify.git Gitify
cd Gitify

# Make sure gitify is globally available
echo "export PATH=/home/vagrant/Gitify/:$PATH" >> ~/.profile
export PATH=/home/vagrant/Gitify/:$PATH

# Refresh profile
source ~/.profile

# install dependencies and make executable
composer install
sudo chmod +X Gitify

# Now let's set up gitify in the www-folder:
# and install the latest modx:
cd /var/www/project
Gitify modx:install latest

# Install all the packages that are specified in the .gitify-file in project/.gitify
## Gitify install:package --all

# Extract all the settings & files specified in the .gitify-file in project/.gitify
## Gitify build
