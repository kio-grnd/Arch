import XMonad
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Util.Run (spawnPipe, hPutStrLn)
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import XMonad.Util.SpawnOnce
import XMonad.Hooks.ManageHelpers (isDialog)
import XMonad.Hooks.EwmhDesktops (ewmh, setEwmhActivateHook)
import XMonad.Hooks.Focus (activateSwitchWs)
import Control.Monad (liftM2)
import XMonad.Config.Desktop
import XMonad.Layout.Gaps

main = do
    polybarProc <- spawnPipe "bash ~/.config/polybar/launch.sh"
    let ah = activateSwitchWs
    xmonad $ ewmh (setEwmhActivateHook ah $ docks def
        { terminal = "xterm"                   
        , modMask = mod4Mask                   
        , layoutHook = avoidStruts $ myLayout  
        , startupHook = myStartupHook          
        , manageHook = myManageHook            
        , logHook = dynamicLogWithPP polybarPP {  
            ppOutput = hPutStrLn polybarProc,  
            ppTitle = polybarColor "#ffffff" "" . shorten 50  
          }
        , normalBorderColor  = "#2e3440"        
        , focusedBorderColor = "#d8dee9"        
        , borderWidth = 1                       
        } `additionalKeys`
        [ ((mod4Mask, xK_Return), spawn "xterm")  
        , ((mod4Mask, xK_d), spawn "rofi -show run") 
        , ((mod4Mask, xK_c), spawn "google-chrome") 
        , ((0, xK_F12), kill)                     
        , ((controlMask, xK_F12), spawn "bash ~/.local/bin/wallpaper.sh")
        , ((0, xK_F11), spawn "~/.local/bin/set_nvidia_pipeline.sh")
        , ((mod4Mask, xK_q), io (exitSuccess))     
        ])

myStartupHook = do
    spawn "bash ~/.local/bin/wallpaper.sh"
    spawn "bash ~/.config/polybar/launch.sh"

myManageHook = composeAll
    [ className =? "XTerm" --> centerFloat
    , className =? "URxvt" --> centerFloat
    , className =? "Google-chrome" --> doF (W.shift "3")
    , className =? "Geany" --> viewShift "2"
    , className =? "Gimp" --> doF (W.shift "4")
    , className =? "loupe" --> doFloat
    , isDialog --> doFloat
    ]
  where viewShift = doF . liftM2 (.) W.greedyView W.shift

myLayout = gaps [(U, 10), (D, 10), (L, 10), (R, 10)] $ Tall 1 (3/100) (1/2)

centerFloat :: ManageHook
centerFloat = do
    w <- ask
    let rect = W.RationalRect l t w' h'
    doF (W.float w rect)
  where
    w' = 0.5  
    h' = 0.5  
    l = (1 - w') / 2  
    t = (1 - h') / 2  

polybarPP :: PP
polybarPP = def { ppTitle = polybarColor "#ffffff" "" . shorten 50 }

polybarColor :: String -> String -> String -> String
polybarColor color bg = wrap ("<fg=" ++ color ++ ">") ("</fg>")
