module Ynab exposing (fetchBudgets)

import Json.Decode as Decode
import Http exposing (..)
import Model exposing (Budget)


fetchBudgetsUrl : String -> String
fetchBudgetsUrl token =
    "https://api.youneedabudget.com/v1/budgets?access_token=" ++ token


fetchBudgetsDecoder : Decode.Decoder (List Budget)
fetchBudgetsDecoder =
    budgetDecoder
        |> Decode.list
        |> Decode.field "budgets"
        |> Decode.field "data"


budgetDecoder : Decode.Decoder Budget
budgetDecoder =
    Decode.map2 Budget (Decode.field "id" Decode.string) (Decode.field "name" Decode.string)


fetchBudgets : String -> Request (List Budget)
fetchBudgets token =
    fetchBudgetsDecoder
        |> Http.get (fetchBudgetsUrl token)
