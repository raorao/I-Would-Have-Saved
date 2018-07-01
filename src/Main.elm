module Main exposing (..)

import Navigation
import Router
import Model
import Update exposing (Msg(..))
import View
import Task


init : Model.Config -> Navigation.Location -> ( Model.Model, Cmd Update.Msg )
init config location =
    let
        ( page, cmd ) =
            case ( (Router.parseLocation location), (Router.parseAccessToken location) ) of
                ( Just Router.LoggedOut, _ ) ->
                    ( Model.LoggedOut, Cmd.none )

                ( Just Router.LoggedIn, Just token ) ->
                    ( Model.Loading "Loading Budgets..."
                    , (send (FetchBudgets token))
                    )

                ( Just Router.LoggedIn, Nothing ) ->
                    ( Model.Error Model.NoAccessToken, Cmd.none )

                ( Nothing, _ ) ->
                    ( Model.Error Model.InvalidRoute, Cmd.none )
    in
        ( { config = config, page = page }, cmd )


main =
    Navigation.programWithFlags (always NoOp)
        { view = View.view
        , init = init
        , update = Update.update
        , subscriptions = always Sub.none
        }


send : msg -> Cmd msg
send msg =
    Task.succeed msg
        |> Task.perform identity
