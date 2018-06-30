module Page.BudgetSelector exposing (..)

import Model
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Update
import RemoteData
import List.Zipper as Zipper


view : Model.Model -> Html Update.Msg
view model =
    case model.budgets of
        RemoteData.Success budgets ->
            div []
                [ h2 [] [ text "Select Your Budget" ]
                , fieldset [] (viewRadioButtons budgets)
                ]

        _ ->
            text "uh oh"



-- PRIVATE --


type Status
    = Selected
    | NotSelected


type alias BudgetOption =
    { status : Status
    , budget : Model.Budget
    }


viewRadioButtons : Zipper.Zipper Model.Budget -> List (Html Update.Msg)
viewRadioButtons budgets =
    budgets
        |> toBudgetOptions
        |> List.filter (\b -> b.budget.name /= "default")
        |> List.sortBy (.budget >> .name)
        |> List.map viewBudgetOption


toBudgetOptions : Zipper.Zipper Model.Budget -> List BudgetOption
toBudgetOptions budgets =
    let
        current =
            BudgetOption Selected (Zipper.current budgets)

        after =
            (Zipper.after budgets) |> List.map (BudgetOption NotSelected)

        before =
            (Zipper.before budgets) |> List.map (BudgetOption NotSelected)
    in
        before ++ [ current ] ++ after


isSelected : Status -> Bool
isSelected status =
    case status of
        Selected ->
            True

        NotSelected ->
            False


viewBudgetOption : BudgetOption -> Html Update.Msg
viewBudgetOption { status, budget } =
    label []
        [ input
            [ type_ "radio"
            , checked (isSelected status)
            , name "radio-button"
            , onClick (Update.SelectBudget budget)
            ]
            []
        , text budget.name
        ]
