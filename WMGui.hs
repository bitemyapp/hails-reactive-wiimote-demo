-- NOTE: This module is work in progress, incomplete and contains errors.
module Main where

import Control.Applicative
import Control.Monad.IfElse
import Data.ReactiveValue
import Graphics.Rendering.Pango as Pango
import Graphics.UI.Gtk
import Graphics.UI.Gtk.Reactive
import Hails.Polling

import Wiimote

main :: IO ()
main = do 
   wm <- initialiseWiimote

   awhen wm $ \wm' -> do
      -- Keera Hails - External RV by polling the Wiimote
      wiimoteRV <- pollingReactive (pollWiimote wm')
                                   (Just 10000) -- Every 10ms

      -- View
      initGUI
      -- Create the builder, and load the UI file
      builder <- builderNew
      builderAddFromFile builder "UI.glade"

      -- Retrieve some objects from the UI
      window        <- builderGetObject builder castToWindow "mainWindow"
      labelA        <- builderGetObject builder castToLabel  "labelA"
      labelB        <- builderGetObject builder castToLabel  "labelB"
      label1        <- builderGetObject builder castToLabel  "label1"
      label2        <- builderGetObject builder castToLabel  "label2"
      labelLeft     <- builderGetObject builder castToLabel  "labelLeft"
      labelRight    <- builderGetObject builder castToLabel  "labelRight"
      labelUp       <- builderGetObject builder castToLabel  "labelUp"
      labelDown     <- builderGetObject builder castToLabel  "labelDown"
      labelHome     <- builderGetObject builder castToLabel  "labelHome"
      labelPlus     <- builderGetObject builder castToLabel  "labelPlus"
      labelMinus    <- builderGetObject builder castToLabel  "labelMinus"
      labelAccVal   <- builderGetObject builder castToLabel  "labelValAcc"
      labelPitchVal <- builderGetObject builder castToLabel  "labelValPitch"
      labelRollVal  <- builderGetObject builder castToLabel  "labelValRoll"


      -- View: show
      widgetShowAll window

      -- Keera Hails - Reactive Controller

      -- Controller: synchronise buttons
      ((buttonColorF.buttonA)     <$> wiimoteRV) =:> labelBackground labelA
      ((buttonColorF.buttonB)     <$> wiimoteRV) =:> labelBackground labelB
      ((buttonColorF.button1)     <$> wiimoteRV) =:> labelBackground label1
      ((buttonColorF.button2)     <$> wiimoteRV) =:> labelBackground label2
      ((buttonColorF.buttonLeft)  <$> wiimoteRV) =:> labelBackground labelLeft
      ((buttonColorF.buttonRight) <$> wiimoteRV) =:> labelBackground labelRight
      ((buttonColorF.buttonUp)    <$> wiimoteRV) =:> labelBackground labelUp
      ((buttonColorF.buttonDown)  <$> wiimoteRV) =:> labelBackground labelDown
      ((buttonColorF.buttonHome)  <$> wiimoteRV) =:> labelBackground labelHome
      ((buttonColorF.buttonPlus)  <$> wiimoteRV) =:> labelBackground labelPlus
      ((buttonColorF.buttonMinus) <$> wiimoteRV) =:> labelBackground labelMinus

      -- Controller: synchronise accelerometre data
      ((show.accValue)            <$> wiimoteRV) =:> labelTextReactive labelAccVal 
      ((show.pitchValue)          <$> wiimoteRV) =:> labelTextReactive labelPitchVal 
      ((show.rollValue)           <$> wiimoteRV) =:> labelTextReactive labelRollVal 
      -- onDestroy window mainQuit

      -- Controller: main loop
      mainGUI

-- Auxiliary functions

-- TODO: This may not be the default color. It's theme dependent.
-- There must be some function to obtain it.
buttonColorF :: Bool -> Pango.Color
buttonColorF s = if s then green else defColor
  where green    = Pango.Color 0 65535 0
        defColor = Pango.Color 61952 61696 61240
