module Page.TransactionViewer exposing (..)

import Model
import Html exposing (..)
import Html.Events exposing (onClick)
import Update exposing (Msg)
import TransactionReducer
import DatePicker
import Round
import Styling
import Bootstrap.Dropdown as Dropdown
import Bootstrap.Button as Button
import Bootstrap.Utilities.Flex as Flex


view : Model.TransactionViewerData -> Html Msg
view { filters, datePicker, transactions, viewState } =
    div []
        [ Styling.title
        , Styling.titleWithText (viewSavings filters transactions)
        , Styling.row [ viewAdjustmentSelector filters viewState.adjustmentDropdown ]
        , Styling.row [ viewCategorySelector transactions filters viewState.categoryDropdown ]
        , Styling.row [ viewSinceSelector datePicker filters ]
        ]


viewSavings : Model.Filters -> List Model.Transaction -> String
viewSavings filters transactions =
    transactions
        |> TransactionReducer.savings filters
        |> Round.round 2
        |> (++) "$"


viewAdjustmentSelector : Model.Filters -> Dropdown.State -> Html Msg
viewAdjustmentSelector filters dropdown =
    div
        [ Flex.block, Flex.justifyCenter, Flex.alignItemsCenter ]
        [ Styling.selectorLabel "If I Spent"
        , viewAdjustmentDropdown filters dropdown
        ]


adjustmentFilterString : Model.AdjustmentFilter -> String
adjustmentFilterString adjustmentFilter =
    case adjustmentFilter of
        Model.TenPercent ->
            "10% less"

        Model.TwentyFivePercent ->
            "25% less"

        Model.HalfAsMuch ->
            "half as much"

        Model.NothingAtAll ->
            "nothing"


viewAdjustmentDropdown : Model.Filters -> Dropdown.State -> Html Msg
viewAdjustmentDropdown { adjustment } dropdown =
    let
        adjustmentName =
            case adjustment of
                Model.Active adjustmentFilter ->
                    adjustmentFilterString adjustmentFilter

                Model.Inactive ->
                    "..."
    in
        Dropdown.dropdown
            dropdown
            { options = []
            , toggleMsg = (Update.DropdownMsg Model.AdjustmentDropdown)
            , toggleButton =
                Dropdown.toggle [ Button.primary ] [ text adjustmentName ]
            , items = adjustmentDropdownItems
            }


adjustmentDropdownItems : List (Dropdown.DropdownItem Msg)
adjustmentDropdownItems =
    let
        options =
            [ Model.TenPercent
            , Model.TwentyFivePercent
            , Model.HalfAsMuch
            , Model.NothingAtAll
            ]
    in
        List.map adjustmentDropdownItem options


adjustmentDropdownItem : Model.AdjustmentFilter -> Dropdown.DropdownItem Msg
adjustmentDropdownItem adjustmentFilter =
    Dropdown.buttonItem
        [ onClick (Update.AdjustmentSelected adjustmentFilter) ]
        [ text (adjustmentFilterString adjustmentFilter) ]


viewCategorySelector : List Model.Transaction -> Model.Filters -> Dropdown.State -> Html Msg
viewCategorySelector transactions filters dropdown =
    div
        [ Flex.block, Flex.justifyCenter, Flex.alignItemsCenter ]
        [ Styling.selectorLabel "On", viewCategoryDropdown transactions filters dropdown ]


viewCategoryDropdown : List Model.Transaction -> Model.Filters -> Dropdown.State -> Html Msg
viewCategoryDropdown transactions { category } dropdown =
    let
        categoryName =
            case category of
                Model.Active (Model.CategoryFilter category) ->
                    category

                Model.Inactive ->
                    "..."
    in
        Dropdown.dropdown
            dropdown
            { options = []
            , toggleMsg = (Update.DropdownMsg Model.CategoryDropdown)
            , toggleButton =
                Dropdown.toggle [ Button.primary ] [ text categoryName ]
            , items = categoryDropdownItems transactions
            }


categoryDropdownItems : List Model.Transaction -> List (Dropdown.DropdownItem Msg)
categoryDropdownItems transactions =
    transactions
        |> TransactionReducer.categories
        |> List.map categoryDropdownItem


categoryDropdownItem : String -> Dropdown.DropdownItem Msg
categoryDropdownItem category =
    Dropdown.buttonItem
        [ onClick (Update.CategorySelected (Model.CategoryFilter category)) ]
        [ text category ]


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
