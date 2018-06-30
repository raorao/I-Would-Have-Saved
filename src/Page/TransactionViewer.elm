module Page.TransactionViewer exposing (..)

import Model
import Html exposing (..)
import Update exposing (Msg)
import RemoteData exposing (RemoteData)
import TransactionReducer
import Dropdown


view : Model.Model -> Html Msg
view model =
    let
        transactions =
            model.transactions
                |> RemoteData.withDefault []
    in
        div []
            [ h2 [] [ text "I Would Have Saved..." ]
            , viewSavings model transactions
            , viewAdjustmentSelector
            , viewCategorySelector transactions
            ]


viewSavings : Model.Model -> List Model.Transaction -> Html Msg
viewSavings { filters, adjustment } transactions =
    transactions
        |> TransactionReducer.savings filters adjustment
        |> text
        |> List.singleton
        |> div []


viewAdjustmentSelector : Html Msg
viewAdjustmentSelector =
    div
        []
        [ label [] [ text "If I Spent " ], viewAdjustmentDropdown ]


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
            Update.AdjustmentSelected (Model.Adjustment 0.1)

        Just "25% less" ->
            Update.AdjustmentSelected (Model.Adjustment 0.25)

        Just "half as much" ->
            Update.AdjustmentSelected (Model.Adjustment 0.5)

        Just "nothing" ->
            Update.AdjustmentSelected (Model.Adjustment 1.0)

        _ ->
            Update.NoOp


viewCategorySelector : List Model.Transaction -> Html Msg
viewCategorySelector transactions =
    div
        []
        [ label [] [ text "On " ], viewCategoryDropdown transactions ]


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
            Update.FilterSelected (Model.Category category)

        Nothing ->
            Update.NoOp
