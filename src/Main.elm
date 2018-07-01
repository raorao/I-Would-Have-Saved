module Main exposing (..)

import Navigation
import Router
import Model
import Update exposing (Msg(..))
import View
import Task


init : Model.Config -> Navigation.Location -> ( Model.Model, Cmd Update.Msg )
init config location =
    case Router.parseLocation location of
        ( Just Router.LoggedOut, _ ) ->
            ( Model.LoggedOut config, Cmd.none )

        ( Just Router.LoggedIn, Just token ) ->
            ( Model.Loading "Loading Budgets...", (Update.send (FetchBudgets token)) )

        ( Just Router.LoggedIn, Nothing ) ->
            ( Model.Error Model.NoAccessToken, Cmd.none )

        ( Nothing, _ ) ->
            ( Model.Error Model.InvalidRoute, Cmd.none )


main =
    Navigation.programWithFlags (always NoOp)
        { view = View.view
        , init = init
        , update = Update.update
        , subscriptions = always Sub.none
        }
