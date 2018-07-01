module Ynab exposing (fetchBudgets, fetchTransactions)

import Json.Decode as Decode
import Http exposing (..)
import Model exposing (Budget, AccessToken(..), BudgetId(..), Transaction)
import List.Zipper as Zipper exposing (Zipper)
import Date exposing (Date)
import Result exposing (..)


fetchBudgets : AccessToken -> Request (Zipper Budget)
fetchBudgets token =
    fetchBudgetsDecoder
        |> Http.get (fetchBudgetsUrl token)


fetchTransactions : AccessToken -> BudgetId -> Request (List Transaction)
fetchTransactions token budgetId =
    Http.get (fetchTransactionsUrl token budgetId) fetchTransactionDecoder


fetchTransactionsUrl : AccessToken -> BudgetId -> String
fetchTransactionsUrl (AccessToken token) (BudgetId budgetId) =
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
        (Decode.field "category_name" (Decode.nullable Decode.string))
        (Decode.field "payee_name" (Decode.nullable Decode.string))
        (Decode.field "date" decodeDate)


decodeDate : Decode.Decoder Date
decodeDate =
    let
        decodeDateOrFail str =
            case Date.fromString str of
                Ok date ->
                    Decode.succeed date

                Err e ->
                    Decode.fail e
    in
        Decode.string
            |> Decode.andThen (decodeDateOrFail)


fetchBudgetsUrl : AccessToken -> String
fetchBudgetsUrl (AccessToken token) =
    "https://api.youneedabudget.com/v1/budgets?access_token=" ++ token


fetchBudgetsDecoder : Decode.Decoder (Zipper Budget)
fetchBudgetsDecoder =
    budgetDecoder
        |> Decode.list
        |> Decode.field "budgets"
        |> Decode.field "data"
        |> Decode.map addDefaultBudgetIfNecessary
        |> Decode.map Zipper.fromList
        |> Decode.andThen ensureAtLeastOne


budgetDecoder : Decode.Decoder Budget
budgetDecoder =
    Decode.map2 Budget
        (Decode.field "id" (Decode.map BudgetId Decode.string))
        (Decode.field "name" Decode.string)


ensureAtLeastOne : Maybe (Zipper Budget) -> Decode.Decoder (Zipper Budget)
ensureAtLeastOne maybeZipper =
    case maybeZipper of
        Just zipper ->
            Decode.succeed zipper

        Nothing ->
            Decode.fail "must have at least one budget."


addDefaultBudgetIfNecessary : List Budget -> List Budget
addDefaultBudgetIfNecessary budgets =
    if List.length budgets > 1 then
        [ Model.defaultBudget ] ++ budgets
    else
        budgets
