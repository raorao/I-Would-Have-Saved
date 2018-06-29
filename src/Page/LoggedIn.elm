module Page.LoggedIn exposing (..)

import Model
import Html exposing (Html, text)
import Update


view : Model.Model -> Html Update.Msg
view model =
    text "you're logged in!"
