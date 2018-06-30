module TransactionReducer exposing (savings, categories)

import Model exposing (..)
import List.Extra


savings : List Filter -> Maybe Adjustment -> List Transaction -> String
savings filters adjustment transactions =
    transactions
        |> List.filter (applyFilters filters)
        |> List.map .amount
        |> List.sum
        |> toFloat
        |> applyAdjustment adjustment
        |> format


categories : List Transaction -> List String
categories transactions =
    transactions
        |> List.map .category
        |> List.Extra.unique
        |> List.sort


applyAdjustment : Maybe Adjustment -> Float -> Float
applyAdjustment adjustment currentSavings =
    case adjustment of
        Just (Adjustment val) ->
            val * currentSavings

        Nothing ->
            currentSavings


format : Float -> String
format amount =
    let
        inDollars =
            -amount / 1000.0
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
