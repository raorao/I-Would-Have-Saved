module Page.TransactionViewer exposing (..)

import Model
import Html exposing (..)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Update exposing (Msg)
import TransactionReducer
import DatePicker
import DatePickerSettings
import Styling
import Bootstrap.Dropdown as Dropdown
import Bootstrap.Button as Button
import Bootstrap.Utilities.Flex as Flex
import Bootstrap.Utilities.Spacing as Spacing
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import FormatNumber
import FormatNumber.Locales


view : Model.TransactionViewerData -> Html Msg
view { filters, datePicker, transactions, viewState } =
    div []
        [ Styling.title
        , Styling.titleWithText (viewSavings filters transactions)
        , selectorRow "If I Spent"
            [ viewAdjustmentDropdown filters viewState.adjustmentDropdown ]
        , selectorRow "On"
            [ viewCategoryDropdown transactions filters viewState.categoryDropdown ]
        , selectorRow "At"
            [ viewPayeeDropdown transactions filters viewState.payeeDropdown ]
        , selectorRow "Since" [ viewSinceDatePicker datePicker transactions filters.since ]
        ]


viewSavings : Model.Filters -> List Model.Transaction -> String
viewSavings filters transactions =
    transactions
        |> TransactionReducer.savings filters
        |> FormatNumber.format FormatNumber.Locales.usLocale
        |> (++) "$"


selectorRow : String -> List (Html Msg) -> Html Msg
selectorRow title children =
    Grid.row
        [ Row.centerXs, (Row.attrs [ Flex.alignItemsCenter, Spacing.mb2 ]) ]
        [ Grid.col ([ Col.md5, Col.sm8 ])
            [ div
                [ Flex.block, Flex.justifyEndMd, Flex.justifyCenter, Flex.alignItemsCenter ]
                [ label
                    [ class "lead"
                    , Spacing.mb0
                    ]
                    [ text title ]
                ]
            ]
        , Grid.col ([ Col.md5, Col.sm8 ])
            [ div
                [ Flex.block, Flex.justifyStartMd, Flex.justifyCenter, Flex.alignItemsCenter ]
                children
            ]
        ]


viewAdjustmentDropdown : Model.Filters -> Dropdown.State -> Html Msg
viewAdjustmentDropdown { adjustment } dropdown =
    Dropdown.dropdown
        dropdown
        { options = []
        , toggleMsg = (Update.DropdownMsg Model.AdjustmentDropdown)
        , toggleButton =
            Dropdown.toggle [ Button.primary, Button.large ] [ text (adjustmentFilterString adjustment) ]
        , items = adjustmentDropdownItems
        }


adjustmentDropdownItems : List (Dropdown.DropdownItem Msg)
adjustmentDropdownItems =
    let
        unselectItem =
            adjustmentDropdownItem Model.Inactive

        adjustmentItems =
            [ Model.TenPercent, Model.TwentyFivePercent, Model.HalfAsMuch ]
                |> List.map Model.Active
                |> List.map adjustmentDropdownItem
    in
        [ unselectItem ] ++ [ Dropdown.divider ] ++ adjustmentItems


adjustmentDropdownItem : Model.Filter Model.AdjustmentFilter -> Dropdown.DropdownItem Msg
adjustmentDropdownItem filter =
    Dropdown.buttonItem
        [ onClick (Update.AdjustmentSelected filter) ]
        [ text (adjustmentFilterString filter) ]


adjustmentFilterString : Model.Filter Model.AdjustmentFilter -> String
adjustmentFilterString filter =
    case filter of
        Model.Active Model.TenPercent ->
            "10% less"

        Model.Active Model.TwentyFivePercent ->
            "25% less"

        Model.Active Model.HalfAsMuch ->
            "Half as much"

        Model.Inactive ->
            "Nothing"


viewCategoryDropdown : List Model.Transaction -> Model.Filters -> Dropdown.State -> Html Msg
viewCategoryDropdown transactions filters dropdown =
    let
        categoryName =
            case filters.category of
                Model.Active (Model.CategoryFilter category) ->
                    category

                Model.Inactive ->
                    "All Categories"
    in
        Dropdown.dropdown
            dropdown
            { options = []
            , toggleMsg = (Update.DropdownMsg Model.CategoryDropdown)
            , toggleButton =
                Dropdown.toggle [ Button.primary, Button.large ] [ text categoryName ]
            , items = categoryDropdownItems filters transactions
            }


categoryDropdownItems : Model.Filters -> List Model.Transaction -> List (Dropdown.DropdownItem Msg)
categoryDropdownItems filters transactions =
    let
        unselectItem =
            categoryDropdownItem ( "All Categories", Model.Inactive )

        categoryItems =
            transactions
                |> TransactionReducer.categories filters
                |> List.map (\a -> ( a, a ))
                |> List.map (Tuple.mapSecond Model.CategoryFilter)
                |> List.map (Tuple.mapSecond Model.Active)
                |> List.map categoryDropdownItem
    in
        [ unselectItem ] ++ [ Dropdown.divider ] ++ categoryItems


categoryDropdownItem : ( String, Model.Filter Model.CategoryFilter ) -> Dropdown.DropdownItem Msg
categoryDropdownItem ( name, filter ) =
    Dropdown.buttonItem
        [ onClick (Update.CategorySelected filter) ]
        [ text name ]


viewPayeeDropdown : List Model.Transaction -> Model.Filters -> Dropdown.State -> Html Msg
viewPayeeDropdown transactions filters dropdown =
    let
        payeeName =
            case filters.payee of
                Model.Active (Model.PayeeFilter payee) ->
                    payee

                Model.Inactive ->
                    "All Payees"
    in
        Dropdown.dropdown
            dropdown
            { options = []
            , toggleMsg = (Update.DropdownMsg Model.PayeeDropdown)
            , toggleButton =
                Dropdown.toggle [ Button.primary, Button.large ] [ text payeeName ]
            , items = payeeDropdownItems filters transactions
            }


payeeDropdownItems : Model.Filters -> List Model.Transaction -> List (Dropdown.DropdownItem Msg)
payeeDropdownItems filters transactions =
    let
        unselectItem =
            payeeDropdownItem ( "All Payees", Model.Inactive )

        payeeItems =
            transactions
                |> TransactionReducer.payees filters
                |> List.map (\a -> ( a, a ))
                |> List.map (Tuple.mapSecond Model.PayeeFilter)
                |> List.map (Tuple.mapSecond Model.Active)
                |> List.map payeeDropdownItem
    in
        [ unselectItem ] ++ [ Dropdown.divider ] ++ payeeItems


payeeDropdownItem : ( String, Model.Filter Model.PayeeFilter ) -> Dropdown.DropdownItem Msg
payeeDropdownItem ( name, filter ) =
    Dropdown.buttonItem
        [ onClick (Update.PayeeSelected filter) ]
        [ text name ]


viewSinceDatePicker : DatePicker.DatePicker -> List Model.Transaction -> Model.Filter Model.SinceFilter -> Html Update.Msg
viewSinceDatePicker datePicker transactions currentSince =
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
            (DatePickerSettings.default transactions)
            datePicker
            |> Html.map Update.SetDatePicker
