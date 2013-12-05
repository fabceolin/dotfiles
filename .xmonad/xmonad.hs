-- default desktop configuration for Fedora

import System.Posix.Env (getEnv)
import Data.Maybe (maybe)

import XMonad
import XMonad.Config.Desktop
import XMonad.Config.Gnome
import XMonad.Config.Kde
import XMonad.Config.Xfce
import XMonad.Layout.Tabbed
import XMonad.Layout.Accordion
import XMonad.Layout.NoBorders
import XMonad.Hooks.EwmhDesktops   -- fullscreenEventHook fixes chrome fullscreen
import XMonad.Hooks.SetWMName


import XMonad.Util.EZConfig

import qualified XMonad.StackSet as W
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders



main = do
     session <- getEnv "DESKTOP_SESSION"
     xmonad  $ maybe desktopConfig desktop session
  

desktop "gnome" = gnomeConfig 
desktop "kde" = kde4Config
desktop "xfce" = xfceConfig
-- Fedora 16
desktop "xmonad-gnome" = gnomeConfig {  modMask = mod4Mask
                                        , borderWidth = 0
                                     }  `additionalKeysP` myKeys

-- Ubuntu 12.10
desktop _ = desktopConfig {  modMask = mod4Mask
                             , borderWidth = 0
--                             , startupHook = ewmhDesktopsStartup >> setWMName "LG3D"
--                             , handleEventHook    = fullscreenEventHook -- Only in darcs xmonad-contrib
                          }  `additionalKeysP` myKeys

myKeys = concat
  [
    -- Use the dmenu shortcut for Synapse
    [ ( "M-p",      spawn "exec synapse"            )
    ]
    , [ ( "M-z",      spawn "exec google-chrome"            )
    ]
    , [ ( "M-a",      spawn "exec toggle-autohide"          )
    ]
    , [ ( "M-d",      spawn "exec nautilus"          )
    ]
    , [ ( "M-[",      spawn "xrandr --output $(xrandr | grep -m 1 ' connected' | awk '{ print $1 }') --brightness .3"        )
    ]
    , [ ( "M-]",      spawn "xrandr --output $(xrandr | grep -m 1 ' connected' | awk '{ print $1 }') --brightness 1"        )
    ]
    , [ ( "M-m",      spawn "xcalib -invert -alter"        )
    ]
    , [ ( "M-r",      spawn "dconf write /org/gnome/desktop/interface/gtk-theme '\"Ambiance\"'"        )
    ]
    , [ ( "M-e",      spawn "dconf write /org/gnome/desktop/interface/gtk-theme '\"Radiance\"'"        )
    ]
    , [ ( "M-s",      spawn "$HOME/bin/screenshot"        )
    ]
    , [ ( "M-f",      spawn "$HOME/bin/killcast"        )
    ]
    , [ ( "M-v",      spawn "$HOME/bin/screencastInternalAudioAndMicrophone"        )
    ]
    , [ ( "M-g",      spawn "$HOME/bin/audiocastInternalAudioAndMicrophone"        )
    ]
    , [ ( "M-/",      spawn "gnome-terminal -e orpie" )
    ]
    , [ ( "M-y",      spawn "xdotool mousemove 840 525" )
    ]
    , [ ( "M-o",      spawn  "killall xmonad-x86_64-linux ; metacity --replace" )
    ]
  ]

-- M-b put the application on fullscreen without gnome-panels

