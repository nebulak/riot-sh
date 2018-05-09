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
  su -
  apt-get install sudo -y
  # todo: ask for username
  usermod -aG sudo yourusername
  # todo: reboot machine

  sudo apt-get install jq -y


  ################ Add backports-repo #####################

  # add backports-repo
  # //TODO: check if backports repo is already added
  printf "deb http://deb.debian.org/debian stretch-backports main contrib" > /etc/apt/sources.list.d/stretch-backports.list
  apt-get update

  ################ Core dependencies ######################

  # add moz-install-addon script
  sudo wget -O /usr/local/sbin/install-mozilla-addon http://bernaerts.dyndns.org/download/ubuntu/install-mozilla-addon
  sudo chmod +x /usr/local/sbin/install-mozilla-addon

  # add appimaged
  # source: https://github.com/AppImage/AppImageKit/blob/appimagetool/master/README.md#appimaged-usage
  wget -c "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimaged_1.0_amd64.deb"
  sudo dpkg -i appimaged_*.deb
  systemctl --user add-wants default.target appimaged
  systemctl --user start appimaged

  ################ GAJIM + OMEMO ##########################
  # source: https://hackershell.noblogs.org/post/2017/04/08/gajim-omemo-mit-debian-8-jessie/

  apt-get remove gajim
  apt-get update
  apt-get install gajim
  # apt-get install python-axolotl python-axolotl-curve25519
  apt-get install gajim-omemo gajim-httpupload gajim-urlimagepreview gajim-triggers


  ################# KeePassXC  + Browser-Integration ###############################
  # //TODO: add appimaged
  # https://github.com/AppImage/AppImageKit/blob/appimagetool/master/README.md#appimaged-usage
  LATEST_TAG= $(get_latest_release 'keepassxreboot/keepassxc')
  wget https://github.com/keepassxreboot/keepassxc/releases/download/$LATEST_TAG/KeePassXC-$LATEST_TAG-x86_64.AppImage
  # //TODO: move to right directory
  # //TODO: install
  # example: ./appimaged-x86_64.AppImage --install

  sudo install-mozilla-addon https://addons.mozilla.org/firefox/downloads/latest/881663/addon-881663-latest.xpi

  ################ Thunderbird + Enigmail + Monterail ###################
  apt-get install thunderbird
  apt-get install enigmail

  ############### TorBirdy ##################################
  # //TODO: download & install from moziila
  apt-get install torbirdy

  ############### Tor & Tor-Browser #########################
  # source: https://wiki.debian.org/TorBrowser#Debian_9_.22Stretch.22
  apt-get install torbrowser-launcher -t stretch-backports
  # //TODO: delete
  # torbrowser-launcher
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
