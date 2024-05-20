alias dpl='docker pull'
alias dph='docker push'
alias dkl='docker kill $(docker ps -a | fzf | awk "{ print $1 }")'
#alias dt='docker images | fzf | awk '{print $1":"$2}'
# Not yet operational

# ---
# References 
#
# [1] https://www.youtube.com/watch?v=IYZDIhfAUM0
