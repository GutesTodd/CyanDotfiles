# Hacknet Hyprland zsh profile.
# Keep secrets, proxies, API keys, and machine-local exports in ~/.zshrc.local.

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
export HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
export HISTSIZE="${HISTSIZE:-10000}"
export SAVEHIST="${SAVEHIST:-10000}"

setopt autocd
setopt extended_history
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt share_history

path=(
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$HOME/go/bin"
  "$HOME/.local/share/pnpm"
  $path
)
typeset -U path
export PATH

export PNPM_HOME="$HOME/.local/share/pnpm"
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

autoload -Uz compinit
compinit

if [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if command -v oh-my-posh >/dev/null 2>&1 && [[ -f "$HOME/.config/ohmyposh/hacknet.toml" ]]; then
  eval "$(oh-my-posh init zsh --config "$HOME/.config/ohmyposh/hacknet.toml")"
else
  PROMPT='%F{green}>_%f '
fi

git() {
  case "$1" in
    rbd)
      shift
      command git pull --rebase origin develop "$@"
      ;;
    ac)
      shift
      command git commit --amend "$@"
      ;;
    clean-local-branches)
      shift
      local protected_branches=(develop master main dev pre-prod pre-dev)
      local current_branch branch branches_to_delete

      if ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "Not inside a git repository"
        return 1
      fi

      command git fetch --prune "$@"

      current_branch="$(command git branch --show-current)"
      branches_to_delete=()

      for branch in "${(@f)$(command git for-each-ref --format='%(refname:short)' refs/heads)}"; do
        if [[ "$branch" == "$current_branch" || ${protected_branches[(Ie)$branch]} -gt 0 ]]; then
          continue
        fi

        branches_to_delete+=("$branch")
      done

      if (( ${#branches_to_delete[@]} == 0 )); then
        echo "No local branches to delete"
        return 0
      fi

      printf 'Local branches to delete:\n'
      printf '  %s\n' "${branches_to_delete[@]}"
      printf 'Delete these branches? [y/N] '
      read -r answer

      if [[ "$answer" != [yY] ]]; then
        echo "Canceled"
        return 0
      fi

      for branch in "${branches_to_delete[@]}"; do
        command git branch -D "$branch"
      done
      ;;
    *)
      command git "$@"
      ;;
  esac
}

for local_zsh_config in "$HOME/.zshrc.local" "$HOME/.zshrc_custom"; do
  if [[ -f "${local_zsh_config}" ]]; then
    source "${local_zsh_config}"
  fi
done

unset local_zsh_config
