# ---
# Base Dockerfile image used to test ansible in Linux
# ---

FROM --platform=linux/amd64 ubuntu:latest

ENV USER=user
ENV HOME=/home/user
ENV SHELL=/bin/bash
ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p $HOME
WORKDIR $HOME

RUN apt-get update && apt-get install -y ansible bash git npm sudo

RUN mkdir -p $HOME/dotfiles && \
    git clone https://github.com/hsteinshiromoto/dotfiles.linux.git $HOME/dotfiles

ENV PATH="$HOME/.cargo/bin:${PATH}"
ENV PATH="$PATH:/opt/nvim-linux64/bin"

RUN ansible-playbook $HOME/dotfiles/packages.yml
RUN ansible-playbook $HOME/dotfiles/dotfiles.yml

CMD source $HOME/.zshrc

