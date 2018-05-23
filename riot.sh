# Base system: debian stretch
# Debian package search: https://packages.debian.org/search?searchon=names&keywords=gajim-omemo
SCRIPT_NAME="$0"
ARGS="$@"
UPDATE_URL="https://nebulak.github.io/riot-sh"
VERSION="0.0.0"
COMMAND=$1




################ Functions ##############################

# source: https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}


banner() {
  # source: http://patorjk.com/software/taag/#p=display&f=Doom&t=riot.sh
  echo "      _       _         _     "
  echo "     (_)     | |       | |    "
  echo " _ __ _  ___ | |_   ___| |__  "
  echo "| '__| |/ _ \| __| / __| '_ \ "
  echo "| |  | | (_) | |_ _\__ \ | | |"
  echo "|_|  |_|\___/ \__(_)___/_| |_|"
  echo "                              "

}


install() {
  ############### Check core dependencies #################

  # //TODO: ....

  ############### Core Dependencies #######################
  # //TODO: add user to sudoers
  # source: https://unix.stackexchange.com/questions/354928/bash-sudo-command-not-found
  #su -
  #apt-get install sudo -y
  # todo: ask for username
  #usermod -aG sudo yourusername
  # todo: reboot machine

  ################ Install ansible ########################
  # source: https://opensource.com/article/18/3/manage-workstation-ansible
  deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
  sudo apt-get update
  sudo apt-get install ansible
  sudo ansible-pull -U https://github.com/nebulak/riot-ansible.git
  
}

# update riot script
# source: https://bani.com.br/2013/04/shell-script-that-updates-itself/
check_upgrade () {

  # check if there is a new version of this file
  # here, hypothetically we check if a file exists in the disk.
  # it could be an apt/yum check or whatever...
  [ -f "$NEW_FILE" ] && {

    # install a new version of this file or package
    # again, in this example, this is done by just copying the new file
    echo "Found a new version of me, updating myself..."
    cp "$NEW_FILE" "$SCRIPT_NAME"
    rm -f "$NEW_FILE"

    # note that at this point this file was overwritten in the disk
    # now run this very own file, in its new version!
    echo "Running the new version..."
    $SCRIPT_NAME $ARGS

    # now exit this old instance
    exit 0
  }

  echo "I'm VERSION $VERSION, already the latest version."
}


wget_update() {
  sudo wget "$UPDATE_URL/version"
  sudo wget "$UPDATE_URL/riot.sh"
  # //TODO: move to install location
  # //TODO: run new instance
  # echo "Running the new version..."
  # $SCRIPT_NAME $ARGS
}

update() {
  wget_update
}
# //TODO: do semver check of version before update
# source: https://github.com/fsaintjacques/semver-tool/blob/master/src/semver

banner

case "$1" in
        install)
            install # install all package
            ;;

        update)
            install # update core and packages
            ;;

        post-update)
            update # update core and packages
            ;;
        uninstall)
            uninstall # uninstall one or all packages
            ;;
        *)
            echo $"Usage: $0 {install|update|uninstall}"
            exit 1

esac
