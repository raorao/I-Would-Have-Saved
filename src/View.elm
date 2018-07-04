module View exposing (view)

import Html exposing (Html)
import Html.Attributes
import Model exposing (Model(..))
import Update exposing (Msg)
import Page.Loading
import Page.LoggedOut
import Page.BudgetSelector
import Page.TransactionViewer
import Page.ErrorView
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Utilities.Spacing as Spacing


view : Model -> Html Msg
view model =
    Grid.containerFluid [ Spacing.mt4, Html.Attributes.style [ ( "padding", "0" ) ] ]
        [ pageView model
        ]


pageView : Model -> Html Msg
pageView model =
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
