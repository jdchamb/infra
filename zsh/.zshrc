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
alias zsh-reload="source ~/.zshrc && echo 'Zsh config reloaded!'"

#fastfetch
alias sys="fastfetch"
alias sys="fastfetch --logo none --structure Title:OS:Kernel:Uptime:Battery"

# This tells Zsh to complete files (-f) from the specific directory (-W) for the 'aistart' command
compdef '_path_files -W ~/ai-lab/ai_models' aistart

# Launch ai cli chat function 
aistart() {
    local model_name="${1:-mistralai_Devstral-Small-2-24B-Instruct-2512-Q4_K_M.gguf}"
    # 1. New: Store the full file path in a variable to keep the code tidy
    local model_path="$HOME/ai-lab/ai_models/$model_name"

    # 2. New: The Fail-Safe Check
    if [ ! -f "$model_path" ]; then
        echo "❌ Error: Model file not found at $model_path"
        echo "💡 Tip: Make sure the filename is correct or use Tab completion!"
        return 1
    fi

    echo "🧠 Loading model: $model_name"
    
    cd ~/ai-lab/koboldcpp
    # 3. New: Uses the $model_path variable we checked above
    python3 koboldcpp.py --model "$model_path" --gpulayers 99 --smartcontext --flashattention --cli
    cd -
}
