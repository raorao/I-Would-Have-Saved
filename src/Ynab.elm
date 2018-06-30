module Ynab exposing (fetchBudgets)

import Json.Decode as Decode
import Http exposing (..)
import Model exposing (Budget)
import List.Zipper as Zipper exposing (Zipper)


fetchBudgetsUrl : String -> String
fetchBudgetsUrl token =
    "https://api.youneedabudget.com/v1/budgets?access_token=" ++ token


fetchBudgetsDecoder : Decode.Decoder (Zipper Budget)
fetchBudgetsDecoder =
    budgetDecoder
        |> Decode.list
        |> Decode.field "budgets"
        |> Decode.field "data"
        |> Decode.map Zipper.fromList
        |> Decode.andThen ensureAtLeastOne


ensureAtLeastOne : Maybe (Zipper Budget) -> Decode.Decoder (Zipper Budget)
ensureAtLeastOne maybeZipper =
    case maybeZipper of
        Just zipper ->
            Decode.succeed zipper

        Nothing ->
            Decode.fail "must have at least one budget."


budgetDecoder : Decode.Decoder Budget
budgetDecoder =
    Decode.map2 Budget (Decode.field "id" Decode.string) (Decode.field "name" Decode.string)


fetchBudgets : String -> Request (Zipper Budget)
fetchBudgets token =
    fetchBudgetsDecoder
        |> Http.get (fetchBudgetsUrl token)
