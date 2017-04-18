_You need to have [Vagrant](https://www.vagrantup.com/) and [Virtualbox](https://www.virtualbox.org/wiki/Downloads) installed on your computer_

# MODX Gitify Vagrant
This repository aims to make it easy to setup a local MODX environment with 
[Gitify](https://docs.modmore.com/en/Open_Source/Gitify/index.html) on a Vagrant virtual machine.

## Initial Setup
Here is a small guide to get you started. You only need to run the following commands once.

### Setting up the local database
Open `vagrant/puppet/manifests/main.pp` and replace `$database_name`, `$database_user` & `$database_password` with something of your liking. When you're using MODX Cloud you may want to use the same database name, user and database password. The details you can find on the projectpage on https://dashboard.modxcloud.com/.

### Vagrant
_Run `vagrant global-status` to check if there are no running vagrant boxes_
In your terminal navigate to the `vagrant`-folder and type the following commands:
```
vagrant up
```

Make sure the box is up to date:
```
vagrant box update
```

### Setting up MODX
Let's setup MODX within the virtual machine:
```
vagrant ssh
cd /vagrant
./install_gitify.sh
exit
```

This will log you into the virtualmachine, open the vagrant folder,
install Composer (Gitify dependency), Gitify and the latest version of MODX and log you out of the virtual machine again.

*During this process Gitify will ask you for some input. Fill in:*
* **Database Host:** localhost _(default, you can just press enter)_
* **Database Name:** _see puppet/manifests/main.pp_
* **Database User:** _see puppet/manifests/main.pp_
* **Database Password:** _see puppet/manifests/main.pp_
* **Database Prefix:** MODX\_ _(default, you can just press enter)_
* **Hostname:** vagrant-ubuntu-trusty-64 _(default, you can just press enter)_
* **Base URL:** / _(default, you can just press enter)_
* **Manager Language:** EN _(default, you can just press enter)_
* **Manager User:** project\_admin _(default, you can just press enter)_
* **Manager User Password:** _leave empty and write down the generated password_
* **Manager Email:** _(you can just press enter or enter your e-mailaddress)_

MODX will be installed, this may take a while. ☕ After this you can access your fresh MODX installation on http://192.168.33.10.

## Using your virtual machine
To run Vagrant all you need to do is point your CLI to the vagrant folder:
```
cd vagrant
vagrant up
```
After your Vagrant box has started open http://192.168.33.10 in your browser. To stop Vagrant type `vagrant halt` ✋ from within the `vagrant`-folder (or `vagrant destroy` ⚠ to delete the complete virtual machine).

### Using Gitify-commands
For your convenience Gitify is installed within the Vagrant box. Change the [.gitify-file](/project/.gitify) to your liking. To use the [Gitify-commands](https://docs.modmore.com/en/Open_Source/Gitify/Commands/index.html) you first need to login to your Vagrant box and go to the directory where the .gitify-file is stored:
```
vagrant ssh
cd /var/www/project
```
From within this folder you can use Gitify-commands like `Gitify extract`. See the  [Gitify-documentation](https://docs.modmore.com/en/Open_Source/Gitify/index.html) for more information. If you get the error `Gitify: command not found`, run `source ~/.profile` and try again.

### Optional: Install extras from modmore.com
_ModMore offers development licenses for premium extras. These are only available
through [certain domain names](https://https://www.modmore.com/free-development-licenses/)._
For now it is not possible to install these packages through the CLI, so a few extra steps are needed. To be able to use ModMore dev licenses within your Vagrant setup you need to:

* [Add an alias to your hosts-file](https://support.rackspace.com/how-to/modify-your-hosts-file/) 
of `192.168.33.10 vagrant.dev`. You may need to restart your computer before the changes take effect.
* [Create an API-key](https://www.modmore.com/account/api-keys/) on the ModMore website.
* In the folder /project create a file `.modmore.com.key` and paste in the API key you've just created.
* Open the .gitify-file, scroll all the way down and uncomment the values `packages`, `modmore.com`, `service_url`, `username`, `api_key` by removing the hashes `#` in front. Replace username `modmore_username` with the username that is associated with your API-key.
* Run:
 ```
 vagrant ssh
 cd /var/www/project
 Gitify install:package --all
 ```
You will get an error since there are no packages to install, but this will still add ModMore to your package providers with the correct username and API-key. _Note that this command will also install any other extra's you may have specified in the .gitify-file_.
* Go to http://vagrant.dev/manager › Extras › Installer
* Press the little dropdown button next to 'Download Extras' and select 'Select a provider'.
* In the dropdown pick 'modmore.com' and 'Save and go to Package Browser'.
 * _If you run into an error, go to the `providers`-tab, right-click on modmore.com > `Update provider` and check if the API-key are correct_
* You can now download premium ModMore extras for development use!

## Updating a remote server
A remote server can be updated using the `update_from_git.sh` file. This script clones the git-repository on the server and updates an existing MODX-installation there. The advantage of using this method is that the code on the server can always be traced back to a specific commit.

You can use different branches for different servers (`dev` and `master` or `production`).

### Setting up
Before running the first time, it is wise to change the code for testing purposes. Update the code in `update_modx` to not make any changes: add `--dry-run` to the `rsync_options` and comment the line `Gitify build`.

* Install `Gitify` on the server  (for MODX Cloud instances you may want to follow [these instructions](https://github.com/modmore/Gitify/issues/107#issuecomment-112702336))
* Make sure `git` and `rsync` are installed
* Setup MODX as detailed above
* Create an SSH Key on the server ([using `ssh-keygen`](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/))
* Add this key as a valid key for your repository (for GitHub you can [use a deploy key](https://developer.github.com/guides/managing-deploy-keys/))
* Change the options in `update_from_git.sh`:
   - your repository-url
   - the branch that contains the relevant code for this server
   - review the two directories used (git-directory and MODX-directory)
   - review the commands used to update MODX

After testing the script, re-enable the code (remove `--dry-run` and uncomment `Gitify build`).

### Usage
Once the file is uploaded on your server, you can simply run it using:
```
ssh user@server ./update_from_git.sh
```
_note: the above works if the `update_from_git` is in the home-directory. Otherwise, you need to specify the full path_

## Big thanks goes out to:
* MODX & its community
* [ModMore](https://www.modmore.com)

## Planned features:
TODO:
- [ ] Database Sync
