module View exposing (view)

import Html exposing (Html, text)
import Model exposing (Page(..), Model, Config)
import Update exposing (Msg)
import Page.Loading
import Page.LoggedOut
import Page.BudgetSelector


view : Model -> Html Msg
view model =
    case model.page of
        LoggedOut ->
            Page.LoggedOut.view model

        Loading ->
            Page.Loading.view model

        BudgetSelector ->
            Page.BudgetSelector.view model

        Error ->
            text "something went wrong during app initialization."
