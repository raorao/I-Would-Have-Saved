module Page.TransactionViewer exposing (..)

import Model
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Update exposing (Msg)
import TransactionReducer
import DatePicker
import Round
import Styling
import Bootstrap.Dropdown as Dropdown
import Bootstrap.Button as Button
import Bootstrap.Utilities.Flex as Flex
import Bootstrap.Utilities.Spacing as Spacing


view : Model.TransactionViewerData -> Html Msg
view { filters, datePicker, transactions, viewState } =
    div []
        [ Styling.title
        , Styling.titleWithText (viewSavings filters transactions)
        , selectorRow "If I Spent"
            [ viewAdjustmentDropdown filters viewState.adjustmentDropdown ]
        , selectorRow "On"
            [ viewCategoryDropdown transactions filters viewState.categoryDropdown ]
        , selectorRow "Since" [ viewSinceDatePicker datePicker filters.since ]
        ]


viewSavings : Model.Filters -> List Model.Transaction -> String
viewSavings filters transactions =
    transactions
        |> TransactionReducer.savings filters
        |> Round.round 2
        |> (++) "$"


selectorRow : String -> List (Html Msg) -> Html Msg
selectorRow title children =
    Styling.row
        [ div
            [ Flex.block, Flex.justifyCenter, Flex.alignItemsCenter, Spacing.my1 ]
            ([ label
                [ class "lead"
                , Spacing.mr2
                , Spacing.mb0
                ]
                [ text title ]
             ]
                ++ children
            )
        ]


selectorLabel : String -> Html Msg
selectorLabel str =
    label
        [ class "lead"
        , Spacing.mr2
        , Spacing.mb0
        ]
        [ text str ]


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
                Dropdown.toggle [ Button.primary, Button.large ] [ text adjustmentName ]
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
                Dropdown.toggle [ Button.primary, Button.large ] [ text categoryName ]
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
            Model.datePickerSettings
            datePicker
            |> Html.map Update.SetDatePicker
