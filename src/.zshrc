# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# ZSH Options
setopt AUTO_CD              # cd by typing directory name
setopt INTERACTIVE_COMMENTS # Allow comments in interactive mode
setopt EXTENDED_GLOB       # Extended globbing
setopt NO_CASE_GLOB       # Case insensitive globbing
setopt NUMERIC_GLOB_SORT  # Sort filenames numerically
setopt EXTENDED_HISTORY    # Write the history file in the ':start:elapsed;command' format
setopt SHARE_HISTORY       # Share history between all sessions
setopt HIST_EXPIRE_DUPS_FIRST # Expire a duplicate event first when trimming history
setopt HIST_IGNORE_DUPS   # Do not record an event that was just recorded again
setopt HIST_FIND_NO_DUPS  # Do not display a previously found event
setopt HIST_IGNORE_SPACE  # Do not record an event starting with a space
setopt HIST_SAVE_NO_DUPS  # Do not write a duplicate event to the history file

# Performance improvements
# Skip compinit on every shell load
skip_global_compinit=1

# Completion settings
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zcompcache"

# Performance optimization settings
HIST_STAMPS="yyyy-mm-dd"

# History configuration
HISTFILE="$HOME/.zsh_history"

# Autosuggestions configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1

# ----------------------------------------------

# Customize colors
typeset -A ZSH_HIGHLIGHT_STYLES
# Syntax Highlighting Colors
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)
# Paste warning (optional)
ZSH_HIGHLIGHT_STYLES[paste]='fg=black,bold,bg=yellow'
# Highlight dangerous commands with red background and white text
ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=white,bold,bg=red')
# Base styles
ZSH_HIGHLIGHT_STYLES[default]=none                   # Default text style
ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=red,bold      # Unknown commands or tokens
ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=yellow        # Shell reserved words (if, for, while, etc.)
# Command styles
ZSH_HIGHLIGHT_STYLES[alias]=fg=cyan,bold            # Command aliases
ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=cyan,bold     # Suffix aliases
ZSH_HIGHLIGHT_STYLES[builtin]=fg=cyan,bold          # Shell builtin commands
ZSH_HIGHLIGHT_STYLES[function]=fg=cyan,bold         # Shell functions
ZSH_HIGHLIGHT_STYLES[command]=fg=cyan,bold          # Regular commands
ZSH_HIGHLIGHT_STYLES[precommand]=fg=cyan,bold,underline  # Commands with precommand modifiers
ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold # Command separators (;, &&, ||)
ZSH_HIGHLIGHT_STYLES[hashed-command]=fg=cyan,bold   # Commands that are hashed (cached)
# Path and globbing styles
ZSH_HIGHLIGHT_STYLES[path]=fg=green,underline       # File paths
ZSH_HIGHLIGHT_STYLES[path_prefix]=fg=green,underline # Path prefixes
ZSH_HIGHLIGHT_STYLES[globbing]=fg=magenta,bold      # Globbing patterns (*, ?, etc.)
# Option styles
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=yellow    # Single-hyphen options (-l)
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=yellow    # Double-hyphen options (--long)
# Argument styles
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=fg=magenta,bold          # Back-quoted arguments (`command`)
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=green,bold          # Single-quoted arguments ('text')
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=green,bold          # Double-quoted arguments ("text")
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=green,bold          # Dollar-quoted arguments ($'text')
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta,bold # Dollar-double-quoted arguments ($"text")
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta,bold   # Back-double-quoted arguments (`"text"`)
ZSH_HIGHLIGHT_STYLES[comment]='fg=grey'      # Comments
ZSH_HIGHLIGHT_STYLES[quoted]='fg=yellow'     # Quoted text

# Assignment style
ZSH_HIGHLIGHT_STYLES[assign]=fg=blue,bold           # Variable assignments (VAR=value)

# ----------------------------------------------

# Install zi if not already installed
if [[ ! -f $HOME/.zi/bin/zi.zsh ]]; then
  print -P "%F{33}▓▒░ %F{160}Installing (%F{33}z-shell/zi%F{160})…%f"
  command mkdir -p "$HOME/.zi" && command chmod go-rwX "$HOME/.zi"
  command git clone -q --depth=1 --branch "main" https://github.com/z-shell/zi "$HOME/.zi/bin" && \
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
    print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

# Load zi
. "$HOME/.zi/bin/zi.zsh"
autoload -Uz _zi
(( ${+_comps} )) && _comps[zi]=_zi

# Load zi annexes and meta-plugins
zi light-mode for \
  z-shell/z-a-meta-plugins \
  @annexes

# Configure OMZP and OMZL shorthands
zi light z-shell/z-a-patch-dl

# Load core zsh plugins SYNCHRONOUSLY for stability
zi ice pick"zcomp.zsh" atload"zicompinit_fast" blockf
zi for \
    zsh-users/zsh-completions \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-history-substring-search \
    zdharma-continuum/fast-syntax-highlighting

# Load git plugin and setup aliases
zi snippet OMZL::git.zsh
zi snippet OMZP::git

# Load cloud/container plugins
# zi wait lucid as"completion" for \
#   https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker \
#   https://raw.githubusercontent.com/docker/compose/master/contrib/completion/zsh/_docker-compose

# Tool-specific plugins with conditional loading
zi wait lucid for \
  has"kubectl" \
    OMZP::kubectl \
  has"terraform" \
    OMZP::terraform \
  has"dotnet" \
    OMZP::dotnet \
  has"go" \
    OMZP::golang \
  has"node" \
    OMZP::node \
  has"yarn" \
    OMZP::yarn \
  has"ruby" \
    OMZP::ruby \
  has"z" \
    OMZP::z \
  has'pip' \
    OMZP::pip \
  has"python" \
    OMZP::python

# ----------------------------------------------

# Modern prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Language environments
export PATH="$HOME/.mise/bin:$PATH"
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi
