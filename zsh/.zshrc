# Add this to the top of your .zshrc to cache completion results
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.zcompcache"

if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    autoload -Uz compinit
    compinit
  fi

# Case-insensitive completion (lowercase matches uppercase)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Use a menu-driven selection (use arrow keys to pick from the list)
zstyle ':completion:*' menu select

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Initialize Starship for cool terminal!
eval "$(starship init zsh)"

# System Management Aliases

## 🚀 The New Standard: update-install
#update-install() {
#  # 1. Force the password prompt BEFORE the logging starts
#  echo -e "\033[1;33m🔐 Please authenticate to begin updates:\033[0m"
#  sudo -v || return 1
#
#  local TIMESTAMP="$(date +'%Y.%m.%d@%I:%M%p')"
#  local LOG_NAME="${TIMESTAMP}-update-install.log"
#  local LOG_DIR="$HOME/Logs/Updates"
#  local LOG_PATH="$LOG_DIR/$LOG_NAME"
#
#  mkdir -p "$LOG_DIR"
#  echo -e "\033[1;34m📝 Logging session to: $LOG_PATH\033[0m"
#
#  # 2. Wrap the logic in a block that 'tee' captures
#  {
#    echo "=== SESSION START: $(date) ==="
#    
#    echo -e "\n--- 🍺 Homebrew ---"
#    brew update --verbose && brew upgrade --verbose && brew cleanup --verbose
#
#    echo -e "\n--- 🍎 App Store ---"
#    mas upgrade
#
#    echo -e "\n--- 💻 macOS System ---"
#    # The 'sudo -n' flag tells it to use the cached password from earlier
#    sudo -n softwareupdate -ia --verbose
#
#    echo -e "\n--- 📂 Bundling System Debug Logs ---"
#    sudo -n log show --predicate 'process == "softwareupdated"' --style syslog --last 10m
#    
#    echo -e "\n=== SESSION END: $(date) ==="
#  } 2>&1 | tee -a "$LOG_PATH"
#
#  say "Updates complete and system logs created successfully"
#}

#update-install() {
#  local TIMESTAMP="$(date +'%Y.%m.%d@%I:%M%p')"
#  local LOG_NAME="${TIMESTAMP}-update-install.log"
#  local LOG_DIR="$HOME/Logs/Updates"
#  local LOG_PATH="$LOG_DIR/$LOG_NAME"
#
#  mkdir -p "$LOG_DIR"
#  
#  echo -e "\033[1;33m🔐 Please authenticate to begin the full update process:\033[0m"
#  # This 'sudo' covers the entire bash block below
#  sudo bash -c "
#    exec 2>&1
#    echo '=== SESSION START: \$(date) ==='
#    
#    echo -e '\n--- 🍺 Homebrew ---'
#    # Homebrew should run as YOU, not root, so we use 'sudo -u'
#    sudo -u $(whoami) brew update --verbose && sudo -u $(whoami) brew upgrade --verbose && sudo -u $(whoami) brew cleanup --verbose
#
#    echo -e '\n--- 🍎 App Store ---'
#    sudo -u $(whoami) mas upgrade
#
#    echo -e '\n--- 💻 macOS System ---'
#    softwareupdate -ia --verbose
#
#    echo -e '\n--- 📂 Bundling System Debug Logs ---'
#    log show --predicate 'process == \"softwareupdated\"' --style syslog --last 10m
#    
#    echo -e '\n=== SESSION END: \$(date) ==='
#  " | tee -a "$LOG_PATH"
#
#  say "Updates complete and system logs created successfully"
#}

