# General, cross-machine aliases. Managed by chezmoi.
#
# Machine-specific aliases (aws-login-*, vault-*, etc.) do NOT go here.
# Put those in ~/.config/zsh/local.zsh (untracked).

# git
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'

# safety
alias rm='rm -i'

# chezmoi
alias cm='chezmoi'
alias cma='chezmoi apply'
alias cme='chezmoi edit'
