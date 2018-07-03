module Page.TransactionViewer exposing (..)

import Model
import Html exposing (..)
import Update exposing (Msg)
import TransactionReducer
import Dropdown
import DatePicker
import Round
import Styling
import Bootstrap.Utilities.Spacing as Spacing


view : Model.TransactionViewerData -> Html Msg
view { filters, datePicker, transactions } =
    div []
        [ Styling.title
        , Styling.titleWithText (viewSavings filters transactions)
        , Styling.row [ viewAdjustmentSelector ]
        , Styling.row [ viewCategorySelector transactions ]
        , Styling.row [ viewSinceSelector datePicker filters ]
        ]


viewSavings : Model.Filters -> List Model.Transaction -> String
viewSavings filters transactions =
    transactions
        |> TransactionReducer.savings filters
        |> Round.round 2
        |> (++) "$"


viewAdjustmentSelector : Html Msg
viewAdjustmentSelector =
    div
        []
        [ Styling.selectorLabel "If I Spent"
        , viewAdjustmentDropdown
        ]


viewAdjustmentDropdown : Html Msg
viewAdjustmentDropdown =
    Dropdown.dropdown
        (Dropdown.Options
            adjustmentDropdownItems
            (Just (Dropdown.Item "Adjustment" "Adjustment" False))
            selectAdjustment
        )
        []
        (Just "Adjustment")


adjustmentDropdownItems : List Dropdown.Item
adjustmentDropdownItems =
    let
        options =
            [ "10% less", "25% less", "half as much", "nothing" ]
    in
        List.map enabledDropdownItem options


selectAdjustment : Maybe String -> Update.Msg
selectAdjustment selection =
    case selection of
        Just "10% less" ->
            Update.AdjustmentSelected (Model.AdjustmentFilter 0.1)

        Just "25% less" ->
            Update.AdjustmentSelected (Model.AdjustmentFilter 0.25)

        Just "half as much" ->
            Update.AdjustmentSelected (Model.AdjustmentFilter 0.5)

        Just "nothing" ->
            Update.AdjustmentSelected (Model.AdjustmentFilter 1.0)

        _ ->
            Update.NoOp


viewCategorySelector : List Model.Transaction -> Html Msg
viewCategorySelector transactions =
    div
        []
        [ Styling.selectorLabel "On", viewCategoryDropdown transactions ]


viewCategoryDropdown : List Model.Transaction -> Html Msg
viewCategoryDropdown transactions =
    Dropdown.dropdown
        (Dropdown.Options
            (categoryDropdownItems transactions)
            (Just (Dropdown.Item "Category" "Category" False))
            selectCategory
        )
        []
        (Just "Category")


categoryDropdownItems : List Model.Transaction -> List Dropdown.Item
categoryDropdownItems transactions =
    transactions
        |> TransactionReducer.categories
        |> List.map enabledDropdownItem


enabledDropdownItem : String -> Dropdown.Item
enabledDropdownItem str =
    Dropdown.Item str str True


selectCategory : Maybe String -> Update.Msg
selectCategory selection =
    case selection of
        Just category ->
            Update.CategorySelected (Model.CategoryFilter category)

        Nothing ->
            Update.NoOp


viewSinceSelector : DatePicker.DatePicker -> Model.Filters -> Html Update.Msg
viewSinceSelector datePicker filters =
    div []
        [ Styling.selectorLabel "Since"
        , viewSinceDatePicker datePicker filters.since
        ]


viewSinceDatePicker : DatePicker.DatePicker -> Model.Filter Model.SinceFilter -> Html Update.Msg
viewSinceDatePicker datePicker currentSince =
    let
        selected =
            case currentSince of
                Model.Active (Model.SinceFilter date) ->
                    Just date

                Model.Inactive ->
                    Nothing
    in
        DatePicker.view
            selected
            DatePicker.defaultSettings
            datePicker
            |> Html.map Update.SetDatePicker
