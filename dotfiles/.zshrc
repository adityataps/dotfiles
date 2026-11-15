# Homebrew: support Apple Silicon and Intel, including new/remote terminals.
if [[ -z ${HOMEBREW_PREFIX:-} ]]; then
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x $brew_bin ]]; then
      eval "$("$brew_bin" shellenv)"
      break
    fi
  done
  unset brew_bin
fi

# Keep PATH stable when reloading this file.
typeset -U path PATH
export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
export GOPATH="${GOPATH:-$HOME/go}"
path=("$PNPM_HOME" "$GOPATH/bin" $path)

# Oh My Zsh is optional for startup; full setup (-i) installs it.
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_THEME='bureau'
zstyle ':omz:update' mode reminder
plugins=(git)
if (( $+commands[gh] )); then
  plugins+=(gh)
fi
if [[ ${TERM_PROGRAM:-} == iTerm.app ]]; then
  plugins+=(iterm2)
  zstyle ':omz:plugins:iterm2' shell-integration yes
fi
if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
elif [[ -o interactive ]]; then
  autoload -Uz compinit
  compinit
  PROMPT='%n@%m %~ %# '
fi

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE
export EDITOR="${EDITOR:-vi}"

# Shell configuration
alias zshrc='${EDITOR} ~/.zshrc'
alias zshrcr='source ~/.zshrc'
alias zshrcx='exec zsh'

# Languages and frameworks
alias tf='terraform'
alias otf='tofu'
alias py3='python3'
alias cq='cloudquery'

# Docker
alias dc='docker compose'
alias dcup='docker compose up -d'
alias dcdn='docker compose down'
alias dcr='docker compose run'
alias drit='docker run -it'
alias dps='docker ps'
alias dpsa='docker ps -a'

# Networking
alias myip='curl -fsS https://ifconfig.me; echo'
alias myipv4='curl -4 -fsS https://ifconfig.me; echo'
alias myipv6='curl -6 -fsS https://ifconfig.me; echo'

# Packages: a deliberate, explicit full upgrade.
alias brewup='brew update && brew upgrade && brew cleanup'

# Directory listings
if [[ $OSTYPE == darwin* ]]; then
  alias ls='ls -G'
else
  alias ls='ls --color=auto'
fi
alias ll='ls -lh'
alias la='ll -a'
alias lx='la -d .*'
alias lt='la -ltr'
alias grep='grep --color=auto'
alias please='sudo'
alias pretty-please='sudo'

# nvm: use the upstream location first, then an existing Homebrew install.
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
elif [[ -n ${HOMEBREW_PREFIX:-} && -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]]; then
  source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
fi

# Rust/cargo (optional).
if [[ -f "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env"
fi

# Machine-specific aliases, virtualenvs, and secrets stay out of this repo.
if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi
