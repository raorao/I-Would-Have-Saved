module Page.Loading exposing (..)

import Html exposing (..)
import Update


view : String -> Html Update.Msg
view message =
    div []
        [ h2 [] [ text "I Would Have Saved..." ]
        , text message
        ]
