# User Local Overrides
alias zconf="vi $ZDOTDIR/.zshrc"
alias sconf="sudo vi /etc/zsh/zshrc"
export PATH="$HOME/.local/bin:$PATH"

extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.zip)       unzip $1       ;;
      *.7z)        7z x $1        ;;
      *)     echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
