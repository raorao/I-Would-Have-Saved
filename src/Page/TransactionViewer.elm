module Page.TransactionViewer exposing (..)

import Model
import Html exposing (..)
import Html.Events exposing (onClick)
import Update exposing (Msg)
import TransactionReducer
import Dropdown
import DatePicker
import Round
import Styling
import Bootstrap.Dropdown as BDropdown
import Bootstrap.Button as Button
import Bootstrap.Utilities.Flex as Flex


view : Model.TransactionViewerData -> Html Msg
view { filters, datePicker, transactions, viewState } =
    div []
        [ Styling.title
        , Styling.titleWithText (viewSavings filters transactions)
        , Styling.row [ viewAdjustmentSelector filters viewState.adjustmentDropdown ]
        , Styling.row [ viewCategorySelector transactions ]
        , Styling.row [ viewSinceSelector datePicker filters ]
        ]


viewSavings : Model.Filters -> List Model.Transaction -> String
viewSavings filters transactions =
    transactions
        |> TransactionReducer.savings filters
        |> Round.round 2
        |> (++) "$"


viewAdjustmentSelector : Model.Filters -> BDropdown.State -> Html Msg
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


viewAdjustmentDropdown : Model.Filters -> BDropdown.State -> Html Msg
viewAdjustmentDropdown { adjustment } dropdown =
    let
        adjustmentName =
            case adjustment of
                Model.Active adjustmentFilter ->
                    adjustmentFilterString adjustmentFilter

                Model.Inactive ->
                    "..."
    in
        BDropdown.dropdown
            dropdown
            { options = []
            , toggleMsg = (Update.DropdownMsg Model.AdjustmentDropdown)
            , toggleButton =
                BDropdown.toggle [ Button.primary ] [ text adjustmentName ]
            , items = adjustmentDropdownItems
            }


adjustmentDropdownItems : List (BDropdown.DropdownItem Msg)
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


adjustmentDropdownItem : Model.AdjustmentFilter -> BDropdown.DropdownItem Msg
adjustmentDropdownItem adjustmentFilter =
    BDropdown.buttonItem
        [ onClick (Update.AdjustmentSelected adjustmentFilter) ]
        [ text (adjustmentFilterString adjustmentFilter) ]


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
