module View exposing (view)

import Html exposing (Html)
import Model exposing (Page(..), Model)
import Update exposing (Msg)
import Page.Loading
import Page.LoggedOut
import Page.BudgetSelector
import Page.TransactionViewer
import Page.ErrorView


view : Model -> Html Msg
view model =
    case model.page of
        LoggedOut ->
            Page.LoggedOut.view model

        Loading message ->
            Page.Loading.view message

        BudgetSelector ->
            Page.BudgetSelector.view model

        TransactionViewer ->
            Page.TransactionViewer.view model

        Error errorType ->
            Page.ErrorView.view errorType
