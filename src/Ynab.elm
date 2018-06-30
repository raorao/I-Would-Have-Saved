module Ynab exposing (fetchBudgets, fetchTransactions)

import Json.Decode as Decode
import Http exposing (..)
import Model exposing (Budget, AccessToken, BudgetId, Transaction)
import List.Zipper as Zipper exposing (Zipper)


fetchBudgets : String -> Request (Zipper Budget)
fetchBudgets token =
    fetchBudgetsDecoder
        |> Http.get (fetchBudgetsUrl token)


fetchTransactions : AccessToken -> BudgetId -> Request (List Transaction)
fetchTransactions token budgetId =
    Http.get (fetchTransactionsUrl token budgetId) fetchTransactionDecoder


fetchTransactionsUrl : AccessToken -> BudgetId -> String
fetchTransactionsUrl token budgetId =
    "https://api.youneedabudget.com/v1/budgets/"
        ++ budgetId
        ++ "/transactions?access_token="
        ++ token


fetchTransactionDecoder : Decode.Decoder (List Transaction)
fetchTransactionDecoder =
    transactionDecoder
        |> Decode.list
        |> Decode.field "transactions"
        |> Decode.field "data"


transactionDecoder : Decode.Decoder Transaction
transactionDecoder =
    Decode.map5 Transaction
        (Decode.field "id" Decode.string)
        (Decode.field "amount" Decode.int)
        (Decode.field "category_name" Decode.string)
        (Decode.field "payee_name" Decode.string)
        (Decode.field "date" Decode.string)


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


budgetDecoder : Decode.Decoder Budget
budgetDecoder =
    Decode.map2 Budget (Decode.field "id" Decode.string) (Decode.field "name" Decode.string)


ensureAtLeastOne : Maybe (Zipper Budget) -> Decode.Decoder (Zipper Budget)
ensureAtLeastOne maybeZipper =
    case maybeZipper of
        Just zipper ->
            Decode.succeed zipper

        Nothing ->
            Decode.fail "must have at least one budget."
