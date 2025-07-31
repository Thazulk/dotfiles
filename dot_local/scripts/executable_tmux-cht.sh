#!/usr/bin/env zsh

selected=$(cat ~/.tmux-cht-languages ~/.tmux-cht-command | fzf)
if [[ -z $selected ]]; then
    exit 0
fi

# read user input with a prompt in zsh
echo -n "Enter Query: "
read query

if grep -qs "$selected" ~/.tmux-cht-languages; then
    query=$(echo $query | tr ' ' '+')
    tmux neww bash -c "echo \"curl cht.sh/$selected/$query/\" & curl cht.sh/$selected/$query || echo 'Query failed. Please try again.' & while [ : ]; do sleep 1; done"
else
    tmux neww bash -c "curl -s cht.sh/$selected~$query | less || echo 'Query failed. Please try again.'"
fi