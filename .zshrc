#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  #source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi
export TERM="xterm-256color"
export ZSH="$HOME/.oh-my-zsh"
export INTERFACES="wlp2s0"
export LANG="en_US.UTF-8"
PATH=$PATH:~/.local/bin
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=( 
  z 
  zsh-autosuggestions
)
source $ZSH/oh-my-zsh.sh
# stty -ixon
source ~/.zsh_aliases
source ~/miniconda3/bin/activate && conda deactivate
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
