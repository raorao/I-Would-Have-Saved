module View exposing (view)

import Html exposing (Html, text)
import Model exposing (Page(..), Model, Config)
import Update exposing (Msg)
import Page.LoggedIn
import Page.LoggedOut
import Page.BudgetSelector


view : Model -> Html Msg
view model =
    case model.page of
        LoggedOut ->
            Page.LoggedOut.view model

        LoggedIn ->
            Page.LoggedIn.view model

        BudgetSelector ->
            Page.BudgetSelector.view model

        Error ->
            text "something went wrong during app initialization."
