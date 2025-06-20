# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to 'random', it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME='robbyrussell'
ZSH_THEME='bureau'

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( 'robbyrussell' 'agnoster' )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE='true'

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE='true'

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS='true'

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS='true'

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE='true'

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION='true'

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS='%F{yellow}waiting...%f'
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS='true'

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY='true'

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# 'mm/dd/yyyy'|'dd.mm.yyyy'|'yyyy-mm-dd'
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git iterm2 dotenv)

# source $HOMEBREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
# bindkey              '^I'         menu-complete
# bindkey '$terminfo[kcbt]' reverse-menu-complete
# bindkey "^[[1;2A" up-line-or-history    # Shift + Up Arrow
# bindkey "^[[1;2B" down-line-or-history  # Shift + Down Arrow
# zstyle ':autocomplete:*' delay 0.5  # seconds (float)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH='/usr/local/man:$MANPATH'

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS='-arch x86_64'

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig='mate ~/.zshrc'
# alias ohmyzsh='mate ~/.oh-my-zsh'

# ~/.zshrc
alias zshrc='vim ~/.zshrc'                           # Open `.zshrc` for editing
alias zshrcr='source ~/.zshrc'                       # Reload `.zshrc` without restarting shell
alias zshrcx='echo "Restarting zsh...";exec zsh'     # Restart zsh shell

# Languages and frameworks
alias tf='terraform'
alias otf='tofu'
alias py3='python3'
alias cq="cloudquery"
alias env-dbt='source ~/Documents/dev/env/dbt-env/bin/activate'

# Docker
alias dc='docker compose'
alias dcup='docker compose up -d'   # Detached mode
alias dcdn='docker compose down'
alias dcr='docker compose run'
alias drit='docker run -it'
alias dps='docker ps'
alias dpsa='docker ps -a'

# Networking
alias myip='curl ifconfig.me'
alias myipv4='curl -4 ifconfig.me'  # Get external IP address
alias myipv6='curl -6 ifconfig.me'  # Get external IP address

# Packages
alias brewup='brew update && brew upgrade && brew cleanup'

# Directory
alias ls='ls -G'    # Enable colors for ls
alias ll='ls -l'    # Long listing format
alias la='ll -a'    # Long listing with hidden files
alias lx='la -d .*' # List only hidden files
alias lt='la -ltr'  # List by modification time, reverse order

# Misc
alias grep='grep --color=auto'  # Grep with color
alias please='sudo'
alias pretty-please="echo 'Executing with 'pretty please with a cherry on top' command.';sudo"

# pnpm
export PNPM_HOME="/Users/aditapalshkar/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# nvm end

export GITCONFIG_SAFE_DIRECTORY=/mnt/devbox
[[ -v GITCONFIG_SAFE_DIRECTORY ]] && find "$GITCONFIG_SAFE_DIRECTORY" -name '.git' -type d -exec bash -c 'git config --global --add safe.directory ${0%/.git}' {} \; || echo "GITCONFIG_SAFE_DIRECTORY is not set";

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/root/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/root/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/root/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/root/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export CUDA_VISIBLE_DEVICES=0
