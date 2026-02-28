export DEFAULT_PDF_READER="sioyek"

# Functions

# dlist() {
#     for arg in "$@"
#     do
#         find $arg \( -name .git -o -name .npm -o -name .vscode -o -name obj -o -name bin \) -prune -o -type d -print
#     done
# }

# flist() {
#     for arg in "$@"
#     do
#         find $arg \( -name .git -o -name .npm -o -name .vscode -o -name obj -o -name bin \) -prune -o -type f -print
#     done
# }

# flist() {
#     for arg in "$@"
#     do
#         fd $arg 
#     done
# }

# dpick() {
#     dlist "$@" | fzf
# }

# fpick() {
#     flist "$@" | fzf
# }

# sr() {
#     if [ -z "$1" ]; then
#         fpick . | xargs -r -I % $DEFAULT_PDF_READER %"
#     else
#         fpick "$1" | xargs -r -I % $DEFAULT_PDF_READER %"
#     fi
# }

# Replace ls with eza
alias ls='eza'
# Long format with headers and icons
alias ll='eza -l --header --icons'
# Long format including hidden files
alias la='eza -la --header --icons'
# Tree view shortcut
alias tree='eza --tree'


alias nv="NVIM_APPNAME=nn nvim"
alias t="just"
alias zl="zellij list-sessions"
alias za="zellij attach"
alias tvmc="python3 -m tvm.driver.tvmc"
alias czs="nv ~/.zshrc"
alias cal="nv ~/.alias"
alias cts="nv ~/.tmux.conf"
alias cnv="nv ~/.config/nvim"
local logfile="/mnt/e/data/workspace/inbox/log.norg"
alias gl="nv $logfile"
local indexfile="~/workspace/inbox/index.norg"
alias gi="nv $indexfile"
alias gzi="zellij edit -f $indexfile"
# alias sr="fpick . | xargs -r -I % $DEFAULT_PDF_READER %"
alias nvim-scratch="NVIM_APPNAME=scratch nvim"
alias nvim-modern="NVIM_APPNAME=modern nvim"
alias nvim-lazy="NVIM_APPNAME=LazyVim_starter nvim"
alias nvim-kick="NVIM_APPNAME=kickstart nvim"
alias nvim-chad="NVIM_APPNAME=NvChad nvim"
alias nvim-astro="NVIM_APPNAME=AstroNvim nvim"
alias lazyvim="NVIM_APPNAME=lazyvim nvim"
alias lvim="proxychains4 ~/.local/bin/lvim"
alias pc="proxychains4 "
alias mvim="NVIM_APPNAME=mvim nvim"
alias lvf="fd --type f --hidden --exclude .git | fzf --height 60% --reverse --border --preview 'bat - -color=always --style=grid {}' | xargs zellij run -- ~/.local/bin/lvim"
alias cof="git branch --sort=-committerdate | fzf --height 60% --reverse --header 'Checkout New Branch' --preview 'git diff --color=always {1} | delta' --pointer='' | xargs git checkout"
# alias cof="git branch --sort=-committerdate | fzf --header 'Checkout Recent Branch' --preview 'git diff {1} --color=always' --pointer='' | xargs git checkout"
alias tldrf='tldr --list | fzf --preview "tldr {1} --color=always" --preview-window=right,70% | xargs tldr'
plv() { NVIM_APPNAME="lazyvim" proxychains4 nvim $@ }
pmv() { NVIM_APPNAME="mvim" proxychains4 nvim $@ }
function nvims() {
  items=("default" "modern" "scratch" "kickstart" "LazyVim" "NvChad" "AstroNvim")
  config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
  if [[ -z $config ]]; then
    echo "Nothing selected"
    return 0
  elif [[ $config == "default" ]]; then
    config="nvim"
  fi
  NVIM_APPNAME=$config nvim $@
}

# bindkey -s ^a "nvims\n"

export hostip=$(ip route | grep default | awk '{print $3}')
export hostport=10810
export proxy_user=zzf
export proxy_pw=5201314
alias proxy='
    export HTTPS_PROXY="socks5://${proxy_user}:${proxy_pw}@${hostip}:${hostport}";
    export HTTP_PROXY="socks5://${proxy_user}:${proxy_pw}@${hostip}:${hostport}";
    export ALL_PROXY="socks5://${proxy_user}:${proxy_pw}@${hostip}:${hostport}";
    echo -e "Acquire::http::Proxy \"socks5h://${proxy_user}:${proxy_pw}@${hostip}:${hostport}\";" | sudo tee -a /etc/apt/apt.conf.d/proxy.conf > /dev/null;
    echo -e "Acquire::https::Proxy \"socks5h://${proxy_user}:${proxy_pw}@${hostip}:${hostport}\";" | sudo tee -a /etc/apt/apt.conf.d/proxy.conf > /dev/null;
    echo -e "Acquire::socks::Proxy \"socks5h://${proxy_user}:${proxy_pw}@${hostip}:${hostport}\";" | sudo tee -a /etc/apt/apt.conf.d/proxy.conf > /dev/null;
'
alias unproxy='
    unset HTTPS_PROXY;
    unset HTTP_PROXY;
    unset ALL_PROXY;
    sudo sed -i -e '/Acquire::http::Proxy/d' /etc/apt/apt.conf.d/proxy.conf;
    sudo sed -i -e '/Acquire::https::Proxy/d' /etc/apt/apt.conf.d/proxy.conf;
    sudo sed -i -e '/Acquire::socks::Proxy/d' /etc/apt/apt.conf.d/proxy.conf;
' 
