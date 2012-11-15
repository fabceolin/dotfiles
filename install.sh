#!/bin/bash
cd ~
ln -sf dotfiles/.xmonad .xmonad
ln -sf dotfiles/bin bin
ln -sf dotfiles/.vim .vim
ln -sf dotfiles/.vimrc .vimrc
# TODO - Insert ~/bin/ on PATH at .bashrc
cd -
gconftool-2 --load gnome-terminal.gconftool
