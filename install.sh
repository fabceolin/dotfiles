#!/bin/bash
cd ~
ln -sf etc/.xmonad .xmonad
ln -sf etc/bin bin
ln -sf etc/.vim .vim
# inserir o bin no path pelo .bashrc
cd -
gconftool-2 --load gnome-terminal.gconftool
