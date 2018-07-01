module Page.BudgetSelector exposing (view)

import Model
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Update


view : Model.BudgetSelectorData -> Html Update.Msg
view { budgets } =
    div []
        [ h2 [] [ text "Select Your Budget" ]
        , fieldset [] (viewRadioButtons budgets)
        ]


viewRadioButtons : List Model.Budget -> List (Html Update.Msg)
viewRadioButtons budgets =
    budgets
        |> List.sortBy .name
        |> List.map viewBudgetOption


viewBudgetOption : Model.Budget -> Html Update.Msg
viewBudgetOption budget =
    label []
        [ input
            [ type_ "radio"
            , name "radio-button"
            , onClick (Update.SelectBudget budget)
            ]
            []
        , text budget.name
        ]
