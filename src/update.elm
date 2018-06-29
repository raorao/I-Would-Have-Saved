module Update exposing (..)

import Model


type Msg
    = NoOp


update : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )
