import XMonad
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Util.Run (spawnPipe, hPutStrLn)
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import System.Exit (exitSuccess)
import XMonad.Util.SpawnOnce
import XMonad.Hooks.ManageHelpers (isDialog)

main = do
    xmproc <- spawnPipe "xmobar ~/.xmobarrc"  -- Inicia xmobar y crea un pipe
    xmonad $ docks def
        { terminal = "xterm"                   -- Terminal por defecto
        , modMask = mod4Mask                   -- Usa la tecla de Windows como Mod
        , layoutHook = avoidStruts $ layoutHook def  -- Evita que la barra cubra las ventanas
        , startupHook = myStartupHook          -- Inicializa xmobar
        , manageHook = myManageHook            -- Añade las reglas de gestión de ventanas
        , logHook = dynamicLogWithPP xmobarPP {  -- Configura xmobar para recibir logs de XMonad
            ppOutput = hPutStrLn xmproc,       -- Enviar la salida de XMonad a xmobar
            ppTitle = xmobarColor "#ffffff" "" . shorten 50  -- Personaliza la apariencia del título
          }
        , normalBorderColor  = "#000"        -- Color de las ventanas inactivas
        , focusedBorderColor = "#ccc"        -- Color de las ventanas activas (azul)
        , borderWidth = 1                       -- Ancho del borde
        } additionalKeys
        [ ((mod4Mask, xK_Return), spawn "xterm")  -- Abre el terminal
        , ((mod4Mask, xK_d), spawn "rofi -show run") -- Abre Rofi
        , ((0, xK_F12), kill)                     -- Cierra la ventana activa al presionar F12
        , ((mod4Mask, xK_q), io (exitSuccess))     -- Cierra xmonad
        ]

myStartupHook = do
    spawn "bash ~/.local/bin/change_wallpaper.sh"  -- Cambia el wallpaper

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

myManageHook = composeAll
    [ className =? "XTerm" --> centerFloat  -- Centrar xterm
    , className =? "URxvt" --> centerFloat  -- Centrar urxvt
    , isDialog --> doFloat                   -- Cualquier diálogo también será flotante
    ]
