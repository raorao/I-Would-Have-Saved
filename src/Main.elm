module Main exposing (..)

import Navigation
import Router
import Model
import Update exposing (Msg(..))
import View
import Bootstrap.Dropdown as Dropdown


init : Model.Config -> Navigation.Location -> ( Model.Model, Cmd Update.Msg )
init config location =
    case Router.parseLocation location of
        ( Just Router.LoggedOut, _ ) ->
            ( Model.LoggedOut config, Cmd.none )

        ( Just Router.PrivacyPolicy, _ ) ->
            ( Model.PrivacyPolicy, Cmd.none )

        ( Just Router.LoggedIn, Just token ) ->
            ( Model.Loading Model.LoadingBudgets, (Update.send (FetchBudgets token)) )

        ( Just Router.LoggedIn, Nothing ) ->
            ( Model.Error Model.NoAccessToken, Cmd.none )

        ( Nothing, _ ) ->
            ( Model.Error Model.InvalidRoute, Cmd.none )


main =
    Navigation.programWithFlags (always NoOp)
        { view = View.view
        , init = init
        , update = Update.update
        , subscriptions = subscriptions
        }


subscriptions : Model.Model -> Sub Update.Msg
subscriptions model =
    case model of
        Model.TransactionViewer { viewState } ->
            Sub.batch
                [ Dropdown.subscriptions
                    viewState.adjustmentDropdown
                    (Update.DropdownMsg Model.AdjustmentDropdown)
                , Dropdown.subscriptions
                    viewState.categoryDropdown
                    (Update.DropdownMsg Model.CategoryDropdown)
                , Dropdown.subscriptions
                    viewState.payeeDropdown
                    (Update.DropdownMsg Model.PayeeDropdown)
                ]

        _ ->
            Sub.none
