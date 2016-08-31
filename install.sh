#!/usr/bin/env bash
#/ Usage: script/setup [--debug]
#/ Install development dependencies on macOS.

set -e

### Run script with debugging
[ "$1" = "--debug" ] && SETUP_DEBUG="1"

if [ -n "$SETUP_DEBUG" ]; then
  set -x
fi

### Convenience	 functions for the script
abort() { echo "!!! $@" >&2; exit 1; }
log()	 { echo "--> $@"; }
logn()	{ printf -- "--> $@ "; }
logk()	{ echo "OK"; }

### Setting up sudo for script ###
log 'Setting up persistant sudo for script...'
sudo_stat=sudo_stat.txt
echo $$ >> $sudo_stat
trap 'rm -f $sudo_stat >/dev/null 2>$1' 0
trap "exit 2" 1 2 3 15

sudo_me() {
	while [ -f $sudo_stat ]; do
		sudo -v
		sleep 5
	done &
}

#Setting up sudo heartbeat
log "Enter your password (for sudo access):"
sudo -v
sudo_me
logk
###################################

### Check that OS X version is compatible with script
sw_vers -productVersion | grep $Q -E "^10.(11|12)" || {
	abort "Run the script on macOS 10.11/12."
}

### Make sure script is run as yourself, not root.
[ "$USER" = "root" ] && abort "Run the script as yourself, not root."
groups | grep $Q admin || abort "Add $USER to the admin group."

# Set computer name (as done via System Preferences → Sharing)
computerName='Hugin'
read -p "Set computer name [ $computerName ]: " computerName
log "Setting computer name to $computerName"
sudo scutil --set ComputerName "$computerName"
sudo scutil --set HostName "$computerName"
sudo scutil --set LocalHostName "$computerName"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$computerName"
logk

# Install the Xcode Command Line Tools if Xcode isn't installed.
DEVELOPER_DIR=$("xcode-select" -print-path 2>/dev/null || true)
[ -z "$DEVELOPER_DIR" ] || ! [ -f "$DEVELOPER_DIR/usr/bin/git" ] \
                        || ! [ -f "/usr/include/iconv.h" ] && {
  log "Installing the Xcode Command Line Tools:"
  CLT_PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
  sudo touch "$CLT_PLACEHOLDER"
  CLT_PACKAGE=$(softwareupdate -l | \
                grep -B 1 -E "Command Line (Developer|Tools)" | \
                awk -F"*" '/^ +\*/ {print $2}' | sed 's/^ *//' | head -n1)
  sudo softwareupdate -i "$CLT_PACKAGE"
  sudo rm -f "$CLT_PLACEHOLDER"
  if ! [ -f "/usr/include/iconv.h" ]; then
    if [ -n "$SETUP_INTERACTIVE" ]; then
      echo
      logn "Requesting user install of Xcode Command Line Tools:"
      xcode-select --install
    else
      echo
      abort "Run 'xcode-select --install' to install the Xcode Command Line Tools."
    fi
  fi
  logk
}

# Check if the Xcode license is agreed to and agree if not.
xcode_license() {
  if /usr/bin/xcrun clang 2>&1 | grep $Q license; then
    if [ -n "$SETUP_INTERACTIVE" ]; then
      logn "Asking for Xcode license confirmation:"
      sudo xcodebuild -license
      logk
    else
      abort "Run 'sudo xcodebuild -license' to agree to the Xcode license."
    fi
  fi
}
xcode_license

# Setup Homebrew directory and permissions.
logn "Installing Homebrew:"
HOMEBREW_PREFIX="/usr/local"
[ -d "$HOMEBREW_PREFIX" ] || sudo mkdir -p "$HOMEBREW_PREFIX"
sudo chown -R "$USER:admin" "$HOMEBREW_PREFIX"

# Download Homebrew.
export GIT_DIR="$HOMEBREW_PREFIX/.git" GIT_WORK_TREE="$HOMEBREW_PREFIX"
[ -d "$GIT_DIR" ] && HOMEBREW_EXISTING="1"
git init $Q
git config remote.origin.url "https://github.com/Homebrew/brew"
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
if [ -n "$HOMEBREW_EXISTING" ]
then
  git fetch $Q
else
  git fetch $Q --no-tags --depth=1 --force --update-shallow
fi
git reset $Q --hard origin/master
unset GIT_DIR GIT_WORK_TREE HOMEBREW_EXISTING
logk

# Update Homebrew.
export PATH="$HOMEBREW_PREFIX/bin:$PATH"
log "Updating Homebrew:"
brew update
logk

# Install Homebrew Bundle, Cask, Services and Versions tap.
log "Installing Homebrew taps and extensions:"
brew bundle --file=- <<EOF
tap 'caskroom/cask'
tap 'caskroom/versions'
tap 'homebrew/core'
tap 'homebrew/php'
tap 'homebrew/services'
tap 'homebrew/versions'
EOF
logk

# Set some basic security settings.
logn "Configuring security settings:"
defaults write com.apple.Safari \
  com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled \
  -bool false
defaults write com.apple.Safari \
  com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles \
  -bool false
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
sudo launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist 2>/dev/null



### Clean up 
rm $sudo_stat
