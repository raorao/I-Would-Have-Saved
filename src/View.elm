module View exposing (view)

import Html exposing (Html)
import Model exposing (Model(..))
import Update exposing (Msg)
import Page.Loading
import Page.LoggedOut
import Page.BudgetSelector
import Page.TransactionViewer
import Page.ErrorView


view : Model -> Html Msg
view model =
    case model of
        LoggedOut config ->
            Page.LoggedOut.view config

        Loading pageData ->
            Page.Loading.view pageData

        BudgetSelector pageData ->
            Page.BudgetSelector.view pageData

        TransactionViewer pageData ->
            Page.TransactionViewer.view pageData

        Error pageData ->
            Page.ErrorView.view pageData
