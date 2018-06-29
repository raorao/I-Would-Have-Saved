module Main exposing (..)

import Navigation
import Router
import Model
import Update exposing (Msg(..))
import View


init : Model.Config -> Navigation.Location -> ( Model.Model, Cmd Update.Msg )
init config location =
    let
        pageModel =
            case Router.parseLocation location of
                Just Router.LoggedOut ->
                    Model.LoggedOut

                Just (Router.LoggedIn (Just token)) ->
                    Model.LoggedIn token

                Just (Router.LoggedIn Nothing) ->
                    Model.Error

                Nothing ->
                    Model.Error
    in
        ( { config = config, pageModel = pageModel }, Cmd.none )


main =
    Navigation.programWithFlags (always NoOp)
        { view = View.view
        , init = init
        , update = Update.update
        , subscriptions = always Sub.none
        }
