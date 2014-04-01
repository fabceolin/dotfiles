# Path to your oh-my-zsh configuration.
ZSH=/home/ceolin/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# ZSH_THEME="robbyrussell"
ZSH_THEME="agnoster"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment this to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often to auto-update? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
# DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment following line if you want to the command execution time stamp shown 
# in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

export PATH="/home/ceolin/mingw-w64/lib:/home/ceolin/mingw-w64/bin:/home/ceolin/bin:/usr/lib/lightdm/lightdm:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/jvm/java-8-oracle/bin:/usr/lib/jvm/java-8-oracle/db/bin:/usr/lib/jvm/java-8-oracle/jre/bin"
# export MANPATH="/usr/local/man:$MANPATH"

# # Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"
alias history='fc -l -d'
eval $(dircolors /home/ceolin/src/vcs/dircolors-solarized/dircolors.ansi-dark)

# Instalacao das Funcoes ZZ (www.funcoeszz.net)
#export ZZOFF=""  # desligue funcoes indesejadas
#export ZZPATH="/home/ceolin/src/vcs/funcoeszz/funcoeszz"  # script
#export ZZDIR="/home/ceolin/src/vcs/funcoeszz/zz"
#source "$ZZPATH"

export BYOBU_NO_TITLE=1

# PATH=$PATH:/home/Alexandre/bin:/usr/x86_64-w64-mingw32/sys-root/mingw/bin

PATH=$PATH:$HOME/opt/android-sdk-linux/tools
PATH=$PATH:$HOME/opt/android-sdk-linux/platform-tools
PATH=$PATH:$HOME/opt/android-ndk-r9c/toolchains/arm-linux-androideabi-4.6/prebuilt/linux-x86_64/bin/
 
export ANDROID_NDK_TOOLCHAIN_ROOT=$HOME/opt/android-ndk-r9c/toolchains/arm-linux-androideabi-4.6/prebuilt/linux-x86_64/
export ANDTOOLCHAIN=$HOME/opt/android-cmake/toolchain/android.toolchain.cmake
alias cmake-android='cmake -DCMAKE_TOOLCHAIN_FILE=$ANDTOOLCHAIN'
ulimit -c unlimited

bindkey -v
bindkey -M viins 'jj' vi-cmd-mode
bindkey '^R' history-incremental-search-backward
bindkey -M viins '\e.' insert-last-word
autoload edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line
