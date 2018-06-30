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
            , viewSavings model.filters transactions
            , viewCategorySelector transactions
            ]


viewSavings : List Model.Filter -> List Model.Transaction -> Html Msg
viewSavings filters transactions =
    transactions
        |> TransactionReducer.savings filters
        |> text
        |> List.singleton
        |> div []


viewCategorySelector : List Model.Transaction -> Html Msg
viewCategorySelector transactions =
    div
        []
        [ label [] [ text "Category" ], viewCategoryDropdown transactions ]


viewCategoryDropdown : List Model.Transaction -> Html Msg
viewCategoryDropdown transactions =
    Dropdown.dropdown
        (Dropdown.Options
            (categoryDropdownItems transactions)
            (Just (Dropdown.Item "Category" "Category" False))
            selectCategory
        )
        []
        (Just "Category ")


categoryDropdownItems : List Model.Transaction -> List Dropdown.Item
categoryDropdownItems transactions =
    transactions
        |> TransactionReducer.categories
        |> List.map categoryDropdownItem


categoryDropdownItem : String -> Dropdown.Item
categoryDropdownItem category =
    Dropdown.Item category category True


selectCategory : Maybe String -> Update.Msg
selectCategory selection =
    case selection of
        Just category ->
            Update.FilterSelected (Model.Category category)

        Nothing ->
            Update.NoOp
