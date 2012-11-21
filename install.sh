#!/bin/bash
cd ~
ln -sf dotfiles/.xmonad .xmonad
ln -sf dotfiles/bin bin
ln -sf dotfiles/.vim .vim
ln -sf dotfiles/.vimrc .vimrc
ln -sf dotfiles/.tmux.conf .tmux.conf
# TODO - Insert ~/bin/ on PATH at .bashrc
cd -
cd ~/.ssh
ln -sf ~/dotfiles/.ssh/config config
cd -
gconftool-2 --load gnome-terminal.gconftool