#update-install() {
#  # 1. Ask for sudo once at the very start
#  echo -e "\033[1;33m🔐 Authenticate to start the update session:\033[0m"
#  sudo -v || return 1
#
#  local TIMESTAMP="$(date +'%Y.%m.%d@%I:%M%p')"
#  local LOG_DIR="$HOME/Logs/Updates"
#  local MAIN_LOG="$LOG_DIR/${TIMESTAMP}-summary.log"
#  local SYSTEM_LOG="$LOG_DIR/${TIMESTAMP}-system-debug.log"
#
#  mkdir -p "$LOG_DIR"
#  echo -e "\033[1;34m🚀 Starting updates. Summary will be at: $MAIN_LOG\033[0m"
#
#  {
#    echo "=== SUMMARY START: $(date) ==="
#    
#    echo -e "\n--- 🍺 Homebrew ---"
#    brew update && brew upgrade && brew cleanup
#
#    echo -e "\n--- 🍎 App Store ---"
#    mas upgrade
#
#    echo -e "\n--- 💻 macOS System ---"
#    sudo softwareupdate -ia --verbose
#    
#    echo -e "\n=== SUMMARY END: $(date) ==="
#  } 2>&1 | tee -a "$MAIN_LOG"
#
#  # 2. THE SECRET MOVE: Send the heavy logs to a separate file ONLY (no tee)
#  echo -e "\n--- 📂 Archiving System Debug Logs (Background) ---"
#  sudo log show --predicate 'process == "softwareupdated"' --style syslog --last 10m > "$SYSTEM_LOG" 2>&1
#
#  echo -e "\033[1;32m✅ Done! Summary: $(basename $MAIN_LOG)\033[0m"
#  echo -e "\033[1;32m📂 Debug Logs: $(basename $SYSTEM_LOG)\033[0m"
#  
#  say "Update complete"
#}

update-install() {
  local TIMESTAMP="$(date +'%Y.%m.%d@%I:%M%p')"
  local LOG_DIR="$HOME/Logs/Updates"
  local LOG_PATH="$LOG_DIR/${TIMESTAMP}-update-install.log"
  local DEBUG_LOG="$LOG_DIR/${TIMESTAMP}-system-debug.log"

  mkdir -p "$LOG_DIR"
  
  echo -e "\033[1;33m🔐 Please authenticate to begin the full update process:\033[0m"
  
  # We run the block, but we DON'T pipe the whole thing to tee yet.
  # This ensures the password prompt is 'clean'.
  sudo bash -c "
    # Redirect all output of THIS bash session to the log file AND terminal
    exec > >(tee -a '$LOG_PATH') 2>&1

    echo '=== SESSION START: \$(date) ==='
    
    echo -e '\n--- 🍺 Homebrew ---'
    sudo -u $(whoami) brew update --verbose && \
    sudo -u $(whoami) brew upgrade --verbose && \
    sudo -u $(whoami) brew cleanup --verbose

    echo -e '\n--- 🍎 App Store ---'
    sudo -u $(whoami) mas upgrade

    echo -e '\n--- 💻 macOS System ---'
    softwareupdate -ia --verbose

    echo -e '\n--- 📂 Archiving System Debug Logs (Silent) ---'
    # This part DIVERTS to a separate file so it doesn't flood your screen
    log show --predicate 'process == \"softwareupdated\"' --style syslog --last 10m > '$DEBUG_LOG' 2>&1
    
    echo -e '\n=== SESSION END: \$(date) ==='
    echo -e '\n✅ Main Log: \$(basename '$LOG_PATH')'
    echo -e '✅ Debug Log: \$(basename '$DEBUG_LOG')'
  "

  say "Updates complete and system logs created successfully"
}

#check for updates and perform dry run test
alias upgrade-check="brew update && brew outdated; mas outdated; softwareupdate -l"

# This alias gives you a one-word command to see the logs
alias update-logs="sudo log stream --predicate 'process == \"softwareupdated\"' --level debug"

# Ask for confirmation before deleting files
alias rm="rm -i"

# Prevent accidental overwrites when moving or copying
alias mv="mv -i"
alias cp="cp -i"

# Shorten session changes for the terminal session 
alias reload="source ~/.zshrc && echo 'Zsh config reloaded!'"

#fastfetch
alias sys="fastfetch"
#alias sys="fastfetch --logo none --structure Title:OS:Kernel:Uptime:Battery"
