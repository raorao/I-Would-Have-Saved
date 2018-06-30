module Update exposing (..)

import Model
import RemoteData
import Http
import Ynab


--import Result


type Msg
    = NoOp
    | FetchBudgets
    | BudgetsFetched (Result Http.Error (List Model.Budget))


update : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        FetchBudgets ->
            case model.token of
                Nothing ->
                    ( model, Cmd.none )

                Just token ->
                    let
                        requestCmd =
                            token
                                |> Ynab.fetchBudgets
                                |> Http.send BudgetsFetched
                    in
                        ( { model | budgets = RemoteData.Loading }, requestCmd )

        BudgetsFetched (Ok a) ->
            ( { model | budgets = RemoteData.Success a, page = Model.BudgetSelector }, Cmd.none )

        BudgetsFetched (Err e) ->
            ( { model | budgets = RemoteData.Failure e }, Cmd.none )
