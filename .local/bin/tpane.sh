#!/usr/bin/env bash

P=$(tmux show -wqv @myspecialpane)
if [ -n "$P" ] && tmux lsp -F'#{pane_id}' | grep -q ^$P; then
     tmux killp -t$P
     tmux set -wu @myspecialpane
else
     P=$(tmux splitw -PF'#{pane_id}')
     tmux set -w @myspecialpane "$P"
fi

# References:
# 	[1] https://superuser.com/questions/1456540/toggle-a-pane-in-tmux
