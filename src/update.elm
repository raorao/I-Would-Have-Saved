module Update exposing (..)

import Model
import Http exposing (..)
import Json.Decode exposing (list, string)
import RemoteData


--import Result


type Msg
    = NoOp
    | FetchTransactions
    | TransactionsFetched (Result Error (List String))


update : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        FetchTransactions ->
            case model.token of
                Nothing ->
                    ( model, Cmd.none )

                Just token ->
                    let
                        request =
                            (Http.get ("https://api.youneedabudget.com/v1/budgets?access_token=" ++ token) (list string))
                    in
                        ( { model | transactions = RemoteData.Loading }, request |> Http.send TransactionsFetched )

        TransactionsFetched (Ok a) ->
            ( { model | transactions = RemoteData.Success a }, Cmd.none )

        TransactionsFetched (Err e) ->
            ( { model | transactions = RemoteData.Failure e }, Cmd.none )
