module Update exposing (..)

import Model
import Http
import Ynab
import Task
import DatePicker


--import Result


type Msg
    = NoOp
    | FetchBudgets Model.AccessToken
    | BudgetsFetched Model.AccessToken (Result Http.Error (List Model.Budget))
    | FetchTransactions Model.AccessToken Model.BudgetId
    | TransactionsFetched (Result Http.Error (List Model.Transaction))
    | SelectBudget Model.Budget
    | CategorySelected Model.CategoryFilter
    | AdjustmentSelected Model.Adjustment
    | SetDatePicker DatePicker.Msg


update : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        FetchBudgets token ->
            let
                requestCmd =
                    token
                        |> Ynab.fetchBudgets
                        |> Http.send (BudgetsFetched token)
            in
                ( { model
                    | page = Model.Loading "Loading Budgets..."
                  }
                , requestCmd
                )

        BudgetsFetched token (Ok budgets) ->
            let
                ( page, cmd ) =
                    case budgets of
                        [] ->
                            ( Model.Error Model.ImpossibleState, Cmd.none )

                        [ budget ] ->
                            ( Model.Loading "Loading Transactions..."
                            , send (FetchTransactions token budget.id)
                            )

                        _ ->
                            ( Model.BudgetSelector
                                { budgets = budgets
                                , token = token
                                }
                            , Cmd.none
                            )
            in
                ( { model | page = page }, cmd )

        BudgetsFetched token (Err error) ->
            ( { model | page = Model.Error (Model.ApiDown error) }
            , Cmd.none
            )

        SelectBudget budget ->
            case model.page of
                Model.BudgetSelector { token } ->
                    ( { model | page = Model.Loading "Loading Transactions..." }
                    , send (FetchTransactions token budget.id)
                    )

                _ ->
                    ( { model | page = Model.Error Model.ImpossibleState }, Cmd.none )

        FetchTransactions token budgetId ->
            let
                requestCmd =
                    Ynab.fetchTransactions token budgetId
                        |> Http.send TransactionsFetched
            in
                ( { model
                    | page = Model.Loading "Loading Transactions..."
                  }
                , requestCmd
                )

        TransactionsFetched (Ok transactions) ->
            let
                ( datePicker, datePickerCmd ) =
                    DatePicker.init
                        |> Tuple.mapSecond (Cmd.map SetDatePicker)
            in
                ( { model
                    | page =
                        Model.TransactionViewer
                            { transactions = transactions
                            , datePicker = datePicker
                            , filters = Model.emptyFilters
                            }
                  }
                , datePickerCmd
                )

        TransactionsFetched (Err error) ->
            ( { model
                | page = Model.Error (Model.ApiDown error)
              }
            , Cmd.none
            )

        CategorySelected categoryFilter ->
            case model.page of
                Model.TransactionViewer pageData ->
                    let
                        filters =
                            pageData.filters

                        newFilters =
                            { filters | category = Just categoryFilter }

                        newPageData =
                            { pageData | filters = newFilters }
                    in
                        ( { model | page = Model.TransactionViewer newPageData }
                        , Cmd.none
                        )

                _ ->
                    ( { model | page = Model.Error Model.ImpossibleState }, Cmd.none )

        AdjustmentSelected adjustmentFilter ->
            case model.page of
                Model.TransactionViewer pageData ->
                    let
                        filters =
                            pageData.filters

                        newFilters =
                            { filters | adjustment = Just adjustmentFilter }

                        newPageData =
                            { pageData | filters = newFilters }
                    in
                        ( { model | page = Model.TransactionViewer newPageData }
                        , Cmd.none
                        )

                _ ->
                    ( { model | page = Model.Error Model.ImpossibleState }, Cmd.none )

        SetDatePicker msg ->
            case model.page of
                Model.TransactionViewer pageData ->
                    let
                        ( newDatePicker, datePickerCmd, dateEvent ) =
                            DatePicker.update
                                DatePicker.defaultSettings
                                msg
                                pageData.datePicker

                        date =
                            case dateEvent of
                                DatePicker.Changed (Just newDate) ->
                                    Just (Model.SinceFilter newDate)

                                _ ->
                                    Nothing

                        filters =
                            pageData.filters

                        newFilters =
                            { filters | since = date }

                        newPageData =
                            { pageData | filters = newFilters }
                    in
                        ({ model | page = Model.TransactionViewer newPageData }
                            ! [ Cmd.map SetDatePicker datePickerCmd ]
                        )

                _ ->
                    ( { model | page = Model.Error Model.ImpossibleState }, Cmd.none )


send : msg -> Cmd msg
send msg =
    Task.succeed msg
        |> Task.perform identity
