# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
  PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
  for rc in ~/.bashrc.d/*; do
    if [ -f "$rc" ]; then
      . "$rc"
    fi
  done
fi
unset rc

fastfetch
eval "$(fzf --bash)"
export FZF_COMPLETION_TRIGGER=''
export PATH=$HOME/.npm-global/bin:$PATH
export VCPKG_ROOT=~/vcpkg
export VCPKG_ROOT=~/vcpkg
export PATH=$PATH:$HOME/go/bin
export PATH="$HOME/.cargo/bin:$PATH"

# Added by Antigravity CLI installer
export PATH="/home/bonpepe/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

# opencode
export PATH=/home/bonpepe/.opencode/bin:$PATH
eval "$(zoxide init bash)"
