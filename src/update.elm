module Update exposing (..)

import Model
import RemoteData
import Http
import Ynab
import List.Zipper as Zipper exposing (Zipper)


--import Result


type Msg
    = NoOp
    | FetchBudgets
    | BudgetsFetched (Result Http.Error (Zipper Model.Budget))
    | SelectBudget Model.Budget


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

        SelectBudget budget ->
            let
                newBudgets =
                    case model.budgets of
                        RemoteData.Success budgets ->
                            budgets
                                |> Zipper.first
                                |> Zipper.find (\b -> b.name == budget.name)
                                |> Maybe.withDefault budgets
                                |> RemoteData.Success

                        _ ->
                            model.budgets
            in
                ( { model | budgets = newBudgets }, Cmd.none )
