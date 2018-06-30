module TransactionReducer exposing (savings)

import Model exposing (..)


savings : List Filter -> List Transaction -> String
savings filters transactions =
    transactions
        |> List.filter (applyFilters filters)
        |> List.map .amount
        |> List.sum
        |> format


format : Int -> String
format amount =
    let
        inDollars =
            -(toFloat amount) / 1000.0
    in
        "$" ++ (toString inDollars)


applyFilters : List Filter -> Transaction -> Bool
applyFilters filters transaction =
    List.any (applyFilter transaction) filters


applyFilter : Transaction -> Filter -> Bool
applyFilter transaction filter =
    case filter of
        Category category ->
            transaction.category == category
