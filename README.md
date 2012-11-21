dotfiles
========

Here I archive my home dotfiles

My name is Fabrício Ceolin @fabceolin and I'm sharing my dot files with you.

I used to like the simple things and I believe that maintain everything simple makes my work environment more productive. To archive this objective, I'm putting my dotfiles here, to facilitate the sync my working evironment look and feel with all my machines and you.

I'm using this dotfiles at Fedora 16 and Ubuntu 12.10 and justs works.

My idea is combine the simple xmonad desktop window with command line, psychological tricks and lot of shortcuts to make my environment very productive.

At now, there are configurations for
gnome-terminal
xmonad
vim
and some scripts

# Psychological tricks

It's known that changing context is expensive to us. 
[Reference: Cognitive Switching Penalty](http://book.personalmba.com/cognitive-switching-penalty/)


And the distractions can make us less productive [Reference: Distractions](http://book.personalmba.com/guiding-structure/)

To improve my productivity I minimize the context switch and remove distractions of my work desktop, using the following environment:

# Google-chrome

I'm using google-chrome with [High Contrast Google Chrome Extension](https://chrome.google.com/webstore/detail/high-contrast/djcfdncoelnlbldjfhinnjlhdjlikmph) using a Inverted Grayscale Theme or a full desktop inverted color (see xmonad). 

In this way, images is become not attractive and you concentrate on important things instead color pop-up claiming your attention. 

You can improve a lot you productivity coding, writing, reporting and continue to search on web without restrictions.

# Xmonad

My xmonad is high productivity environment, using tablets main ideas:
* Full screen applications with no borders and no panels [Full Screen Application](https://plus.google.com/u/0/photos/114323121467532890733/albums/5811059931765494817/5811059937287058210?authkey=CLCzjd3_yb_gpQE)
* Open applications with (Mod + P) using synaptics
* 10 desktops slots to put applications [My 10 desktops](https://plus.google.com/u/0/photos/114323121467532890733/albums/5811059931765494817/5811061509498161106?authkey=CLCzjd3_yb_gpQE)
* Change desktop focus (Mod + Number) change application [Changing Desktop Focus](http://youtu.be/ffBECrEUSco)
* Move application desktop with (Mod + Shift + Number) [Changing Applicatinon From Desktop 1 to 2](http://youtu.be/eaNe3Ep55xM)
* Keyboard shortcut to turn on and off gnome panels (Mod + b) [Turning On and Off gnome-panels](http://youtu.be/396oaQWMLZI)
* keyboard shortcut to increase or decrease brightness (Mod + [ and Mod + ]). It's good at night. [Monitor Brightiness](http://youtu.be/xyW7EImELlA)
* Invert colors of desktop to no distract with web navigations and applications (Mod + m) [Full desktop color inversion](http://youtu.be/FRge-e6KR7w)
* Open Nautilus with Mod + d
* Open Google-chrome with Mod + z

# Gnome-terminal

I'm using gnome terminal with byobu terminal window manager. I can manage all console terminals from there with some shortcuts.

The highlights gnome-terminal configuration is
* Open byobu directly
* Support invert colors to using with full desktop invert colors [Gnome-terminal with inverse colors on full desktop inverse colors](http://youtu.be/91OWni8vYIs)
* Support monochrome colors [Gnome-terminal with monochrome](https://plus.google.com/u/0/photos/114323121467532890733/albums/5811059931765494817/5811075451215909778?authkey=CLCzjd3_yb_gpQE)

# Vim

There are a simple vimrc file that convert tab to 4 spaces, taglist plugin, autoident, DiffOrig, that show a diff from original file and you editing a file.

# Scripts

At the moment, there are two script only:
A dconf to put auto-hide gnome panels to on or or off called ~/bin/toggle-autohide
and a gstreamer script to make screencasts at ~/bin/recorddesktop

# Install

To install dotfiles, run
cd dotfiles
./install.sh

***CAUTION*** This script will overwrite of your conf files without warning. I'll improve this scripts soon to check this situation.
