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

### Set some scipt variables
read -p "Enter your full name to be used: " userFullName
read -p "Enter your email to be used: " userEmail
tempDir=$(mktemp -d -t tmp.XXXXXXXXXX)

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

# Add login screen message.
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText \
	"Found this computer? Please contact $userFullName at $userEmail."
logk

# Check and enable full-disk encryption.
logn "Checking full-disk encryption status:"
if fdesetup status | grep $Q -E "FileVault is (On|Off, but will be enabled after the next restart)."; then
  logk
elif [ -n "$SETUP_CI" ]; then
  echo
  logn "Skipping full-disk encryption for CI"
elif [ -n "$SETUP_INTERACTIVE" ]; then
  echo
  log "Enabling full-disk encryption on next reboot:"
  sudo fdesetup enable -user "$USER" \
    | tee ~/Desktop/"FileVault Recovery Key.txt"
  logk
else
  echo
  abort "Run 'sudo fdesetup enable -user \"$USER\"' to enable full-disk encryption."
fi

# Check and install any remaining software updates.
logn "Checking for software updates:"
if softwareupdate -l 2>&1 | grep $Q "No new software available."; then
  logk
else
  echo
  log "Installing software updates:"
  if [ -z "$SETUP_CI" ]; then
    sudo softwareupdate --install --all
    xcode_license
  else
    echo "Skipping software updates for CI"
  fi
  logk
fi

# Install latest version of Bash.
logn "Install latest version of Bash:"
brew install bash
if [ -z "$SETUP_CI" ]; then
	sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
	chsh -s /usr/local/bin/bash
else
	echo "Skipping updating shells for CI"
fi
logk

logn "Installing binaries:"
cat > /$tempDir/Brewfile <<EOF
brew 'aria2'
brew 'git'
brew 'gnu-sed', args: ['with-default-names']
brew 'homebrew/versions/bash-completion2'
brew 'hub'
brew 'node'
brew 'wget'
brew 'z'
EOF
brew bundle --file=/$tempDir/Brewfile
rm -f /$tempDir/Brewfile
logk

logn "Installing latest version of NPM:"
npm install -g npm@latest
logk

logn "Installing PHP:"
brew install homebrew/php/php70
sed -i".bak" "s/^\;phar.readonly.*$/phar.readonly = Off/g" /usr/local/etc/php/7.0/php.ini
sed -i "s/memory_limit = .*/memory_limit = -1/" /usr/local/etc/php/7.0/php.ini
if [ -z "$SETUP_CI" ]; then
	brew install homebrew/php/composer
	brew install homebrew/php/php-cs-fixer
else
	echo "Skipping installing composer and php-cs-fixer for CI"
fi
logk

logn "Installing Mac applications:"
export HOMEBREW_CASK_OPTS="--appdir=/Applications";
cat > /tmp/Caskfile <<EOF
cask '1password'
cask 'appcleaner'
cask 'atom'
cask 'couleurs'
cask 'dropbox'
cask 'flux'
cask 'github-desktop'
cask 'google-chrome'
cask 'imagealpha'
cask 'imageoptim'
cask 'qlimagesize'
cask 'qlstephen'
cask 'qlcolorcode'
cask 'sequel-pro'
cask 'sketch'
cask 'skype'
cask 'slack'
cask 'spectacle'
cask 'spotify'
cask 'transmit'
cask 'vlc'
cask 'sublime-text'
cask 'evernote'
cask 'iterm2'
EOF
brew bundle --file=/tmp/Caskfile
rm -f /tmp/Caskfile
logk

# Create Sites directory in user folder.
logn "Create Sites directory in user folder:"
mkdir ~/Sites
logk

# Create projects directory in user folder.
logn "Creating projects directory in user folder."
mkdir ~/projects
logk

# Create screenshot directory in user folder
logn "Create screenshots directory in user forlder."
mkdir ~/Screenshots
logk

# Setup prefered macOS settings.
logn "Setup prefered macOS settings:"

# Menu bar: Always show percentage next to the Battery icon
defaults write com.apple.menuextra.battery ShowPercent YES

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Save screenshots to the screenshots directory
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"

# Enable Secure Keyboard Entry in Terminal.app
# See: https://security.stackexchange.com/a/47786/8918
defaults write com.apple.terminal SecureKeyboardEntry -bool true

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -float 0.000000000001
defaults write NSGlobalDomain InitialKeyRepeat -int 13

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# New Finder windows shows Home directory
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file:///Users/$USER/"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Minimize windows into application icon.
defaults write com.apple.dock minimize-to-application -bool true

# Set the icon size of Dock items to 50 pixels
defaults write com.apple.dock tilesize -int 50
logk

### Clean up 
rm $sudo_stat
rm $tempDir/*
rmdir $tempDir

log 'Finished! Please reboot! Install additional software with `brew install` and `brew cask install`.'