module View exposing (view)

import Html exposing (Html, text)
import Model exposing (PageModel(..), Model, Config)
import Update exposing (Msg)
import Page.LoggedIn
import Page.LoggedOut


view : Model -> Html Msg
view model =
    case model.pageModel of
        LoggedOut ->
            Page.LoggedIn.view model

        LoggedIn _ ->
            Page.LoggedOut.view model

        Error ->
            text "something went wrong during app initialization."
