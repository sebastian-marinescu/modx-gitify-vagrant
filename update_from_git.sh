#!/bin/sh

# This file gets the latest version of the software from a specified repository
# and branch and applies the changes to the current version using Gitify
# It is supposed to be run on a remote server
# V0.1 - matthijs@angistudio.com

##################################################################################
# Prerequisites:
# - the server can clone from the repository (for instance deploy key from Github)
# - gitify is installed
# - git is installed
# - rsync is installed
# - permissions are correct for the two folders (temp-dir and modx-dir)
#
# NOTE: the first time this script is run, you may need to add the RSA key
# fingerprint to the list of known hosts. Simply said: run this script manually
# at least once!
##################################################################################

##################################################################################
# Settings
##################################################################################

# The repository url (with "git@github.com:" for github repository):
url="git@github.com:ANGIstudio/modx-gifify-vagrant"

# The branch to check-out:
branch="master"

# Location of ModX root in the repository: (relative path in repository!)
modx_in_repo="project"

# Temporary directory for cloning the repository: (absolute path!)
# NOTE: this directory should not be web-accessible!
temp="/home/vagrant"

# ModX-directory: (absolute path!)
modx="/var/www/project"

# Get the name of the repository: (assuming last part of the URL)
arr=(${url//\// })
gitname=${arr[${#arr[@]}-1]}

# Commands to run after git is up to date:
update_modx() {
  # options for rsync
  # -r                : recursive
  # --delete          : remove everything that is not in the git
  # --itemize-changes : show why files are updated
  # --checksum        : instead of using time/filesize to check for changes use
  #                     checksum. This is done because time is not a good
  #                     indicator in this case and filesize may stay the same
  #                     for simple changes
  # --dry-run         : use for testing purposes
  # NOTE: not using 'a' because that would also update permissions and timestamps
  rsync_options="-r --delete --itemize-changes --checksum" # --dry-run

  # the Gitify data folder
  rsync ${rsync_options} "${temp}/${gitname}/${modx_in_repo}/git/data/" "${modx}/git/data/"

  # Chunks, templates, CSS and javascript
  rsync ${rsync_options} --exclude components "${temp}/${gitname}/${modx_in_repo}/assets/" "${modx}/assets/"

  cd "${modx}"
  Gitify build
}

##################################################################################
# Sanity check
##################################################################################

if [ ! -d "${temp}" ]
then
  echo "ERROR: Temporary directory (${temp}) does not exist." >&2
  exit 1
fi

if [ ! -d "${modx}" ]
then
  echo "ERROR: ModX directory (${modx}) does not exist." >&2
  exit 1
fi

command -v Gitify >/dev/null 2>&1 || { echo "ERROR: Gitify is not installed." >&2; exit 1; }
command -v git >/dev/null 2>&1 || { echo "ERROR: git is not installed." >&2; exit 1; }
command -v rsync >/dev/null 2>&1 || { echo "ERROR: rsync is not installed." >&2; exit 1; }

##################################################################################
# Update Git, or clone if non-existent
##################################################################################

# If the directory doesn't exist: clone, otherwise: update
if [ ! -d "${temp}/${gitname}" ]
then
  echo "Directory ${temp}/${gitname} does not exist. Cloning repository..."
  cd ${temp}
  git clone --branch ${branch} ${url} --depth 1
else
  echo "Cloned already, now pulling latest changes..."
  cd ${temp}/${gitname}
  git pull
fi

##################################################################################
# Updating ModX
##################################################################################

update_modx
