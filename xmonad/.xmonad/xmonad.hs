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

main = do
    polybarProc <- spawnPipe "bash ~/.config/polybar/launch.sh"  -- Inicia Polybar con el script
    let ah = activateSwitchWs  -- Configurar el comportamiento de activación de ventanas
    xmonad $ ewmh (setEwmhActivateHook ah $ docks def
        { terminal = "xterm"                   -- Terminal por defecto
        , modMask = mod4Mask                   -- Usa la tecla de Windows como Mod
        , layoutHook = avoidStruts $ layoutHook def  -- Evita que la barra cubra las ventanas
        , startupHook = myStartupHook          -- Inicializa Polybar y wallpaper
        , manageHook = myManageHook            -- Añade las reglas de gestión de ventanas
        , logHook = dynamicLogWithPP polybarPP {  -- Configura Polybar para recibir logs de XMonad
            ppOutput = hPutStrLn polybarProc,  -- Enviar la salida de XMonad a Polybar
            ppTitle = polybarColor "#ffffff" "" . shorten 50  -- Personaliza el título
          }
        , normalBorderColor  = "#2e3440"        -- Color de las ventanas inactivas
        , focusedBorderColor = "#d8dee9"        -- Color de las ventanas activas
        , borderWidth = 1                       -- Ancho del borde
        } `additionalKeys`
        [ ((mod4Mask, xK_Return), spawn "xterm")  -- Abre el terminal
        , ((mod4Mask, xK_d), spawn "rofi -show run") -- Abre Rofi
        , ((mod4Mask, xK_c), spawn "google-chrome") -- Abre Google Chrome
        , ((0, xK_F12), kill)                     -- Cierra la ventana activa al presionar F12
        , ((controlMask, xK_F12), spawn "bash ~/.local/bin/wallpaper.sh") -- Cambia el wallpaper
        , ((mod4Mask, xK_q), io (exitSuccess))     -- Cierra xmonad
        ])

-- Hook para iniciar aplicaciones al iniciar XMonad
myStartupHook = do
    spawn "bash ~/.local/bin/wallpaper.sh"  -- Cambia el wallpaper al iniciar XMonad
    spawn "bash ~/.config/polybar/launch.sh" -- Inicia Polybar usando el script

-- Reglas para gestionar ventanas
myManageHook = composeAll
    [ className =? "XTerm" --> centerFloat
    , className =? "URxvt" --> centerFloat
    , className =? "Google-chrome" --> doF (W.shift "3")
    , className =? "Geany" --> viewShift "2"
    , className =? "Gimp" --> doF (W.shift "4")
    , className =? "loupe" --> doFloat  -- Haz que 'loupe' sea flotante
    , isDialog --> doFloat
    ]

  where viewShift = doF . liftM2 (.) W.greedyView W.shift


-- Función para centrar ventanas flotantes
centerFloat :: ManageHook
centerFloat = do
    w <- ask  -- Obtiene la ventana actual
    let rect = W.RationalRect l t w' h'  -- Crea el rectángulo con el tamaño y posición deseados
    doF (W.float w rect)  -- Aplica W.float a la ventana
  where
    w' = 0.5  -- Ancho de la ventana (50% de la pantalla)
    h' = 0.5  -- Altura de la ventana (50% de la pantalla)
    l = (1 - w') / 2  -- Posición horizontal para centrar
    t = (1 - h') / 2  -- Posición vertical para centrar

-- Define la configuración de Polybar
polybarPP :: PP
polybarPP = def { ppTitle = polybarColor "#ffffff" "" . shorten 50 }

-- Función para cambiar el color del título en Polybar
polybarColor :: String -> String -> String -> String
polybarColor color bg = wrap ("<fg=" ++ color ++ ">") ("</fg>")
