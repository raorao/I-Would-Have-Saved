module Update exposing (..)

import Model exposing (..)
import Http
import Ynab
import Task
import DatePicker


--import Result


type Msg
    = NoOp
    | FetchBudgets AccessToken
    | BudgetsFetched AccessToken (Result Http.Error (List Budget))
    | FetchTransactions AccessToken BudgetId
    | TransactionsFetched (Result Http.Error (List Transaction))
    | SelectBudget Budget
    | CategorySelected CategoryFilter
    | AdjustmentSelected Adjustment
    | SetDatePicker DatePicker.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model.page, msg ) of
        ( Loading _, FetchBudgets token ) ->
            ( { model | page = Loading "Loading Budgets..." }
            , Http.send (BudgetsFetched token) (Ynab.fetchBudgets token)
            )

        ( Loading _, BudgetsFetched token (Ok []) ) ->
            ( { model | page = Error ImpossibleState }, Cmd.none )

        ( Loading _, BudgetsFetched token (Ok [ budget ]) ) ->
            ( { model | page = Loading "Loading Transactions..." }
            , send (FetchTransactions token budget.id)
            )

        ( Loading _, BudgetsFetched token (Ok budgets) ) ->
            ( { model | page = (BudgetSelector { budgets = budgets, token = token }) }
            , Cmd.none
            )

        ( Loading _, BudgetsFetched token (Err error) ) ->
            ( { model | page = Error (ApiDown error) }, Cmd.none )

        ( Loading _, FetchTransactions token budgetId ) ->
            ( { model | page = Loading "Loading Transactions..." }
            , Http.send TransactionsFetched (Ynab.fetchTransactions token budgetId)
            )

        ( Loading _, TransactionsFetched (Ok transactions) ) ->
            let
                ( datePicker, datePickerCmd ) =
                    DatePicker.init
                        |> Tuple.mapSecond (Cmd.map SetDatePicker)
            in
                ( { model
                    | page =
                        TransactionViewer
                            { transactions = transactions
                            , datePicker = datePicker
                            , filters = emptyFilters
                            }
                  }
                , datePickerCmd
                )

        ( Loading _, TransactionsFetched (Err error) ) ->
            ( { model | page = Error (ApiDown error) }, Cmd.none )

        ( BudgetSelector pageData, SelectBudget budget ) ->
            ( { model | page = Loading "Loading Transactions..." }
            , send (FetchTransactions pageData.token budget.id)
            )

        ( TransactionViewer pageData, CategorySelected categoryFilter ) ->
            let
                filters =
                    pageData.filters

                newFilters =
                    { filters | category = Just categoryFilter }

                newPageData =
                    { pageData | filters = newFilters }
            in
                ( { model | page = TransactionViewer newPageData }
                , Cmd.none
                )

        ( TransactionViewer pageData, AdjustmentSelected adjustmentFilter ) ->
            let
                filters =
                    pageData.filters

                newFilters =
                    { filters | adjustment = Just adjustmentFilter }

                newPageData =
                    { pageData | filters = newFilters }
            in
                ( { model | page = TransactionViewer newPageData }
                , Cmd.none
                )

        ( TransactionViewer pageData, SetDatePicker msg ) ->
            let
                ( newDatePicker, datePickerCmd, dateEvent ) =
                    DatePicker.update
                        DatePicker.defaultSettings
                        msg
                        pageData.datePicker

                date =
                    case dateEvent of
                        DatePicker.Changed (Just newDate) ->
                            Just (SinceFilter newDate)

                        _ ->
                            Nothing

                filters =
                    pageData.filters

                newFilters =
                    { filters | since = date }

                newPageData =
                    { pageData | filters = newFilters, datePicker = newDatePicker }
            in
                ( { model | page = TransactionViewer newPageData }
                , Cmd.map SetDatePicker datePickerCmd
                )

        _ ->
            ( { model | page = Error ImpossibleState }, Cmd.none )


send : msg -> Cmd msg
send msg =
    Task.succeed msg
        |> Task.perform identity
