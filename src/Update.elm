module Update exposing (..)

import Model
import RemoteData
import Http
import Ynab
import List.Zipper as Zipper exposing (Zipper)
import Task
import DatePicker


--import Result


type Msg
    = NoOp
    | FetchBudgets
    | BudgetsFetched (Result Http.Error (Zipper Model.Budget))
    | FetchTransactions
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

        FetchBudgets ->
            case model.token of
                Nothing ->
                    ( { model | page = Model.Error Model.NoAccessToken }, Cmd.none )

                Just token ->
                    let
                        requestCmd =
                            token
                                |> Ynab.fetchBudgets
                                |> Http.send BudgetsFetched
                    in
                        ( { model
                            | budgets = RemoteData.Loading
                            , page = Model.Loading "Loading Budgets..."
                          }
                        , requestCmd
                        )

        BudgetsFetched (Ok budgets) ->
            let
                ( page, cmd ) =
                    case Zipper.toList budgets of
                        [] ->
                            ( Model.Error Model.ImpossibleState, Cmd.none )

                        [ _ ] ->
                            ( Model.Loading "Loading Transactions..."
                            , send FetchTransactions
                            )

                        _ ->
                            ( Model.BudgetSelector, Cmd.none )
            in
                ( { model
                    | budgets = RemoteData.Success budgets
                    , page = page
                  }
                , cmd
                )

        BudgetsFetched (Err error) ->
            ( { model
                | budgets = RemoteData.Failure error
                , page = Model.Error Model.ApiDown
              }
            , Cmd.none
            )

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
                ( { model
                    | budgets = newBudgets
                    , page = Model.Loading "Loading Transactions..."
                  }
                , send FetchTransactions
                )

        FetchTransactions ->
            case model.token of
                Nothing ->
                    ( { model | page = Model.Error Model.NoAccessToken }
                    , Cmd.none
                    )

                Just token ->
                    let
                        requestCmd =
                            model.budgets
                                |> RemoteData.toMaybe
                                |> Maybe.map Zipper.current
                                |> Maybe.map .id
                                |> Maybe.map (Ynab.fetchTransactions token)
                                |> Maybe.map (Http.send TransactionsFetched)
                                |> Maybe.withDefault Cmd.none
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
                | page = Model.Error Model.ApiDown
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



--let
--    ( newDatePicker, datePickerCmd, dateEvent ) =
--        DatePicker.update DatePicker.defaultSettings msg model.datePicker
--    date =
--        case dateEvent of
--            DatePicker.Changed (Just newDate) ->
--                Just (Model.SinceFilter newDate)
--            _ ->
--                Nothing
--    filters =
--        model.filters
--    newFilters =
--        { filters | since = date }
--in
--    { model
--        | datePicker = newDatePicker
--        , filters = newFilters
--    }
--        ! [ Cmd.map SetDatePicker datePickerCmd ]


send : msg -> Cmd msg
send msg =
    Task.succeed msg
        |> Task.perform identity
