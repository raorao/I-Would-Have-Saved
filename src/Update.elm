module Update exposing (..)

import Model exposing (..)
import Http
import Ynab
import Task
import DatePicker
import Bootstrap.Dropdown as Dropdown


--import Result


type Msg
    = NoOp
    | FetchBudgets AccessToken
    | BudgetsFetched AccessToken (Result Http.Error (List Budget))
    | FetchTransactions AccessToken BudgetId
    | TransactionsFetched (Result Http.Error (List Transaction))
    | SelectBudget Budget
    | CategorySelected CategoryFilter
    | AdjustmentSelected AdjustmentFilter
    | SetDatePicker DatePicker.Msg
    | DropdownMsg Dropdown.State


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        ( Loading _, FetchBudgets token ) ->
            ( Loading LoadingBudgets
            , Http.send (BudgetsFetched token) (Ynab.fetchBudgets token)
            )

        ( Loading _, BudgetsFetched token (Ok []) ) ->
            ( Error ImpossibleState, Cmd.none )

        ( Loading _, BudgetsFetched token (Ok [ budget ]) ) ->
            ( Loading LoadingTransactions
            , send (FetchTransactions token budget.id)
            )

        ( Loading _, BudgetsFetched token (Ok budgets) ) ->
            ( BudgetSelector { budgets = budgets, token = token }, Cmd.none )

        ( Loading _, BudgetsFetched token (Err error) ) ->
            ( Error (ApiDown error), Cmd.none )

        ( Loading _, FetchTransactions token budgetId ) ->
            ( Loading LoadingTransactions
            , Http.send TransactionsFetched (Ynab.fetchTransactions token budgetId)
            )

        ( Loading _, TransactionsFetched (Ok transactions) ) ->
            let
                ( datePicker, datePickerCmd ) =
                    DatePicker.init
                        |> Tuple.mapSecond (Cmd.map SetDatePicker)
            in
                ( TransactionViewer
                    { transactions = transactions
                    , datePicker = datePicker
                    , dropdown = Dropdown.initialState
                    , filters = emptyFilters
                    }
                , datePickerCmd
                )

        ( Loading _, TransactionsFetched (Err error) ) ->
            ( Error (ApiDown error), Cmd.none )

        ( BudgetSelector { token }, SelectBudget budget ) ->
            ( Loading LoadingTransactions
            , send (FetchTransactions token budget.id)
            )

        ( TransactionViewer pageData, CategorySelected categoryFilter ) ->
            let
                filters =
                    pageData.filters

                newFilters =
                    { filters | category = Active categoryFilter }

                newPageData =
                    { pageData | filters = newFilters }
            in
                ( TransactionViewer newPageData, Cmd.none )

        ( TransactionViewer pageData, AdjustmentSelected adjustmentFilter ) ->
            let
                filters =
                    pageData.filters

                newFilters =
                    { filters | adjustment = Active adjustmentFilter }

                newPageData =
                    { pageData | filters = newFilters }
            in
                ( TransactionViewer newPageData, Cmd.none )

        ( TransactionViewer pageData, SetDatePicker msg ) ->
            let
                ( newDatePicker, datePickerCmd, dateEvent ) =
                    DatePicker.update
                        DatePicker.defaultSettings
                        msg
                        pageData.datePicker

                since =
                    case dateEvent of
                        DatePicker.Changed (Just newDate) ->
                            Active (SinceFilter newDate)

                        _ ->
                            Inactive

                filters =
                    pageData.filters

                newFilters =
                    { filters | since = since }

                newPageData =
                    { pageData | filters = newFilters, datePicker = newDatePicker }
            in
                ( TransactionViewer newPageData
                , Cmd.map SetDatePicker datePickerCmd
                )

        ( TransactionViewer pageData, DropdownMsg dropdown ) ->
            let
                newPageData =
                    { pageData | dropdown = dropdown }
            in
                ( TransactionViewer newPageData, Cmd.none )

        ( _, NoOp ) ->
            ( model, Cmd.none )

        _ ->
            ( Error ImpossibleState, Cmd.none )


send : msg -> Cmd msg
send msg =
    Task.succeed msg
        |> Task.perform identity
