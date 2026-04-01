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

# Utilize install zsh plugins with the following
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Initialize Starship for cool terminal!
eval "$(starship init zsh)"

# System Management Aliases
alias update-install="~/dotfiles/scripts/update-install"

#check for updates and perform dry run test
alias update-check="brew update && brew outdated; mas outdated; softwareupdate -l"

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
alias sys="fastfetch --logo none --structure Title:OS:Kernel:Uptime:Battery"

# Launch mistral-devstral model with gpu usage and instant startup prompt
alias aistart="cd ~/ai-lab/koboldcpp && python3 koboldcpp.py --model /Users/jchambers/ai-lab/ai_models/Qwen2.5-Coder-14B-Instruct-Q6_K.gguf --gpulayers 99 --smartcontext --flashattention; cd -"
